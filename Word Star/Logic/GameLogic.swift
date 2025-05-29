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
        var hasFive = false
        var hasFour = false
        var otherWords = 0

        for word in foundWords {
            switch word.count {
            case 5:
                hasFive = true
            case 4:
                hasFour = true
            case 2...:
                otherWords += 1
            default:
                continue
            }
        }

        // отнимаем 2 слова (4 и 5 букв) от общего числа
        let additionalWords = otherWords - (hasFour ? 1 : 0) - (hasFive ? 1 : 0)

        return hasFive && hasFour && additionalWords >= 3
    }
}
