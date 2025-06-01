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

// 📘 Менеджер словаря — Singleton + ObservableObject
class DictionaryManager: ObservableObject {
    static let shared = DictionaryManager() // 🔂 глобальный доступ
    
    private init() {
        loadWords()
    }
    
    // 🔤 Все слова — множество слов в нижнем регистре
    private var allWords: Set<String> = []
    
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

            let enabledAuthors = SettingsManager.shared.enabledAuthors

            fullDictionary.removeAll()
            allWords.removeAll()

            var withoutDefinition = 0

            for item in items {
                let word = item.word.lowercased()
                let trimmedDefinition = item.definition.trimmingCharacters(in: .whitespacesAndNewlines)

                let itemAuthors = item.author
                    .components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

                let hasMatchingAuthor = itemAuthors.contains(where: { enabledAuthors.contains($0) })

                let isGithubEntry = trimmedDefinition.isEmpty || item.author == "нет"
                let githubAllowed = enabledAuthors.contains("нет")

                // ❌ Пропускаем гитхабовские, если они отключены
                if isGithubEntry && !githubAllowed {
                    continue
                }

                // ❌ Пропускаем слова от авторов, не включённых в настройках
                if !hasMatchingAuthor {
                    continue
                }

                if trimmedDefinition.isEmpty {
                    withoutDefinition += 1
                }

                fullDictionary[word] = item
                allWords.insert(word)
            }

            print("📉 Слов без определения: \(withoutDefinition)")
            print("✅ Слов загружено после фильтрации: \(allWords.count)")

        } catch {
            print("💥 Ошибка загрузки словаря: \(error.localizedDescription)")
        }
    }
    
    // 🔒 Проверка, разрешено ли показывать определение слова (по автору)
    func isDefinitionVisible(for item: DictionaryItem) -> Bool {
        for author in SettingsManager.shared.enabledAuthors {
            if item.author.contains(author) {
                return true
            }
        }
        return false
    }
    
    // 🔍 Получить все слова
    func getWords() -> Set<String> {
        return allWords
    }
    
    func getDefinition(for word: String) -> String {
        guard let item = fullDictionary[word.lowercased()] else {
            return "Нет определения"
        }
        
        let enabled = SettingsManager.shared.enabledAuthors
        
        // если определение не содержит подписи авторов — просто проверим по мета-автору
        if !item.definition.contains("\n/") {
            let authors = item.author.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for a in authors {
                if enabled.contains(a) {
                    return "\(item.definition)\n/\(a)/"
                }
            }
            return "Нет определения"
        }
        
        // ищем блоки: определение + подпись
        let pattern = #"(?s)(.*?)(?:\n/([^/]+?)/)"#
        var result: [String] = []
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let matches = regex?.matches(in: item.definition, options: [], range: NSRange(item.definition.startIndex..., in: item.definition)) ?? []
        
        for match in matches {
            if match.numberOfRanges == 3,
               let defRange = Range(match.range(at: 1), in: item.definition),
               let authorRange = Range(match.range(at: 2), in: item.definition) {
                
                let def = item.definition[defRange].trimmingCharacters(in: .whitespacesAndNewlines)
                let author = item.definition[authorRange].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if enabled.contains(author) {
                    result.append("\(def)\n/\(author)/")
                }
            }
        }
        
        return result.isEmpty ? "Нет определения" : result.joined(separator: "\n\n")
    }
}
