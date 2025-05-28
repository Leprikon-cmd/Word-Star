//
//  DefinitionOverlay.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct DefinitionOverlay: View {
    let word: String
    var onClose: () -> Void

    var body: some View {
        ZStack {
            // 🕶️ Затемнённый фон
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // 📦 Основной блок
                VStack(alignment: .leading, spacing: 16) {
                    // ❌ Кнопка закрытия
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Text("✖")
                                .font(.title)
                        }
                    }

                    // 🔠 Заголовок — само слово
                    Text(word.uppercased())
                        .font(.title)
                        .bold()

                    // 📖 Определение
                    ScrollView {
                        Text(DictionaryManager.shared.getDefinition(for: word))
                            .font(.body)
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.95))
                .cornerRadius(12)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                .frame(maxHeight: UIScreen.main.bounds.height * 0.6)

                Spacer()
            }
        }
    }
}
