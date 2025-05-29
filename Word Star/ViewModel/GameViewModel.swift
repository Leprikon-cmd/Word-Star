//
//  GameViewModel.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import Foundation
import SwiftUI

// 🎮 ViewModel — связывает UI и игровую логику
class GameViewModel: ObservableObject {

    // 📦 Published-свойства, которые следят за изменениями
    @Published var letters: [Character] = []         // текущий набор букв
    @Published var level: Int = 1                    // текущий уровень
    @Published var selectedLetters: [Character] = [] // 🔤 Слово в процессе составления
    @Published var result: String = ""               // ✅ Последний результат
    @Published var validWords: [String] = []         // 📋 Все допустимые слова
    @Published var foundWords: [String] = []         // 🧠 Найденные игроком слова
    @Published var score: Int = 0                    // 🧮 Очки
    @Published var showWinDialog: Bool = false       // 🏆 Победа
    @Published var lastResultSymbol: String? = nil   // ✅ или ❌ после ввода
    @Published var showOverlay: Bool = false         // 🔲 для будущих оверлеев

    private var lastAddedChar: Character? = nil      // 🔐 на будущее — защита от повтора буквы

    // 📚 Основные зависимости
    private let dictionaryManager: DictionaryManager
    private let letterSetGenerator: LetterSetGenerator
    private let progressManager = GameProgressManager.shared

    let gameLogic: GameLogic

    // ⚙️ Конструктор с возможностью принудительно начать новую игру
    init(dictionaryManager: DictionaryManager, generator: LetterSetGenerator, gameLogic: GameLogic, forceNewGame: Bool = false) {
        self.dictionaryManager = dictionaryManager
        self.letterSetGenerator = generator
        self.gameLogic = gameLogic

        if forceNewGame {
            print("🧼 Принудительно новая игра")
            startNewGame()
        } else if let saved = progressManager.loadProgress() {
            print("📦 Загружаем сохранённую игру")

            // 🎮 Восстанавливаем всё
            self.letters = saved.letters
            self.validWords = saved.validWords
            self.foundWords = saved.foundWords
            self.score = saved.score
            self.level = saved.level

            gameLogic.loadState(
                letters: saved.letters,
                validWords: saved.validWords,
                foundWords: Set(saved.foundWords)
            )

            updateWords()
        } else {
            print("🆕 Прогресса нет — старт новой игры")
            startNewGame()
        }
    }

    // 🔁 Генерация нового уровня
    func startNewGame() {
        gameLogic.generateNewLevel(from: letterSetGenerator)
        letters = gameLogic.getLetters()
        validWords = gameLogic.getValidWords().sorted(by: { $0.count == $1.count ? $0 < $1 : $0.count > $1.count })
        foundWords = []
        score = 0
        level = 1
        result = ""
        showWinDialog = false
    }

    // 🧠 Загрузка состояния из сохранённого (например, в GameProgressManager.restoreGame)
    func loadState(letters: [Character], validWords: [String], foundWords: Set<String>) {
        self.letters = letters
        self.validWords = validWords
        self.foundWords = Array(foundWords)
    }

    // 🔁 Сброс (используется при нажатии «🔄»)
    func resetGame() {
        print("🔄 Принудительный сброс — начинаем новую игру")

        // 🧹 Чистим прогресс
        progressManager.clearProgress()

        // 🆕 Запускаем новую игру
        startNewGame()
    }

    // ✅ Проверка введённого слова
    func validateWord() {
        let word = selectedLetters.map { String($0) }.joined()
        tryAddWord(word)
        clearSelection()
    }

    // ➕ Попытка добавить слово
    func tryAddWord(_ word: String) {
        if gameLogic.isValidWord(word), !foundWords.contains(word) {
            foundWords.append(word)
            addScore(for: word.count)
            result = "✅ \(word)"
            lastResultSymbol = "✅"

            // 💾 Сохраняем прогресс
            progressManager.saveProgress(
                letters: letters,
                foundWords: foundWords,
                validWords: validWords,
                score: score,
                level: level
            )

            if foundWords.count == gameLogic.getValidWords().count {
                showWinDialog = true
                let bonus = foundWords.count * 5
                score += bonus
                result += " 🎁 +\(bonus) бонусных очков!"
            }

        } else {
            result = "❌"
            lastResultSymbol = "❌"
        }

        // ⏳ Убираем индикатор результата через 1.5 сек
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.lastResultSymbol = nil
        }
    }

    // 📊 Подсчёт очков
    private func addScore(for length: Int) {
        let base: Int
        switch length {
        case 2...3: base = 5
        case 4: base = 10
        case 5: base = 20
        case 6: base = 30
        default: base = 40 + (length - 6) * 10
        }
        score += base
    }

    // 🔁 Обновление слов в списке
    func updateWords() {
        validWords = gameLogic.getValidWords().sorted { $0.count > $1.count }
    }

    // ➕ Добавление буквы
    func addLetter(_ letter: Character) {
        selectedLetters.append(letter)
    }

    // 🧹 Очистка ввода
    func clearSelection() {
        selectedLetters.removeAll()
        result = ""
        lastAddedChar = nil
    }

    // ℹ️ Кол-во угаданных
    func getFoundWordCount() -> Int {
        return foundWords.count
    }

    // ℹ️ Общее допустимых
    func getTotalValidWordCount() -> Int {
        return gameLogic.getValidWords().count
    }

    // 🧱 Слово в процессе составления
    func getWord() -> String {
        return selectedLetters.map { String($0) }.joined()
    }
}
