//
//  GameLogic.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//

import Foundation

/// 🧠 GameLogic — центральная логика уровня:
/// - генерирует буквы и допустимые слова
/// - проверяет введённые слова
/// - восстанавливает состояние из сохранения
final class GameLogic {
    
    // 🔠 Буквы уровня (только для чтения извне)
    private(set) var currentLetters: [Character] = []
    
    // ✅ Допустимые слова (в нижнем регистре)
    private(set) var validWords: Set<String> = []
    
    // MARK: - 🚀 Генерация уровня
    
    /// Генерирует новый уровень: буквы + допустимые слова
    func generateNewLevel(from generator: LetterSetGenerator) {
        if let set = generator.generateSet() {
            currentLetters = set.letters
            validWords = set.words
            print("📥 Сгенерированы буквы: \(currentLetters)")
            print("✅ Найдено слов: \(validWords.count)")
        } else {
            // 🔁 Резервный набор на случай ошибки
            currentLetters = ["А", "Р", "С", "Т", "У"]
            validWords = []
            print("⚠️ Ошибка генерации — использован запасной набор")
        }
    }
    
    // MARK: - ✅ Проверка слова
    
    /// Проверяет, является ли слово допустимым
    func isValidWord(_ input: String) -> Bool {
        let word = input.lowercased()
        return word.count >= 2 && validWords.contains(word)
    }
    
    /// Проверяет, можно ли собрать слово из доступных букв
    /// (учитывает повторы, если буква используется несколько раз)
    func canBuildWord(_ word: String, from letters: [Character]) -> Bool {
        var available = Dictionary(grouping: letters, by: { $0 }).mapValues { $0.count }
        
        for char in word {
            guard let count = available[char], count > 0 else {
                return false
            }
            available[char]! -= 1
        }
        
        return true
    }
    
    // MARK: - 📤 Получение данных
    
    /// Возвращает буквы текущего уровня
    func getLetters() -> [Character] {
        return currentLetters
    }
    
    /// Возвращает список допустимых слов
    func getValidWords() -> [String] {
        return Array(validWords)
    }
    
    // MARK: - 💾 Восстановление состояния
    
    /// Загружает ранее сохранённое состояние уровня
    func loadState(letters: [Character], validWords: [String], foundWords: Set<String>) {
        self.currentLetters = letters
        self.validWords = Set(validWords)
        // ❗ foundWords не используется внутри логики (см. GameViewModel)
        // Поэтому можно игнорировать, либо оставить на будущее.
    }
    
    // ✅ Проверка условий прохождения уровня по новым критериям
    func isLevelCompleted(foundWords: [String]) -> Bool {
        var usedWords: [String] = []
        var hasFive = false
        var hasFour = false
        var otherCount = 0
        
        for word in foundWords {
            if !hasFive && word.count >= 5 {
                hasFive = true
                usedWords.append(word)
                continue
            }
            
            if !hasFour && word.count >= 4 && !usedWords.contains(word) {
                hasFour = true
                usedWords.append(word)
                continue
            }
            
            if word.count >= 2 && !usedWords.contains(word) {
                otherCount += 1
                usedWords.append(word)
            }
            
            if hasFive && hasFour && otherCount >= 3 {
                return true
            }
        }
        
        return false
    }
}
