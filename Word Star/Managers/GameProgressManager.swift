//
//  GameProgressManager.swift
//  Word Star
//
//  Created by ChatGPT on 27.05.2025
//

import Foundation

/// 📦 Менеджер для сохранения, загрузки и восстановления прогресса игры.
/// Использует UserDefaults — встроенное хранилище ключ-значение.
/// Работает как Singleton — единая точка доступа.
class GameProgressManager: ObservableObject {
    
    // 🔒 Общий экземпляр
    static let shared = GameProgressManager()

    // 🗝️ Ключи для хранения данных
    private let lettersKey = "progress_letters"
    private let validWordsKey = "progress_validWords"
    private let foundWordsKey = "progress_foundWords"
    private let scoreKey = "progress_score"
    private let levelKey = "progress_level"

    // ❌ Запрещаем создание экземпляров извне
    private init() {}

    // MARK: - 💾 Сохранение прогресса

    /// Сохраняем состояние игры: буквы, найденные слова, валидные слова, очки и уровень
    func saveProgress(letters: [Character], foundWords: [String], validWords: [String], score: Int, level: Int) {
        // UserDefaults не умеет сохранять [Character], конвертируем в [String]
        let letterStrings = letters.map { String($0) }

        UserDefaults.standard.set(letterStrings, forKey: lettersKey)
        UserDefaults.standard.set(validWords, forKey: validWordsKey)
        UserDefaults.standard.set(foundWords, forKey: foundWordsKey)
        UserDefaults.standard.set(score, forKey: scoreKey)
        UserDefaults.standard.set(level, forKey: levelKey)

        print("✅ Прогресс сохранён: букв \(letters.count), найдено слов \(foundWords.count), очки \(score), уровень \(level)")
    }

    // MARK: - 📤 Загрузка прогресса

    /// Загружаем сохранённое состояние. Если ничего нет — возвращаем nil
    func loadProgress() -> (letters: [Character], foundWords: [String], validWords: [String], score: Int, level: Int)? {
        // ⚠️ Проверяем, что все ключевые данные есть
        guard let letterStrings = UserDefaults.standard.stringArray(forKey: lettersKey),
              let foundWords = UserDefaults.standard.stringArray(forKey: foundWordsKey),
              let validWords = UserDefaults.standard.stringArray(forKey: validWordsKey) else {
            print("⚠️ Нет сохранённого прогресса")
            return nil
        }

        // 🔤 Преобразуем [String] в [Character]
        let letters = letterStrings.compactMap { $0.first }

        let score = UserDefaults.standard.integer(forKey: scoreKey)
        let level = UserDefaults.standard.integer(forKey: levelKey)

        print("📦 Прогресс загружен: букв \(letters.count), найдено слов \(foundWords.count), очки \(score), уровень \(level)")

        return (letters, foundWords, validWords, score, level)
    }

    // MARK: - 🧼 Очистка прогресса

    /// Удаляем всё сохранённое состояние игры
    func clearProgress() {
        UserDefaults.standard.removeObject(forKey: lettersKey)
        UserDefaults.standard.removeObject(forKey: foundWordsKey)
        UserDefaults.standard.removeObject(forKey: validWordsKey)
        UserDefaults.standard.removeObject(forKey: scoreKey)
        UserDefaults.standard.removeObject(forKey: levelKey)

        print("🗑️ Прогресс сброшен")
    }

    // MARK: - 🧠 Восстановление логики и ViewModel из сохранённого прогресса

    /// Полностью восстанавливает GameLogic и GameViewModel из сохранённого состояния
    func restoreGame(dictionary: DictionaryManager, generator: LetterSetGenerator) -> (GameLogic, GameViewModel)? {
        guard let saved = loadProgress() else {
            return nil
        }

        // ⚙️ Восстанавливаем игровую логику
        let logic = GameLogic()
        logic.loadState(
            letters: saved.letters,
            validWords: saved.validWords,
            foundWords: Set(saved.foundWords)
        )

        // 🧠 Создаём ViewModel и подгружаем туда прогресс
        let viewModel = GameViewModel(
            dictionaryManager: dictionary,
            generator: generator,
            gameLogic: logic,
            forceNewGame: false
        )
        viewModel.loadState(
            letters: saved.letters,
            validWords: saved.validWords,
            foundWords: Set(saved.foundWords)
        )
        viewModel.score = saved.score
        viewModel.level = saved.level
        viewModel.updateWords()

        return (logic, viewModel)
    }
}
