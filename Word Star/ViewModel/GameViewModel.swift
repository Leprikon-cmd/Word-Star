//
//  GameViewModel.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import Foundation
import SwiftUI

// 🎯 Режим после завершения уровня
enum PostWinMode {
    case normal        // Обычный режим
    case explorer      // Режим исследователя (без штрафов)
    case challenge     // Вызов (с бонусами)
}

// 🎮 ViewModel — связывает UI и игровую логику
class GameViewModel: ObservableObject {

    // 📦 Published-свойства, которые следят за изменениями
    @Published var letters: [Character] = []          // текущий набор букв
    @Published var level: Int = 1                     // текущий уровень
    @Published var selectedLetters: [Character] = []  // 🔤 Слово в процессе составления
    @Published var result: String = ""                // ✅ Последний результат
    @Published var validWords: [String] = []          // 📋 Все допустимые слова
    @Published var foundWords: [String] = []          // 🧠 Найденные игроком слова
    @Published var score: Int = 0                     // 🧮 Очки
    @Published var showWinDialog: Bool = false        // 🏆 Победа
    @Published var lastResultSymbol: String? = nil    // ✅ или ❌ после ввода
    @Published var showOverlay: Bool = false          // 🔲 для будущих оверлеев
    @Published var isLevelPassed: Bool = false        // ✅ Уровень пройден по упрощённой логике
    @Published var postWinMode: PostWinMode = .normal // 🔁 Текущий режим
    @Published var isSurrendered: Bool = false        // ⚑ Игрок сдался

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
        isSurrendered = false // 🔁 сбрасываем флаг "Сдался"
        postWinMode = .normal // 🧹 Сброс режима на стандартный
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
    
    // ✅ Проверка условий прохождения уровня (в обычном режиме)
    private func checkLevelCompletion() {
        // ⚠️ Только в обычном режиме — иначе игнорируем
        guard postWinMode == .normal else { return }

        let foundSet = Set(foundWords)

        let has5LetterWord = foundSet.contains(where: { $0.count == 5 })
        let has4LetterWord = foundSet.contains(where: { $0.count == 4 })
        let atLeast3Others = foundSet.filter { $0.count != 4 && $0.count != 5 }.count >= 3

        if has5LetterWord && has4LetterWord && atLeast3Others {
            isLevelPassed = true
            showWinDialog = true
            print("🎉 Уровень пройден по упрощённой логике!")
        }
    }

    // ➕ Попытка добавить слово
    func tryAddWord(_ word: String) {
        if gameLogic.isValidWord(word), !foundWords.contains(word) {
            foundWords.append(word)

            // 🔍 Обработка режима "Исследователь"
            if postWinMode == .explorer {
                result = "ℹ️ \(word) (без очков)"
                lastResultSymbol = "✅"
            } else {
                // 🎯 Стандарт или вызов — начисляем очки
                addScore(for: word.count)
                result = "✅ \(word)"
                lastResultSymbol = "✅"
            }

            // 💾 Сохраняем прогресс
            progressManager.saveProgress(
                letters: letters,
                foundWords: foundWords,
                validWords: validWords,
                score: score,
                level: level
            )

            // 🎯 Проверка условий прохождения уровня
            checkLevelCompletion()

            // 🏆 Полное прохождение уровня
            if foundWords.count == gameLogic.getValidWords().count {
                if postWinMode == .challenge {
                    let bonus = foundWords.count * 5
                    score += bonus
                    result += " 🎁 +\(bonus) бонусных очков!"
                }

                if postWinMode != .explorer {
                    showWinDialog = true
                }
            }

        } else {
            // ❌ Неверное или повторное слово
            result = "❌"
            lastResultSymbol = "❌"
        }

        // ⏳ Через 1.5 секунды убираем символ результата
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
