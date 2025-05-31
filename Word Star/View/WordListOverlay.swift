//
//  WordListOverlay.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//

import SwiftUI

// 📋 Оверлей для отображения списка слов (угаданных и скрытых)
struct WordListOverlay: View {
    @ObservedObject var viewModel: GameViewModel
    var onClose: () -> Void

    @State private var selectedWord: String? = nil
    @State private var backgroundImage: Image? = nil

    var body: some View {
        if let selected = selectedWord {
            // 📖 Показываем определение выбранного слова
            DefinitionOverlay(word: selected) {
                selectedWord = nil
            }
        } else {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    ZStack {
                        // 🧻 Фон — пергамент
                        backgroundImage?
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(12)

                        VStack(spacing: 12) {
                            // ❌ Кнопка закрытия
                            HStack {
                                Spacer()
                                Button("✖") {
                                    onClose()
                                }
                                .font(.title)
                                .padding()
                            }

                            // 🔤 Список слов
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(groupedWords(), id: \.self) { row in
                                        HStack(spacing: 10) {
                                            ForEach(row, id: \.self) { word in
                                                let isFound = viewModel.foundWords.contains(word)
                                                let shouldReveal = viewModel.isSurrendered || isFound
                                                let display = shouldReveal ? word : String(repeating: "🔲", count: word.count)

                                                Text(display)
                                                    .textStyle(size: 30)
                                                    .foregroundColor(.black)
                                                    .padding(8)
                                                    .background(shouldReveal ? Color.white.opacity(0) : Color.gray.opacity(0))
                                                    .cornerRadius(6)
                                                    .onTapGesture {
                                                        if shouldReveal {
                                                            selectedWord = word
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 100)
                            }

                            // 🟨 Сообщение если игрок сдался
                            if viewModel.isSurrendered {
                                Text("Вы сдались. Все слова раскрыты.")
                                    .textStyle(size: 18)
                                    .padding(10)
                                    .background(Color.yellow.opacity(0.8))
                                    .cornerRadius(10)
                                    .padding(.top, 8)
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.75)
                    .padding(.horizontal)
                }
            }
            .onAppear {
                loadBackground()
            }
        }
    }

    // 📥 Загрузка фона из ассетов
    private func loadBackground() {
        backgroundImage = Image("parchment")
    }

    // 📚 Сортируем слова: длинные сначала, внутри — по алфавиту
    private func wordSort(_ lhs: String, _ rhs: String) -> Bool {
        if lhs.count != rhs.count {
            return lhs.count > rhs.count
        }
        return lhs < rhs
    }

    // 🧱 Группируем слова в ряды (в зависимости от длины)
    private func groupedWords() -> [[String]] {
        let sorted = viewModel.validWords.sorted(by: wordSort)
        var rows: [[String]] = []
        var currentRow: [String] = []

        for word in sorted {
            let maxInRow: Int = {
                if word.count >= 6 { return 1 }
                else if word.count >= 4 { return 2 }
                else { return 3 }
            }()

            currentRow.append(word)

            if currentRow.count == maxInRow {
                rows.append(currentRow)
                currentRow = []
            }
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }
}
