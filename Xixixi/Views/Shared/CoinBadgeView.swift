import SwiftUI

// MARK: - Coin Badge (top-right display)
struct CoinBadgeView: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 4) {
            Text("🪙")
                .font(.system(size: 18))
            Text("\(coins)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.xCoin.opacity(0.25))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.xCoin, lineWidth: 1.5))
    }
}

// MARK: - Floating coin animation
struct CoinFlyView: View {
    let delta: Int
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Text("+\(delta) 🪙")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(Color.xCoin)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    offsetY = -60
                    opacity = 0
                }
            }
    }
}

// MARK: - Status Bar (hunger / thirst / mood)
struct StatusBarView: View {
    let label: String
    let emoji: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(emoji).font(.system(size: 14))
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.xSubtext)
                Spacer()
                Text("\(value)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                        .animation(.gentle, value: value)
                }
            }
            .frame(height: 8)
        }
    }
}
