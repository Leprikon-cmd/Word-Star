//
//  SettingsView.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var settings: SettingsManager

    @State private var showResetAlert = false

    var body: some View {
        ZStack {
            BackgroundManager()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    fontSelector
                    backgroundSelector
                    gameModeToggle
                    soundToggle
                    dictionarySelector
                    resetButton
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Сбросить все настройки?"),
                message: Text("Это действие нельзя отменить."),
                primaryButton: .destructive(Text("Сбросить")) {
                    settings.resetAll()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var header: some View {
        Text("⚙️ Настройки")
            .textStyle(size: 18)
            .font(.largeTitle)
            .padding(.top)
    }

    private var fontSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🖋️ Шрифт интерфейса")
                .textStyle(size: 18)

            Picker("Выбери шрифт", selection: $fontManager.selectedFontName) {
                ForEach(fontManager.availableFonts, id: \.self) { font in
                    Text(font)
                        .textStyle(size: 18)
                        .tag(font)
                }
            }
            .pickerStyle(MenuPickerStyle()) // 👈 Выпадающее меню
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
        }
    }

    private var backgroundSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🌅— Тут будет выбор фона —")
                .textStyle(size: 18)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
        }
    }

    private var gameModeToggle: some View {
        Toggle("🎮 Игровой режим (жизни, вызовы)", isOn: $settings.isGameModeEnabled)
            .textStyle(size: 18)
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
    }

    private var soundToggle: some View {
        Toggle("🔈 Звук", isOn: $settings.isSoundEnabled)
            .textStyle(size: 18)
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
    }

    private var dictionarySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📚 Словарь — Тут будет выбор словаря —")
                .textStyle(size: 18)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
        }
    }

    private var resetButton: some View {
        Button(action: {
            showResetAlert = true
        }) {
            Text("🧨 Сбросить настройки")
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
        }
    }
}
