import SwiftUI

extension Color {
    // Brand palette – warm & storybook-like
    static let xPrimary      = Color(red: 1.00, green: 0.76, blue: 0.45)  // warm orange
    static let xSecondary    = Color(red: 0.56, green: 0.86, blue: 0.68)  // mint green
    static let xAccent       = Color(red: 1.00, green: 0.55, blue: 0.65)  // soft pink
    static let xBackground   = Color(red: 1.00, green: 0.97, blue: 0.92)  // warm cream
    static let xCard         = Color(red: 1.00, green: 1.00, blue: 0.98)  // near white
    static let xText         = Color(red: 0.30, green: 0.22, blue: 0.18)  // warm brown
    static let xSubtext      = Color(red: 0.60, green: 0.52, blue: 0.48)  // muted brown
    static let xCoin         = Color(red: 1.00, green: 0.82, blue: 0.20)  // gold
    static let xDanger       = Color(red: 1.00, green: 0.44, blue: 0.44)  // soft red

    // Gradients
    static func skyGradient(_ season: Season) -> LinearGradient {
        LinearGradient(
            colors: season.skyGradient,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Rounded card style
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var shadow: Bool = true

    func body(content: Content) -> some View {
        content
            .background(Color.xCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(shadow ? 0.08 : 0), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 20, shadow: Bool = true) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, shadow: shadow))
    }
}

// MARK: - Scale press button style (shared across all views)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.bouncy, value: configuration.isPressed)
    }
}

// MARK: - Bounce animation
extension Animation {
    static var bouncy: Animation {
        .spring(response: 0.4, dampingFraction: 0.55, blendDuration: 0)
    }

    static var gentle: Animation {
        .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    }
}
