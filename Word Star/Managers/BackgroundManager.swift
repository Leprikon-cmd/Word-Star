//
//  BackgroundManager.swift
//  Word Star
//
//  Created by Евгений Зотчик on 28.05.2025.
//
import SwiftUI

struct BackgroundManager: View {
    @ObservedObject private var controller = BackgroundManagerController.shared
    @State private var imageName: String = "Background1"
    
    var body: some View {
        GeometryReader { geo in
            Image(imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.2) // ← увеличивает изображение
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .ignoresSafeArea()
                .onAppear {
                                    imageName = pickRandomImage()
                                }
                                .onChange(of: controller.reloadID) { _ in
                                    imageName = pickRandomImage()
                                }
                        }
                    }

                    private func pickRandomImage() -> String {
                        let index = Int.random(in: 1...62)
                        return "Background\(index)"
                    }
                }

                // 👇 Контроллер в том же файле, но вне структуры
class BackgroundManagerController: ObservableObject {
    static let shared = BackgroundManagerController()
    
    @Published var reloadID = UUID()
    
    func reload() {
        reloadID = UUID()
    }
    
    private init() {}
}
