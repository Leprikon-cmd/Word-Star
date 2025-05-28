//
//  GameScreenView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct GameScreenView: View {
    let forceNewGame: Bool // 👈 добавили флаг
    // 🎮 ViewModel теперь инициализируется с флагом `forceNewGame`
    @StateObject private var viewModel: GameViewModel
    
    @State private var showWordList = false     // 📜 Оверлей со списком слов
    
    // 🧠 Новый init с параметром, определяющим, грузим ли прогресс
    init(forceNewGame: Bool) {
        _viewModel = StateObject(wrappedValue: {
            let logic = GameLogic()
            let dictionary = DictionaryManager.shared
            let generator = LetterSetGenerator(dictionary: dictionary)
            let vm = GameViewModel(dictionaryManager: dictionary, generator: generator, gameLogic: logic)
            
            if !forceNewGame, let saved = GameProgressManager.shared.loadProgress() {
                print("📦 Загружаем сохранёнку")
                logic.loadState(letters: saved.letters, foundWords: Set(saved.foundWords))
                vm.loadState(letters: saved.letters, foundWords: Set(saved.foundWords))
                vm.score = saved.score
                vm.level = saved.level
                vm.updateWords()
            } else {
                print("🆕 Новая игра")
                vm.startNewGame()
                GameProgressManager.shared.clearProgress()
            }

            return vm
        }())
        
        self.forceNewGame = forceNewGame
    }


    var body: some View {
        ZStack {
            // 🌄 Фон
            BackgroundManager()
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
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        Text("Очки: \(viewModel.score)")
                            .padding(6)
                            .background(Color.white.opacity(0.4))
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    // 🔄 Кнопка перезапуска
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
