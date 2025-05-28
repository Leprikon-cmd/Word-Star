//
//  StartView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct StartView: View {
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
                    // 🔘 Кнопка Играть
                    Button(action: {
                        onNavigate(.game)
                    }) {
                        Text("Играть")
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
    }
}
