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
                
                if viewModel.postWinMode != .normal && !viewModel.isSurrendered {
                    Button("😵 Сдаюсь") {
                        viewModel.isSurrendered = true
                    }
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                if viewModel.isSurrendered {
                    Text("Вы сдались. Все слова раскрыты.")
                        .font(.headline)
                        .padding(8)
                        .background(Color.yellow.opacity(0.9))
                        .cornerRadius(10)
                }

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
            // 🎉 Победа
            if viewModel.showWinDialog {
                VStack {
                    Text("🎉 Победа!")
                        .font(.title)
                        .padding()
                    Text("Вы прошли уровень!")
                    Button("ОК") {
                        viewModel.showWinDialog = false
                        viewModel.isLevelPassed = true // 👈 после подтверждения — включаем меню режимов
                    }
                    .padding(.top)
                }
                .frame(maxWidth: 300)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
            
            // 🎯 Выбор режима после прохождения уровня
            if viewModel.isLevelPassed && !viewModel.showWinDialog {
                VStack(spacing: 16) {
                    Text("🌟 Уровень пройден!")
                        .font(.title)
                        .padding(.bottom)

                    Text("Выберите режим для продолжения:")
                        .font(.headline)

                    Button("🔍 Исследователь (без штрафов)") {
                        viewModel.postWinMode = .explorer
                        viewModel.isLevelPassed = false
                    }
                    .padding()
                    .frame(maxWidth: 260)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button("🎯 Вызов (с бонусами)") {
                        viewModel.postWinMode = .challenge
                        viewModel.isLevelPassed = false
                    }
                    .padding()
                    .frame(maxWidth: 260)
                    .background(Color.orange.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button("🆕 Новая игра") {
                        viewModel.startNewGame()
                        BackgroundManagerController.shared.reload()
                        viewModel.isLevelPassed = false // 👈 сбрасываем
                    }
                    .padding()
                    .frame(maxWidth: 260)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding(.horizontal)
            }
        }
    }
}
