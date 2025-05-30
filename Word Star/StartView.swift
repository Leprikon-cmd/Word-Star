//
//  StartView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct StartView: View {
    
    @State private var hasSavedGame = false // начальное значение
    @State private var showRulesAlert = false
    private var rulesText: String {
        """
        • Составляй слова любой длины из 5 букв
        • Можно использовать одну букву несколько раз: «мама», «папа» и т.п.
        • Ввод слов — свайп по буквам, не отпуская палец
        • Чтобы выбрать одну и ту же букву несколько раз подряд:
          — свайпни на неё, отведи палец в сторону и вернись
        • В верхнем левом углу — список всех возможных слов:
          угаданные открываются и можно тапнуть по ним, чтобы
          увидеть определение из словаря
        • Слова в списке отсортированы по длине и алфавиту — это подсказка

        • Уровень считается пройденным, если:
          — найдено хотя бы 1 слово из 5 букв
          — хотя бы 1 слово из 4 букв
          — и ещё минимум 3 любых слова

        ▶︎ После победы доступны два режима:
        • Исследователь:
          — можно продолжать искать слова без штрафов
          — очки за новые слова не начисляются

        • Вызов:
          — очки начисляются за каждое найденное слово
          — +5 очков за слово, +бонус за полное прохождение:
            (кол-во всех слов × 5)
          — за неправильные слова в будущем будут сниматься жизни

        • В обоих режимах доступна кнопка «Сдаюсь», чтобы открыть все оставшиеся слова
        """
    }
    
    var onNavigate: (Screen) -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundManager()
                .ignoresSafeArea()
            
                .alert(isPresented: $showRulesAlert) {
                    Alert(
                        title: Text("📖 Правила игры"),
                        message: Text(rulesText),
                        dismissButton: .default(Text("Понял"))
                    )
                }
            VStack {
                Spacer() // 🧼 Толкаем всё вниз
                
                Text("🌟 Word Star")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                VStack(spacing: 16) {
                    // 🔄 Кнопка "Продолжить игру", если есть сохранение
                    if hasSavedGame {
                        Button(action: {
                            onNavigate(.game(forceNewGame: false))
                        }) {
                            Text("Продолжить")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }

                    // 🆕 Кнопка "Играть сначала" (без сохранённого прогресса)
                    Button(action: {
                        onNavigate(.game(forceNewGame: true))
                    }) {
                        Text("Новая игра")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                    }
                    
                    // 🔧 Кнопка Настройки
                    Button(action: {
                        onNavigate(.settings)
                    }) {
                        Text("Настройки")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                    }
                    
                    // 📊 Кнопка Статистика
                    Button(action: {
                        onNavigate(.stats)
                    }) {
                        Text("Статистика")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                    }
                    // 📖 Кнопка Правила игры
                    Button(action: {
                        showRulesAlert = true
                    }) {
                        Text("📖 Правила")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                    }
                    .alert(isPresented: $showRulesAlert) {
                        Alert(
                            title: Text("📖 Правила игры"),
                            message: Text(rulesText),
                            dismissButton: .default(Text("Ок"))
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer() // 👇 Чуть-чуть отступ снизу
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            // 🔁 Проверяем каждый раз, когда экран появляется
            hasSavedGame = GameProgressManager.shared.loadProgress() != nil
        }
    }
}
