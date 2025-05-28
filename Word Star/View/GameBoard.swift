//
//  GameBoard.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel

    // 🌟 Константы визуала
    let starSize: CGFloat = 300
    let starRadius: CGFloat = 110
    let letterCircleSize: CGFloat = 60
    let letterFontSize: CGFloat = 24
    let swipeTouchRadius: CGFloat = 40

    // 📍 Координаты букв и выбранных точек
    @State private var starPoints: [(position: CGPoint, letter: Character)] = []
    @State private var selectedIndices: [Int] = []
    @State private var selectedPoints: [CGPoint] = []

    @State private var boxSize: CGSize = .zero
    @State private var lastIndex: Int? = nil
    
    @State private var lastSelectedIndex: Int? = nil
    @State private var lastFrameMiss = false // был ли отвод пальца

    var body: some View {
        VStack(spacing: 12) {
            // 🔠 Текущее слово
            Text(viewModel.getWord())
                .font(.system(size: 24))
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.6))
                .foregroundColor(.black) // 👈 Явно
                .clipShape(Capsule())

            // 📣 Результат
            Text(viewModel.result)
                .font(.system(size: 18))
                .foregroundColor(.black) // 👈 Явно
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            // 🌟 Звезда
            GeometryReader { geo in
                ZStack {
                    // 📏 Вычисление центра
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    let radius = starRadius

                    // 🔄 Обновим точки при изменении букв
                    Color.clear
                        .onAppear {
                            boxSize = geo.size
                            starPoints = computeStarPoints(from: viewModel.letters, center: center, radius: radius)
                        }
                        .onChange(of: viewModel.letters) { newLetters in
                            boxSize = geo.size
                            starPoints = computeStarPoints(from: newLetters, center: center, radius: radius)
                            starPoints = computeStarPoints(from: newLetters, center: center, radius: radius)
                        }

                    // 🟡 Линии свайпа
                    Path { path in
                        guard selectedPoints.count > 1 else { return }
                        for i in 0..<(selectedPoints.count - 1) {
                            path.move(to: selectedPoints[i])
                            path.addLine(to: selectedPoints[i + 1])
                        }
                    }
                    .stroke(Color.yellow, lineWidth: 6)

                    // 🔤 Буквы в звезде
                    ForEach(starPoints.indices, id: \.self) { index in
                        let point = starPoints[index].position
                        let letter = starPoints[index].letter
                        let isSelected = selectedIndices.contains(index)

                        Text(String(letter))
                            .font(.system(size: letterFontSize))
                            .frame(width: letterCircleSize, height: letterCircleSize)
                            .background(isSelected ? Color.yellow.opacity(0.7) : Color.white.opacity(0.6))
                            .foregroundColor(.black) // 👈 Явно
                            .clipShape(Circle())
                            .position(point)
                    }
                }
                .frame(width: starSize, height: starSize)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // 👉 Если свайп только начался — очищаем всё
                            if selectedPoints.isEmpty {
                                viewModel.clearSelection()         // 🧹 сбрасываем текущее слово
                                selectedIndices.removeAll()        // ❌ сбрасываем подсветку
                                selectedPoints.removeAll()         // ❌ очищаем путь
                                lastIndex = nil                    // ❌ сброс предыдущей буквы
                                lastFrameMiss = false              // ❌ сброс флага "промаха"

                                // 👆 Сразу проверим, попали ли по первой букве
                                if let index = checkTouched(at: value.location) {
                                    addLetter(index: index)        // ✅ добавляем букву и подсветку
                                }

                            } else {
                                // 🔁 Если уже свайпим — проверим, попали ли по новой (или прежней) букве
                                if let index = checkTouched(at: value.location) {
                                    // 💡 Разрешаем повторную букву только если:
                                    // 1. Это не та же буква подряд ИЛИ
                                    // 2. Была хотя бы одна "промашка" между
                                    if index != lastIndex || lastFrameMiss {
                                        addLetter(index: index)    // ✅ добавляем букву
                                    }
                                    lastFrameMiss = false          // 👉 Сброс флага промаха

                                } else {
                                    // 😵 Палец вышел за пределы — можно считать, что был "отвод"
                                    lastFrameMiss = true
                                }
                            }
                        }
                        .onEnded { _ in
                            // 🛑 Свайп завершён — проверяем слово
                            let word = viewModel.getWord()
                            viewModel.tryAddWord(word)            // ✅ проверка и обработка

                            // 🧹 Полный сброс состояния
                            viewModel.clearSelection()
                            selectedIndices.removeAll()
                            selectedPoints.removeAll()
                            lastIndex = nil
                            lastFrameMiss = false
                        }
                )
            }
            .frame(width: starSize, height: starSize)
        }
    }

    // 📐 Генерация координат звезды
    private func computeStarPoints(from letters: [Character], center: CGPoint, radius: CGFloat) -> [(CGPoint, Character)] {
        var points: [(CGPoint, Character)] = []
        for i in 0..<letters.count {
            let angleDeg = -90 + 144 * i
            let angleRad = CGFloat(angleDeg) * (.pi / 180)
            let x = center.x + cos(angleRad) * radius
            let y = center.y + sin(angleRad) * radius
            points.append((CGPoint(x: x, y: y), letters[i]))
        }
        return points
    }

    // ✅ Добавить букву по индексу
    private func addLetter(index: Int) {
        let (position, char) = starPoints[index]
        viewModel.addLetter(char)         // ➕ добавляем символ в модель
        selectedPoints.append(position)   // ➕ координата в путь
        selectedIndices.append(index)     // ➕ для подсветки
        lastIndex = index                 // 🔁 запоминаем индекс
        lastFrameMiss = false
    }

    // ✅ Проверка попадания в круг
    private func checkTouched(at location: CGPoint) -> Int? {
        for (index, pair) in starPoints.enumerated() {
            let distance = hypot(pair.position.x - location.x, pair.position.y - location.y)
            if distance <= swipeTouchRadius {
                return index
            }
        }
        return nil
    }
}
