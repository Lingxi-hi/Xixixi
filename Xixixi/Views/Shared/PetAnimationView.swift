import SwiftUI

// MARK: - Pet display with SF Symbol + animations
struct PetAnimationView: View {
    let pet: Pet
    var size: CGFloat = 120
    var onTap: (() -> Void)? = nil

    @State private var isWiggling  = false
    @State private var isJumping   = false
    @State private var showHearts  = false
    @State private var wiggleDeg: Double = 0
    @State private var jumpOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Ground shadow
            Ellipse()
                .fill(Color.black.opacity(0.08))
                .frame(width: size * 0.75, height: size * 0.12)
                .offset(y: size * 0.50)

            // Mood glow background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [pet.mood.color.opacity(0.28), .clear],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius:  size * 0.65
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)

            // Pet SF Symbol
            Image(systemName: pet.type.sfSymbol)
                .resizable()
                .scaledToFit()
                .foregroundStyle(pet.type.bodyColor)
                .frame(width: size * 0.72, height: size * 0.72)
                .rotationEffect(.degrees(wiggleDeg))
                .offset(y: jumpOffset)

            // Mood indicator bubble
            moodBubble
                .offset(x: size * 0.42, y: -size * 0.42)

            // Floating hearts (tap feedback)
            if showHearts {
                ForEach(0..<3, id: \.self) { i in
                    FloatingHeartView()
                        .offset(x: CGFloat(i - 1) * 28, y: -size * 0.48)
                }
            }
        }
        .onAppear { startAnimations() }
        .onChange(of: pet.moodScore) { _ in startAnimations() }
        .onTapGesture {
            triggerTapBounce()
            onTap?()
        }
    }

    // MARK: - Mood bubble
    private var moodBubble: some View {
        Image(systemName: pet.mood.sfSymbol)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(pet.mood.color)
            .padding(7)
            .background(.white.opacity(0.92))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 2)
    }

    // MARK: - Animations
    private func startAnimations() {
        switch pet.mood {
        case .ecstatic:
            startWiggle(amplitude: 9, duration: 0.45)
            startJump(height: 16, duration: 0.5)
        case .happy:
            startWiggle(amplitude: 6, duration: 0.55)
            stopJump()
        case .content:
            startWiggle(amplitude: 3, duration: 0.80)
            stopJump()
        case .sad, .unhappy:
            stopWiggle()
            stopJump()
        }
    }

    private func startWiggle(amplitude: Double, duration: Double) {
        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            wiggleDeg = amplitude
        }
    }

    private func stopWiggle() {
        withAnimation(.easeOut(duration: 0.3)) { wiggleDeg = 0 }
    }

    private func startJump(height: CGFloat, duration: Double) {
        withAnimation(Animation.spring(response: duration, dampingFraction: 0.45)
            .repeatForever(autoreverses: true)) {
            jumpOffset = -height
        }
    }

    private func stopJump() {
        withAnimation(.easeOut(duration: 0.25)) { jumpOffset = 0 }
    }

    private func triggerTapBounce() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
            jumpOffset = -22
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                jumpOffset = 0
            }
        }
        if pet.moodScore >= 60 {
            showHearts = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showHearts = false
            }
        }
    }
}

// MARK: - Floating heart (uses SF Symbol, no emoji)
struct FloatingHeartView: View {
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double  = 1

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 14))
            .foregroundStyle(Color(red: 1.0, green: 0.45, blue: 0.60))
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.1)) {
                    offsetY = -42
                    opacity = 0
                }
            }
    }
}

// MARK: - Weather Overlay (particles use SF Symbols)
struct WeatherOverlayView: View {
    let weather: Weather

    var body: some View {
        if let symbol = weather.particleSymbol {
            ZStack {
                ForEach(0..<10, id: \.self) { i in
                    WeatherParticle(symbol: symbol, index: i,
                                    color: weather.symbolColor)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

struct WeatherParticle: View {
    let symbol: String
    let index: Int
    let color: Color

    @State private var offsetY: CGFloat = -40
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double  = 0.55

    private var startX: CGFloat { CGFloat(index) * 34 - 170 }

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 10))
            .foregroundStyle(color)
            .offset(x: startX + offsetX, y: offsetY)
            .opacity(opacity)
            .onAppear {
                let delay = Double(index) * 0.38
                withAnimation(
                    Animation.linear(duration: 2.6)
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    offsetY  = 420
                    offsetX  = CGFloat.random(in: -18...18)
                    opacity  = 0
                }
            }
    }
}
