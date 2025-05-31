//
//  FontManager.swift
//  Word Star
//
//  Created by Евгений Зотчик on 30.05.2025.
//
import SwiftUI

extension View {
    /// Универсальный стиль текста, автоматически берёт нужные зависимости из Environment
    func textStyle(size: CGFloat, customColor: Color? = nil) -> some View {
        modifier(AutoTextStyle(size: size, customColor: customColor))
    }
}

private struct AutoTextStyle: ViewModifier {
    let size: CGFloat
    let customColor: Color?
    @EnvironmentObject var fontManager: FontManager

    func body(content: Content) -> some View {
        content
            .font(fontManager.font(size: size))
            .offset(fontManager.offset(for: fontManager.selectedFontName)) // добавляем сдвиг
    }
}

extension View {
    /// Универсальный стиль: шрифт из настроек, цвет — кастомный (независимо от выбора игрока)
    func textStyle(size: CGFloat, color: Color) -> some View {
        modifier(FixedTextStyle(size: size, color: color))
    }
}

private struct FixedTextStyle: ViewModifier {
    let size: CGFloat
    let color: Color
    @EnvironmentObject var fontManager: FontManager

    func body(content: Content) -> some View {
        content
            .font(fontManager.font(size: size)) // ✅ шрифт — из настроек
            .foregroundColor(color)              // ✅ цвет — передаём вручную
    }
}

class FontManager: ObservableObject {
    static let shared = FontManager()

    @AppStorage("selectedFont") private var storedFont: String = "System"
    
    // ✅ Публичное Published-свойство
    @Published var selectedFontName: String = "System" {
        didSet {
            storedFont = selectedFontName
        }
    }

    // Инициализация значения при запуске
    private init() {
        selectedFontName = storedFont
    }

    // + Список доступных шрифтов
    let availableFonts: [String] = [
        "System",
        "Pacifico",
        "CormorantGaramond",
        "OldStandard",
        "RuslanDisplay",
        "GreatVibes"
    ]

    // Сам шрифт по имени
    func font(size: CGFloat) -> Font {
        switch selectedFontName {
        case "Pacifico":
            return Font.custom("Pacifico-Regular", size: size)
        case "CormorantGaramond":
            return Font.custom("CormorantGaramond-Regular", size: size) // ✅
        case "OldStandard":
            return Font.custom("OldStandardTT-Regular", size: size)
        case "RuslanDisplay":
            return Font.custom("RuslanDisplay", size: size) // ✅
        case "GreatVibes":
            return Font.custom("GreatVibes-Regular", size: size)
        default:
            return Font.system(size: size)
        }
    }

    func offset(for font: String) -> CGSize {
        switch font {
        case "Pacifico": return CGSize(width: 0, height: -3)
        case "OldStandard": return CGSize(width: 0, height: 2)
        case "RuslanDisplay": return CGSize(width: 0, height: 4)
        case "CormorantGaramond": return CGSize(width: 0, height: -3)
        default: return .zero
        }
    }
}
