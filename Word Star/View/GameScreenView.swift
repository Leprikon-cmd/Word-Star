//
//  GameScreenView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct GameScreenView: View {
    @StateObject private var viewModel = GameViewModel(
        dictionaryManager: DictionaryManager.shared,
        generator: LetterSetGenerator(dictionary: DictionaryManager.shared),
        gameLogic: GameLogic()
    )

    @State private var showWordList = false     // 📜 Оверлей со списком слов

    var body: some View {
        ZStack {
          
            BackgroundManager()   // 🌄 Фон
                .ignoresSafeArea()

            // 🎉 Победный алерт
            if viewModel.showWinDialog {
                VStack {
                    Text("🎉 Победа!")
                        .font(.title)
                        .padding()
                    Text("Вы нашли все слова на этом уровне!")
                    Button("ОК") {
                        viewModel.showWinDialog = false
                    }
                    .padding(.top)
                }
                .frame(maxWidth: 300)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 10)
            }

            // ✅❌ Символ результата
            if let symbol = viewModel.lastResultSymbol {
                VStack {
                    Spacer().frame(height: 150)
                    Text(symbol)
                        .font(.system(size: 48))
                        .foregroundColor(symbol == "✅" ? .green : .red)
                    Spacer()
                }
            }

            VStack {
                // 🔝 Верхняя панель
                HStack {
                    // 📜 Кнопка списка слов
                    Button(action: {
                        showWordList.toggle()
                    }) {
                        Text("📜")
                            .padding()
                            .background(Color.white.opacity(0.4))
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack(spacing: 6) {
                        Text("Найдено: \(viewModel.getFoundWordCount()) из \(viewModel.getTotalValidWordCount())")
                            .padding(6)
                            .background(Color.white.opacity(0.4))
                            .clipShape(Capsule())
                        Text("Очки: \(viewModel.score)")
                            .padding(6)
                            .background(Color.white.opacity(0.4))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    // 🔄 Кнопка перезапуска
                    Button(action: {
                        viewModel.resetGame()
                        BackgroundManagerController.shared.reload() // 💥 меняем фон!
                    }) {
                        Text("🔄")
                            .padding()
                            .background(Color.white.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                Spacer()

                // ⭐ Игровая звезда
                GameBoardView(viewModel: viewModel)
                    .padding(.bottom, 12)
            }

            // 📜 Список слов поверх
            if showWordList {
                WordListOverlay(viewModel: viewModel) {
                    showWordList = false
                }
            }
        }
    }
}
