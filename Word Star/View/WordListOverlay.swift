//
//  WordListOverlay.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct WordListOverlay: View {
    @ObservedObject var viewModel: GameViewModel
    var onClose: () -> Void

    @State private var selectedWord: String? = nil
    @State private var backgroundImage: Image? = nil

    var body: some View {
        if let selected = selectedWord {
            DefinitionOverlay(word: selected, onClose: {
                selectedWord = nil
            })
        } else {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    ZStack {
                        // 🧻 Фон-пергамент (должен быть в Assets как "parchment")
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

                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(groupedWords(), id: \.self) { row in
                                        HStack(spacing: 12) {
                                            ForEach(row, id: \.self) { word in
                                                let isFound = viewModel.foundWords.contains(word)
                                                let display = isFound ? word : String(repeating: "🔲", count: word.count)

                                                Text(display)
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.black)
                                                    .onTapGesture {
                                                        if isFound {
                                                            selectedWord = word
                                                        }
                                                    }
                                                    .frame(minWidth:60)
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 100) // 👈 Вот сюда — увеличь при необходимости
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

    // 📜 Сортировка: по убыванию длины, затем по алфавиту
    private func wordSort(_ lhs: String, _ rhs: String) -> Bool {
        if lhs.count != rhs.count {
            return lhs.count > rhs.count
        }
        return lhs < rhs
    }
    
    private func groupedWords() -> [[String]] {
        let sorted = viewModel.validWords.sorted(by: wordSort)
        var rows: [[String]] = []
        var currentRow: [String] = []

        for word in sorted {
            let length = word.count

            let maxInRow: Int = {
                if length >= 6 { return 1 }
                else if length >= 4 { return 2 }
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

    // 📥 Загрузка фонового изображения из ассетов
    private func loadBackground() {
        backgroundImage = Image("parchment") // добавь файл parchment.png в Assets
    }
}
