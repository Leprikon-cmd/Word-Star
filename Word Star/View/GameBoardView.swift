//
//  GameBoard.swift
//  Word Star
//
//  Created by ChatGPT & Евгений Зотчик on 28.05.2025.
//

import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel

    // 🌟 Константы визуала
    let starSize: CGFloat = 340
    let starRadius: CGFloat = 130
    let letterCircleSize: CGFloat = 60
    let letterFontSize: CGFloat = 40
    let swipeTouchRadius: CGFloat = 40

    // 📍 Координаты букв и выбранных точек
    @State private var starPoints: [(position: CGPoint, letter: Character)] = []
    @State private var selectedIndices: [Int] = []
    @State private var selectedPoints: [CGPoint] = []

    @State private var boxSize: CGSize = .zero
    @State private var lastIndex: Int? = nil
    @State private var lastSelectedIndex: Int? = nil
    @State private var lastFrameMiss = false // был ли отвод пальца
    @State private var currentDragPoint: CGPoint? = nil // 📍 текущая точка пальца
    @State private var sparkPoints: [CGPoint] = [] // искры

    var body: some View {
        VStack(spacing: 12) {
            // 🔠 Текущее слово
            Text(viewModel.getWord())
                .textStyle(size: 35)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.3))
                .foregroundColor(.black)
                .clipShape(Capsule())

            // 📣 Результат
            Text(viewModel.result)
                .textStyle(size: 30)
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            // 🌟 Звезда с буквами и свайпом
            GeometryReader { geo in
                ZStack {
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                    // 🔄 Перерасчёт координат при появлении и смене букв
                    Color.clear
                        .onAppear {
                            boxSize = geo.size
                            starPoints = computeStarPoints(from: viewModel.letters, center: center, radius: starRadius)
                        }
                        .onChange(of: viewModel.letters) { newLetters in
                            boxSize = geo.size
                            starPoints = computeStarPoints(from: newLetters, center: center, radius: starRadius)
                        }

                    // ✨ Искры по пути свайпа — до линии, чтобы были под ней
                    Canvas { context, size in
                        for (i, point) in sparkPoints.enumerated() {
                            let opacity = Double(i) / Double(sparkPoints.count)
                            var circle = Path()
                            circle.addEllipse(in: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6))
                            context.fill(circle, with: .color(.yellow.opacity(opacity)))
                        }
                    }
                    .frame(width: starSize, height: starSize)
                    .drawingGroup()

                    // ✨ Магическая линия свайпа
                    MagicSwipePath(points: selectedPoints, trailingPoint: currentDragPoint)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.9), Color.orange.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                        )
                        .blur(radius: 1.5)
                        .shadow(color: .yellow.opacity(0.6), radius: 5)
                        .shadow(color: .orange.opacity(0.3), radius: 10)

                    // 🔤 Буквы в звезде
                    ForEach(starPoints.indices, id: \.self) { index in
                        let point = starPoints[index].position
                        let letter = starPoints[index].letter
                        let isSelected = selectedIndices.contains(index)

                        Text(String(letter))
                            .textStyle(size: 40)
                            .frame(width: letterCircleSize, height: letterCircleSize)
                            .background(isSelected ? Color.yellow.opacity(0.7) : Color.white.opacity(0.6))
                            .foregroundColor(.black)
                            .clipShape(Circle())
                            .position(point)
                    }
                }
                
                .frame(width: starSize, height: starSize)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !viewModel.isSurrendered else { return }

                            if selectedPoints.isEmpty {
                                viewModel.clearSelection()
                                selectedIndices.removeAll()
                                selectedPoints.removeAll()
                                lastIndex = nil
                                lastFrameMiss = false
                                // ✨ Добавляем точку для искр
                                sparkPoints.append(value.location)
                                if sparkPoints.count > 20 {
                                    sparkPoints.removeFirst()
                                }

                                if let index = checkTouched(at: value.location) {
                                    addLetter(index: index)
                                    currentDragPoint = starPoints[index].position
                                } else {
                                    currentDragPoint = value.location
                                    // ✨ Добавляем точку для искр
                                    sparkPoints.append(value.location)
                                    if sparkPoints.count > 20 {
                                        sparkPoints.removeFirst()
                                    }
                                }

                            } else {
                                if let index = checkTouched(at: value.location) {
                                    if index != lastIndex || lastFrameMiss {
                                        addLetter(index: index)
                                    }
                                    lastFrameMiss = false
                                    currentDragPoint = starPoints[index].position // ✅ прилипаем

                                } else {
                                    lastFrameMiss = true
                                    currentDragPoint = value.location // 👉 свободное следование
                                }
                            }
                        }
                        .onEnded { _ in
                            let word = viewModel.getWord()
                            viewModel.tryAddWord(word)

                            viewModel.clearSelection()
                            selectedIndices.removeAll()
                            selectedPoints.removeAll()
                            lastIndex = nil
                            lastFrameMiss = false
                            currentDragPoint = nil // ✅
                            sparkPoints.removeAll()
                        }
                )
            }
            .frame(width: starSize, height: starSize)
        }
    }

    // 📐 Координаты букв по вершинам звезды
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

    // ➕ Добавление буквы
    private func addLetter(index: Int) {
        let (position, char) = starPoints[index]
        viewModel.addLetter(char)
        selectedPoints.append(position)
        selectedIndices.append(index)
        lastIndex = index
        lastFrameMiss = false
    }

    // 🔍 Проверка попадания по координате
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

// ✨ Кастомный путь для красивой кривой свайпа
struct MagicSwipePath: Shape {
    let points: [CGPoint]
    let trailingPoint: CGPoint?

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !points.isEmpty else { return path }

        path.move(to: points[0])

        for i in 1..<points.count {
            path.addLine(to: points[i])
        }

        // 🔚 Последняя линия — к пальцу (если есть)
        if let trailing = trailingPoint {
            path.addLine(to: trailing)
        }

        return path
    }
}
