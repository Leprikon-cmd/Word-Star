//
//  StartView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct StartView: View {
    
    @State private var hasSavedGame = false // начальное значение
    
    var onNavigate: (Screen) -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundManager()
                .ignoresSafeArea()
            
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
