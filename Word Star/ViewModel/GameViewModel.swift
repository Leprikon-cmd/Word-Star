//
//  GameViewModel.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import Foundation
import SwiftUI

// 🎮 Основная модель представления для игры
final class GameViewModel: ObservableObject {

    // 🎨 Текущий фон
    @Published var backgroundImage: String = "Background1.jpg"
    
    // текущий набор букв
    @Published var letters: [Character] = []

    // 🔤 Текущий ввод (посимвольно)
    @Published var selectedLetters: [Character] = []

    // ✅ Результат последней проверки (строка)
    @Published var result: String = ""

    // 📋 Все допустимые слова для уровня
    @Published var validWords: [String] = []

    // 🧠 Найденные игроком слова
    @Published var foundWords: [String] = []

    // 🧮 Текущий счёт
    @Published var score: Int = 0

    // 🏆 Флаг победы
    @Published var showWinDialog: Bool = false

    // ✅❌ Символ результата (галка/крестик)
    @Published var lastResultSymbol: String? = nil

    // 🔲 Оверлей — пока не используется
    @Published var showOverlay: Bool = false

    // 🔐 Защита от повторного тапа по той же букве подряд (если понадобится)
    private var lastAddedChar: Character? = nil

    // 📦 Генератор и словарь (инициализируются при создании)
    private let dictionaryManager: DictionaryManager
    private let letterSetGenerator: LetterSetGenerator
    let gameLogic: GameLogic

    init(dictionaryManager: DictionaryManager, generator: LetterSetGenerator, gameLogic: GameLogic) {
        self.dictionaryManager = dictionaryManager
        self.letterSetGenerator = generator
        self.gameLogic = gameLogic

        startNewGame() // 🚀 Только один вызов, и всё красиво
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
        pickNewBackground()
        showWinDialog = false
    }

    // 🎨 Случайный фон
    func pickNewBackground() {
        let index = Int.random(in: 1...62)
        backgroundImage = "Background\(index)"
    }

    // 🔁 Сброс уровня
    func resetGame() {
        foundWords.removeAll()
        score = 0
        result = ""
        selectedLetters.removeAll()
        gameLogic.generateNewLevel(from: letterSetGenerator)
        letters = gameLogic.getLetters() // ✅ обновим published-свойство
        updateWords()
        pickNewBackground()
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
