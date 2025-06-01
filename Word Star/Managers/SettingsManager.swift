//
//  SettingsManager.swift
//  Word Star
//
//  Created by ChatGPT & Евгений Зотчик on 30.05.2025.
//
import SwiftUI

/// 🧠 Менеджер настроек приложения с поддержкой реактивности
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager() // 🧷 Синглтон

    private let defaults = UserDefaults.standard

    private init() {
        // 🔤 Загружаем настройки из UserDefaults
        self.selectedFont = defaults.string(forKey: "selectedFontName") ?? "DefaultFont"
        self.selectedBackground = defaults.string(forKey: "selectedBackground") ?? "default"
        self.isGameModeEnabled = defaults.bool(forKey: "isGameModeEnabled")
        self.isSoundEnabled = defaults.object(forKey: "isSoundEnabled") as? Bool ?? true
        self.selectedDictionary = defaults.string(forKey: "selectedDictionary") ?? "all"

        // 📚 Загружаем включённые авторы
        if let savedAuthors = defaults.array(forKey: "enabledAuthors") as? [String] {
            self.enabledAuthors = Set(savedAuthors)
        } else {
            self.enabledAuthors = [
                "С. И. Ожегов",
                "А. П. Евгеньева",
                "В. И. Даль",
                "нет"
            ]
        }
    }

    // 🔤 Выбранный шрифт
    @Published var selectedFont: String {
        didSet {
            defaults.set(selectedFont, forKey: "selectedFontName")
        }
    }

    // 🌄 Выбранный фон
    @Published var selectedBackground: String {
        didSet {
            defaults.set(selectedBackground, forKey: "selectedBackground")
        }
    }

    // 💀 Игровой режим с жизнями
    @Published var isGameModeEnabled: Bool {
        didSet {
            defaults.set(isGameModeEnabled, forKey: "isGameModeEnabled")
        }
    }

    // 🔈 Звуки включены
    @Published var isSoundEnabled: Bool {
        didSet {
            defaults.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }

    // ✅ Автор(ы) включённые для показа словарей
    @Published var enabledAuthors: Set<String> {
        didSet {
            let arrayToSave = Array(enabledAuthors)
            defaults.set(arrayToSave, forKey: "enabledAuthors")
        }
    }

    // 📚 Выбранный словарь (сейчас не используется, но пусть останется)
    @Published var selectedDictionary: String {
        didSet {
            defaults.set(selectedDictionary, forKey: "selectedDictionary")
        }
    }

    // 🧼 Сброс всех настроек
    func resetAll() {
        selectedFont = "DefaultFont"
        selectedBackground = "default"
        isGameModeEnabled = false
        isSoundEnabled = true
        selectedDictionary = "all"
        enabledAuthors = [
            "С. И. Ожегов",
            "А. П. Евгеньева",
            "В. И. Даль",
            "нет"
        ]
    }
}
