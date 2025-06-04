//
//  StatsView.swift
//  Word Star
//
//  Created by ChatGPT & Евгений Зотчик on 28.05.2025.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var stats: StatsManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var fontManager: FontManager
    
    @State private var showFoundWords = false
    
    var goToScreen: ((Screen) -> Void)?
    var body: some View {
        ZStack {
            BackgroundManager()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("📊 Статистика")
                        .textStyle(size: 18)
                        .bold()
                        .padding(.top)

                    totalWordsStats
                    Divider()
                    levelStats
                }
                .padding()
            }
        }
    }

    private var totalWordsStats: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🧠 Угаданные слова")
                .textStyle(size: 18)
                .bold()

            if stats.foundWords.isEmpty {
                Text("— Пока ничего не угадано")
                    .textStyle(size: 18)
            } else {
                Text("• Всего уникальных слов: \(stats.foundWords.count)")
                    .textStyle(size: 18)
                let totalAttempts = stats.foundWords.values.reduce(0, +)
                Text("• Всего попыток (включая повторы): \(totalAttempts)")
                    .textStyle(size: 18)
            }
        }
        .padding()
        .background(
            Image("parchment")
                .resizable()
                .scaledToFill()
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            if !stats.foundWords.isEmpty {
                showFoundWords = true
            }
        }
        .sheet(isPresented: $showFoundWords) {
            FoundWordsView()
                .environmentObject(stats)
        }
    }

    private var levelStats: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎮 Игры по уровням")
                .textStyle(size: 18)
                .bold()
            
            if stats.gameStats.isEmpty {
                Text("Пока нет завершённых игр.")
                    .textStyle(size: 18)
            } else {
                ForEach(stats.gameStats.keys.sorted(), id: \.self) { level in
                    VStack(alignment: .leading) {
                        Text("📈 Уровень \(level)")
                            .textStyle(size: 18)
                        
                        let modes = stats.gameStats[level]!
                        ForEach(PostWinMode.allCases, id: \.self) { mode in
                            if let data = modes[mode] {
                                Text("  • \(mode.label): сыграно \(data.total), побед \(data.wins)")
                                    .textStyle(size: 18)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            Image("parchment")
                .resizable()
                .scaledToFill()
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// 🔄 Расширяем enum, чтобы он стал и CaseIterable, и удобным для отображения
extension PostWinMode {
    var label: String {
        switch self {
        case .normal: return "Обычный"
        case .explorer: return "Исследователь"
        case .challenge: return "Вызов"
        }
    }
}
