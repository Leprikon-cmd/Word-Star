//
//  GameLogic.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import Foundation

// GameLogic — логика игры (одиночка), как в Android-версии
final class GameLogic {
    
    private var letters: [Character] = []
    private var foundWords: Set<String> = []
    
    // 🔠 Текущий набор букв для уровня
    private(set) var currentLetters: [Character] = []
    
    func getLetters() -> [Character] {
        return currentLetters
    }
    
    // ✅ Допустимые слова для текущего уровня
    private(set) var validWords: Set<String> = []

    // 🔁 Генерация нового уровня: получаем буквы и допустимые слова
    func generateNewLevel(from generator: LetterSetGenerator) {
        if let set = generator.generateSet() {
            currentLetters = set.letters
            validWords = set.words
            print("📥 Сгенерированы буквы: \(currentLetters)")
            print("✅ Допустимых слов: \(validWords.count)")
        } else {
            currentLetters = ["А", "Р", "С", "Т", "У"]  // fallback-набор
            validWords = []
            print("⚠️ Не удалось сгенерировать набор, использован запасной")
        }
    }

    // 🔎 Проверка: можно ли собрать такое слово и оно в списке
    func isValidWord(_ input: String) -> Bool {
        let word = input.lowercased()
        return word.count >= 2 && validWords.contains(word)
    }

    // 🧠 Проверка, можно ли собрать слово из букв (с повторами)
    func canBuildWord(_ word: String, from letters: [Character]) -> Bool {
        var available = Dictionary(grouping: letters, by: { $0 }).mapValues { $0.count }

        for char in word {
            let count = available[char] ?? 0
            if count == 0 {
                return false
            }
            available[char] = count - 1
        }

        return true
    }

    // 📤 Получить все допустимые слова
    func getValidWords() -> [String] {
        return Array(validWords)
    }
    func loadState(letters: [Character], foundWords: Set<String>) {
        self.letters = letters
        self.foundWords = foundWords
    }
}
