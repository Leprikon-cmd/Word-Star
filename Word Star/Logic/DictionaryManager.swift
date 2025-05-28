//
//  DictionaryManager.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import Foundation

// 📘 Структура одного словарного элемента
struct DictionaryItem: Codable {
    let word: String
    let definition: String
    let author: String
}

// 📚 Менеджер словаря
final class DictionaryManager {

    // 🔤 Все слова — множество слов в нижнем регистре
    private(set) var allWords: Set<String> = []

    // 🧠 Полный словарь: слово → DictionaryItem (определение + автор)
    private var fullDictionary: [String: DictionaryItem] = [:]

    // 📥 Загрузка из dictionary.json в бандле
    func loadWords() {
        guard let url = Bundle.main.url(forResource: "dictionary", withExtension: "json") else {
            print("❌ Файл словаря не найден")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let items = try decoder.decode([DictionaryItem].self, from: data)

            let withoutDefinition = items.filter { $0.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
            print("📉 Слов без определения: \(withoutDefinition)")

            fullDictionary.removeAll()
            allWords.removeAll()

            for item in items {
                let word = item.word.lowercased()
                fullDictionary[word] = item
                allWords.insert(word)
            }

            print("✅ Слов загружено: \(allWords.count)")

        } catch {
            print("💥 Ошибка загрузки словаря: \(error.localizedDescription)")
        }
    }

    // 🔍 Получить все слова
    func getWords() -> Set<String> {
        return allWords
    }

    // 📘 Получить определение
    func getDefinition(for word: String) -> String {
        return fullDictionary[word.lowercased()]?.definition ?? "Нет определения"
    }

    // ✍ Получить автора
    func getAuthor(for word: String) -> String {
        return fullDictionary[word.lowercased()]?.author ?? "Неизвестно"
    }
}
