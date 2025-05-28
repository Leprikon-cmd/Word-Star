//
//  LetterSetGenerator.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import Foundation

// 🧱 Структура одного игрового набора: буквы + допустимые слова
struct LetterSet {
    let letters: [Character]    // 🟡 5 букв, включая повторы
    let words: Set<String>      // ✅ допустимые слова
}

// 🔁 Генератор набора букв: выбирает 5 букв и ищет все возможные слова
final class LetterSetGenerator {

    private let LETTER_COUNT = 5          // 🔢 размер набора
    private let MIN_VALID_WORDS = 5       // 📉 минимум слов в наборе

    private let dictionary: DictionaryManager

    init(dictionary: DictionaryManager) {
        self.dictionary = dictionary
    }

    // 🎯 Основная функция генерации
    func generateSet() -> LetterSet? {
        let allWords = dictionary.getWords()

        // 1️⃣ Выбираем кандидатов — слова ровно из 5 букв
        let candidates = allWords.filter { $0.count == LETTER_COUNT }.shuffled()

        for base in candidates {
            let letters = Array(base) // сохраняем повторы (например, П, А, П, К, А)

            // 2️⃣ Ищем все слова, которые можно составить из этих букв
            let matching = allWords.filter { word in
                word.count >= 2 && canBuildWord(word, from: letters)
            }

            // 3️⃣ Проверяем минимальное количество
            if matching.count >= MIN_VALID_WORDS {
                return LetterSet(letters: letters, words: Set(matching))
            }
        }

        // ❌ Не удалось найти подходящий набор
        return nil
    }

    // ✅ Проверка: можно ли составить слово из заданных букв с повторами
    private func canBuildWord(_ word: String, from available: [Character]) -> Bool {
        let unique = Set(available)
        return word.allSatisfy { unique.contains($0) }
    }
}
