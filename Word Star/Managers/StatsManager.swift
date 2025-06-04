//
//  StatsManager.swift
//  Word Star
//
//  Created by ChatGPT & Евгений Зотчик on 01.06.2025.
//

import Foundation

/// 📊 Менеджер статистики (Singleton + ObservableObject)
final class StatsManager: ObservableObject {
    static let shared = StatsManager() // 🧷 глобальный доступ

    private let defaults = UserDefaults.standard

    private let foundWordsKey = "foundWords"
    private let gameStatsKey = "gameStats"

    /// 🧠 Угаданные слова и число повторений
    @Published private(set) var foundWords: [String: Int] = [:]

    /// 🎮 Статистика игр по уровням и режимам
    @Published private(set) var gameStats: [String: [PostWinMode: (total: Int, wins: Int)]] = [:]

    private init() {
        load()
    }

    // 📥 Загрузка из UserDefaults
    private func load() {
        // 🧠 Загружаем найденные слова
        if let wordData = defaults.data(forKey: foundWordsKey),
           let decodedWords = try? JSONDecoder().decode([String: Int].self, from: wordData) {
            foundWords = decodedWords
        }

        // 🎮 Загружаем статистику по играм
        if let statsData = defaults.data(forKey: gameStatsKey),
           let decodedStats = try? JSONDecoder().decode([String: [String: [Int]]].self, from: statsData) {
            var result: [String: [PostWinMode: (Int, Int)]] = [:]
            for (level, modeDict) in decodedStats {
                var modeStats: [PostWinMode: (Int, Int)] = [:]
                for (modeRaw, array) in modeDict {
                    if let mode = PostWinMode(rawValue: modeRaw), array.count == 2 {
                        modeStats[mode] = (array[0], array[1])
                    }
                }
                result[level] = modeStats
            }
            gameStats = result
        }
    }

    // 💾 Сохранение всех данных
    private func save() {
        // 💾 Сохраняем найденные слова
        if let wordData = try? JSONEncoder().encode(foundWords) {
            defaults.set(wordData, forKey: foundWordsKey)
        }

        // 💾 Сохраняем статистику игр
        var encodableStats: [String: [String: [Int]]] = [:]
        for (level, modeDict) in gameStats {
            var modeStats: [String: [Int]] = [:]
            for (mode, stats) in modeDict {
                modeStats[mode.rawValue] = [stats.total, stats.wins]
            }
            encodableStats[level] = modeStats
        }

        if let statsData = try? JSONEncoder().encode(encodableStats) {
            defaults.set(statsData, forKey: gameStatsKey)
        }
    }

    // ➕ Добавить угаданное слово
    func registerFound(word: String) {
        let key = word.lowercased()
        foundWords[key, default: 0] += 1
        save()
    }

    // ➕ Зарегистрировать игру
    func registerGame(level: String, mode: PostWinMode, won: Bool) {
        var modeStats = gameStats[level] ?? [:]
        var stat = modeStats[mode] ?? (0, 0)
        stat.total += 1
        if won { stat.wins += 1 }
        modeStats[mode] = stat
        gameStats[level] = modeStats
        save()
    }

    // 🧼 Сброс всей статистики
    func resetAll() {
        foundWords = [:]
        gameStats = [:]
        defaults.removeObject(forKey: foundWordsKey)
        defaults.removeObject(forKey: gameStatsKey)
    }
}
