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
                                let columns = [GridItem(.adaptive(minimum: 80), spacing: 12)]
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(viewModel.validWords.sorted(by: wordSort), id: \.self) { word in
                                        let isFound = viewModel.foundWords.contains(word)
                                        let display = isFound ? word : String(repeating: "✨", count: word.count)

                                        Text(display)
                                            .font(.system(size: 18))
                                            .foregroundColor(.black) // 👈 Явно
                                            .onTapGesture {
                                                if isFound {
                                                    selectedWord = word
                                                }
                                            }
                                            .frame(minWidth: 60)
                                    }
                                }
                                .padding()
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

    // 📥 Загрузка фонового изображения из ассетов
    private func loadBackground() {
        backgroundImage = Image("parchment") // добавь файл parchment.png в Assets
    }
}
