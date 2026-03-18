import SwiftUI

// MARK: - Coin Badge
struct CoinBadgeView: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 5) {
            CoinIcon(size: 18)
            Text("\(coins)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.xCoin.opacity(0.22))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.xCoin, lineWidth: 1.5))
    }
}

// MARK: - Reusable coin icon (SF Symbol based, no emoji)
struct CoinIcon: View {
    var size: CGFloat = 18

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.xCoin)
                .frame(width: size, height: size)
            Text("¥")
                .font(.system(size: size * 0.52, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Floating coin animation
struct CoinFlyView: View {
    let delta: Int
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double  = 1

    var body: some View {
        HStack(spacing: 4) {
            Text("+\(delta)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.xCoin)
            CoinIcon(size: 20)
        }
        .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
        .offset(y: offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                offsetY = -65
                opacity = 0
            }
        }
    }
}

// MARK: - Status Bar (hunger / thirst / mood)
struct StatusBarView: View {
    let label: String
    let sfSymbol: String
    let symbolColor: Color
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: sfSymbol)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(symbolColor)
                    .frame(width: 16)
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
                        .fill(symbolColor.opacity(0.18))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(symbolColor)
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                        .animation(.gentle, value: value)
                }
            }
            .frame(height: 8)
        }
    }
}
