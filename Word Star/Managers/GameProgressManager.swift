//
//  GameProgressManager.swift
//  Word Star
//
//  Created by ChatGPT on 27.05.2025
//

import Foundation

// 📦 Менеджер для сохранения и загрузки прогресса игры
// Использует UserDefaults — встроенное хранилище ключ-значение
class GameProgressManager: ObservableObject {
    static let shared = GameProgressManager() // 🔒 Singleton: один общий экземпляр

    // 🗝️ Ключи для хранения данных
    private let lettersKey = "progress_letters"
    private let foundWordsKey = "progress_foundWords"
    private let scoreKey = "progress_score"
    private let levelKey = "progress_level"

    private init() {}

    // 💾 Сохранение прогресса
    func saveProgress(letters: [Character], foundWords: [String], score: Int, level: Int) {
        // UserDefaults не умеет сохранять [Character], поэтому конвертим в [String]
        let letterStrings = letters.map { String($0) }

        UserDefaults.standard.set(letterStrings, forKey: lettersKey)
        UserDefaults.standard.set(foundWords, forKey: foundWordsKey)
        UserDefaults.standard.set(score, forKey: scoreKey)
        UserDefaults.standard.set(level, forKey: levelKey)

        print("✅ Прогресс сохранён: букв \(letters.count), слов \(foundWords.count), очки \(score), уровень \(level)")
    }

    // 📤 Загрузка прогресса
    func loadProgress() -> (letters: [Character], foundWords: [String], score: Int, level: Int)? {
        guard let letterStrings = UserDefaults.standard.stringArray(forKey: lettersKey),
              let foundWords = UserDefaults.standard.stringArray(forKey: foundWordsKey)
        else {
            print("⚠️ Нет сохранённого прогресса")
            return nil
        }

        // Конвертим [String] → [Character]
        let letters = letterStrings.compactMap { $0.first }

        let score = UserDefaults.standard.integer(forKey: scoreKey)
        let level = UserDefaults.standard.integer(forKey: levelKey)

        print("📦 Прогресс загружен: букв \(letters.count), слов \(foundWords.count), очки \(score), уровень \(level)")

        return (letters, foundWords, score, level)
    }

    // 🧼 Очистка прогресса (если надо сбросить всё начисто)
    func clearProgress() {
        UserDefaults.standard.removeObject(forKey: lettersKey)
        UserDefaults.standard.removeObject(forKey: foundWordsKey)
        UserDefaults.standard.removeObject(forKey: scoreKey)
        UserDefaults.standard.removeObject(forKey: levelKey)

        print("🗑️ Прогресс сброшен")
    }
}
