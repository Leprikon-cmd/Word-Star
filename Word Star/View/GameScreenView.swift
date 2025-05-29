//
//  GameScreenView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

// 📺 Главный игровой экран
struct GameScreenView: View {
    let forceNewGame: Bool                             // 🧨 Флаг — начать заново или загрузить прогресс
    @StateObject private var viewModel: GameViewModel  // 🎮 ViewModel игры
    @State private var showWordList = false            // 📜 Список слов

    // 🧠 Конструктор с логикой инициализации прогресса или новой игры
    init(forceNewGame: Bool) {
        _viewModel = StateObject(wrappedValue: {
            let dict = DictionaryManager.shared
            let generator = LetterSetGenerator(dictionary: dict)

            if forceNewGame || GameProgressManager.shared.loadProgress() == nil {
                print("🆕 Новая игра")
                let logic = GameLogic()
                let vm = GameViewModel(dictionaryManager: dict, generator: generator, gameLogic: logic)
                vm.startNewGame()
                GameProgressManager.shared.clearProgress()
                return vm
            } else {
                print("📦 Продолжаем игру из сохранёнки")
                let (logic, vm) = GameProgressManager.shared.restoreGame(dictionary: dict, generator: generator)!
                return vm
            }
        }())

        self.forceNewGame = forceNewGame
    }

    var body: some View {
        ZStack {
            // 🌄 Фон
            BackgroundManager()
                .ignoresSafeArea()

            // 🎉 Победа
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
                    // 📜 Список слов
                    Button(action: { showWordList.toggle() }) {
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
                            .foregroundColor(.black)
                            .clipShape(Capsule())

                        Text("Очки: \(viewModel.score)")
                            .padding(6)
                            .background(Color.white.opacity(0.4))
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    // 🔄 Перезапуск
                    Button(action: {
                        viewModel.resetGame()
                        BackgroundManagerController.shared.reload()
                    }) {
                        Text("🔄")
                            .padding()
                            .background(Color.white.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                Spacer()

                // ⭐ Звезда
                GameBoardView(viewModel: viewModel)
                    .padding(.bottom, 12)
            }

            // 📜 Оверлей со словами
            if showWordList {
                WordListOverlay(viewModel: viewModel) {
                    showWordList = false
                }
            }
        }
    }
}
