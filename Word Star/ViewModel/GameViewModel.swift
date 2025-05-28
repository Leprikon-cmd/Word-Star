//
//  GameViewModel.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import Foundation
import SwiftUI

// 🎮 Основная модель представления для игры
// 🧠 ViewModel для игры
class GameViewModel: ObservableObject {

    @Published var letters: [Character] = []         // текущий набор букв
    @Published var level: Int = 1
    @Published var selectedLetters: [Character] = [] // 🔤 Текущий ввод (посимвольно)
    @Published var result: String = ""               // ✅ Результат последней проверки (строка)
    @Published var validWords: [String] = []         // 📋 Все допустимые слова для уровня
    @Published var foundWords: [String] = []         // 🧠 Найденные игроком слова
    @Published var score: Int = 0                    // 🧮 Текущий счёт
    @Published var showWinDialog: Bool = false       // 🏆 Флаг победы
    @Published var lastResultSymbol: String? = nil   // ✅❌ Символ результата (галка/крестик)
    @Published var showOverlay: Bool = false         // 🔲 Оверлей — пока не используется
    private var lastAddedChar: Character? = nil      // 🔐 Защита от повторного тапа по той же букве подряд (если понадобится)

    // 📦 Генератор и словарь (инициализируются при создании)
    private let dictionaryManager: DictionaryManager
    private let letterSetGenerator: LetterSetGenerator
    private let progressManager = GameProgressManager.shared // 🎒 менеджер сохранения
    
    let gameLogic: GameLogic

    init(dictionaryManager: DictionaryManager, generator: LetterSetGenerator, gameLogic: GameLogic, forceNewGame: Bool = false) {
        self.dictionaryManager = dictionaryManager
        self.letterSetGenerator = generator
        self.gameLogic = gameLogic

        if forceNewGame {
            print("🧼 Принудительно новая игра")
            startNewGame()
        } else if let saved = progressManager.loadProgress() {
            print("📦 Загружаем сохранённую игру")
            self.letters = saved.letters
            self.foundWords = saved.foundWords
            self.score = saved.score
            self.level = saved.level
            gameLogic.loadState(letters: saved.letters, foundWords: Set(saved.foundWords))
            updateWords()
        } else {
            print("🆕 Прогресса нет — старт новой игры")
            startNewGame()
        }
    }
    
    func startNewGame() {
        gameLogic.generateNewLevel(from: letterSetGenerator)     // 🎮 Сначала генерим уровень
        letters = gameLogic.getLetters()                          // ✍️ Сохраняем буквы для отрисовки
        validWords = gameLogic.getValidWords().sorted(by: {      // 📜 Получаем все слова
            $0.count == $1.count ? $0 < $1 : $0.count > $1.count
        })
        foundWords = []
        score = 0
        result = ""
        showWinDialog = false
    }
    
    func loadState(letters: [Character], foundWords: Set<String>) {
        self.letters = letters
        self.foundWords = Array(foundWords)
    }


    // 🔁 Сброс уровня и попытка загрузить прогресс
    func resetGame() {
        // 🧹 Чистим всё, что связано с вводом
        selectedLetters.removeAll()
        foundWords.removeAll()
        score = 0
        result = ""
        showWinDialog = false

        // 📦 Пробуем загрузить прогресс
        if let savedProgress = progressManager.loadProgress() {
            print("📦 Прогресс найден — загружаем")

            // ✅ Преобразуем [String] → [Character]
            let restoredLetters: [Character] = savedProgress.letters.flatMap { $0 }

            // ✅ Преобразуем [String] → Set<String>
            let restoredFoundWords = Set(savedProgress.foundWords)

            gameLogic.loadState(
                letters: restoredLetters,
                foundWords: restoredFoundWords
            )

            letters = restoredLetters
            foundWords = Array(restoredFoundWords)
            score = savedProgress.score

            updateWords()
        } else {
            print("🆕 Прогресс не найден — генерим новый уровень")

            gameLogic.generateNewLevel(from: letterSetGenerator)
            letters = gameLogic.getLetters()
            updateWords()
        }
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
            progressManager.saveProgress(
                letters: letters,
                foundWords: foundWords,
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

        // ⏳ Через 1.5 сек убрать символ результата
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.lastResultSymbol = nil
        }
    }

    // 📊 Начисление очков
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

    // 🔄 Обновить список допустимых слов
    func updateWords() {
        validWords = gameLogic.getValidWords().sorted { $0.count > $1.count }
    }

    // ➕ Добавить букву
    func addLetter(_ letter: Character) {
        selectedLetters.append(letter)
    }

    // 🧹 Очистить ввод
    func clearSelection() {
        selectedLetters.removeAll()
        result = ""
        lastAddedChar = nil
    }

    // ℹ️ Кол-во угаданных слов
    func getFoundWordCount() -> Int {
        return foundWords.count
    }

    // ℹ️ Общее кол-во слов
    func getTotalValidWordCount() -> Int {
        return gameLogic.getValidWords().count
    }

    // 🔤 Текущее составляемое слово
    func getWord() -> String {
        return selectedLetters.map { String($0) }.joined()
    }
}
