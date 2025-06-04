//
//  FoundWordsView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 01.06.2025.
//
import SwiftUI  // 🧠 Не забываем импорт!

struct FoundWordsView: View {
    @EnvironmentObject var stats: StatsManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(stats.foundWords.sorted(by: { $0.key < $1.key }), id: \.key) { word, count in
                HStack {
                    Text(word)
                    Spacer()
                    Text("×\(count)")
                        .foregroundColor(.secondary)
                }
                .textStyle(size: 18)
            }
        }
        .navigationTitle("Угаданные слова")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Назад") {
                    dismiss()
                }
            }
        }
    }
}
