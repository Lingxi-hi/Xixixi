import SwiftUI

// MARK: - Pet display with animated state
struct PetAnimationView: View {
    let pet: Pet
    var size: CGFloat = 120
    var onTap: (() -> Void)? = nil

    @State private var isWiggling = false
    @State private var isJumping  = false
    @State private var showHearts = false

    var petEmoji: String {
        switch pet.mood {
        case .ecstatic, .happy: return pet.type.happyEmoji
        case .content:          return pet.type.idleEmoji
        case .sad, .unhappy:    return pet.type.sadEmoji
        }
    }

    var body: some View {
        ZStack {
            // Shadow
            Ellipse()
                .fill(Color.black.opacity(0.08))
                .frame(width: size * 0.8, height: size * 0.15)
                .offset(y: size * 0.48)

            // Pet emoji
            Text(petEmoji)
                .font(.system(size: size))
                .rotationEffect(.degrees(isWiggling ? 8 : -8))
                .offset(y: isJumping ? -20 : 0)
                .animation(
                    Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                    value: isWiggling
                )
                .animation(
                    Animation.spring(response: 0.4, dampingFraction: 0.5).repeatForever(autoreverses: true),
                    value: isJumping
                )

            // Floating hearts when happy
            if showHearts {
                ForEach(0..<3) { i in
                    FloatingHeartView()
                        .offset(x: CGFloat(i - 1) * 30, y: -size * 0.5)
                }
            }

            // Mood bubble
            moodBubble
                .offset(x: size * 0.45, y: -size * 0.45)
        }
        .onAppear {
            updateAnimations()
        }
        .onChange(of: pet.moodScore) { _ in
            updateAnimations()
        }
        .onTapGesture {
            withAnimation(.bouncy) {
                isJumping.toggle()
                showHearts = pet.moodScore >= 60
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showHearts = false
            }
            onTap?()
        }
    }

    private var moodBubble: some View {
        Text(pet.mood.emoji)
            .font(.system(size: 22))
            .padding(6)
            .background(Color.white.opacity(0.9))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func updateAnimations() {
        switch pet.mood {
        case .ecstatic:
            isWiggling = true
            isJumping  = true
        case .happy:
            isWiggling = true
            isJumping  = false
        case .content:
            isWiggling = false
            isJumping  = false
        case .sad, .unhappy:
            isWiggling = false
            isJumping  = false
        }
    }
}

// MARK: - Floating heart animation
struct FloatingHeartView: View {
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Text("💕")
            .font(.system(size: 16))
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    offsetY  = -40
                    opacity  = 0
                }
            }
    }
}

// MARK: - Weather Overlay
struct WeatherOverlayView: View {
    let weather: Weather

    var body: some View {
        if let particle = weather.particle {
            ZStack {
                ForEach(0..<12, id: \.self) { i in
                    WeatherParticle(symbol: particle, index: i)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

struct WeatherParticle: View {
    let symbol: String
    let index: Int

    @State private var offsetY: CGFloat = -40
    @State private var offsetX: CGFloat = 0

    var startX: CGFloat { CGFloat.random(in: -160...160) }

    var body: some View {
        Text(symbol)
            .font(.system(size: 12))
            .opacity(0.6)
            .offset(x: startX + offsetX, y: offsetY)
            .onAppear {
                let delay = Double(index) * 0.4
                withAnimation(
                    Animation.linear(duration: 2.5)
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    offsetY = 400
                    offsetX = CGFloat.random(in: -20...20)
                }
            }
    }
}
