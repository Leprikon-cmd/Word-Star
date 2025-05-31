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
        // Загружаем начальные значения из UserDefaults
        self.selectedFont = defaults.string(forKey: "selectedFontName") ?? "DefaultFont"
        self.selectedBackground = defaults.string(forKey: "selectedBackground") ?? "default"
        self.isGameModeEnabled = defaults.bool(forKey: "isGameModeEnabled")
        self.isSoundEnabled = defaults.object(forKey: "isSoundEnabled") as? Bool ?? true
        self.selectedDictionary = defaults.string(forKey: "selectedDictionary") ?? "all"
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

    // 📚 Выбранный словарь (дал, ожегов, евгеньева, all)
    @Published var selectedDictionary: String {
        didSet {
            defaults.set(selectedDictionary, forKey: "selectedDictionary")
        }
    }

    // 🧼 Сброс всех настроек (на крайний случай)
    func resetAll() {
        selectedFont = "DefaultFont"
        selectedBackground = "default"
        isGameModeEnabled = false
        isSoundEnabled = true
        selectedDictionary = "all"
    }
}
