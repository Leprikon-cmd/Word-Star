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
            BackgroundManager() // Фон
                .ignoresSafeArea()
            
            
            VStack(spacing: 20) {
                Text("🌟 Word Star")
                    .font(.largeTitle)
                
                Button("Играть") {
                    onNavigate(.game)
                }
                
                Button("Настройки") {
                    onNavigate(.settings)
                }
                
                Button("Статистика") {
                    onNavigate(.stats)
                }
            }
            .padding()
        }
    }
}
