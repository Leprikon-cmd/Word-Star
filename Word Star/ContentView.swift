//
//  ContentView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//

import SwiftUI

// 📍 Навигационные маршруты
enum Screen: Hashable {
    case start
    case game(forceNewGame: Bool)
    case settings
    case stats
}

struct ContentView: View {
    // 🧭 Управление стеком экранов
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            StartView { destination in
                path.append(destination)
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .start:
                    StartView { destination in path.append(destination) }
                case .game(let forceNewGame):
                        GameScreenView(forceNewGame: forceNewGame)
                case .settings:
                    SettingsView()
                case .stats:
                    StatsView()
                }
            }
        }
    }
}
