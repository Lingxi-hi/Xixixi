import SwiftUI

// MARK: - Pet Interaction Sheet
struct PetInteractionView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    @State private var showHugEffect  = false
    @State private var interactionMsg = ""

    var pet: Pet { store.pet }

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Pet display
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [pet.mood.color.opacity(0.28), .clear],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 110
                                    )
                                )
                                .frame(width: 230, height: 230)

                            PetAnimationView(pet: pet, size: 140) {
                                handlePet()
                            }

                            if showHugEffect {
                                Image(systemName: "figure.wave.circle.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(Color.xAccent)
                                    .transition(.scale.combined(with: .opacity))
                                    .offset(y: -88)
                            }
                        }
                        .padding(.top, 20)

                        // Name + mood
                        VStack(spacing: 6) {
                            Text(pet.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color.xText)
                            HStack(spacing: 6) {
                                Image(systemName: pet.mood.sfSymbol)
                                    .foregroundStyle(pet.mood.color)
                                Text(pet.mood.description)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(pet.mood.color)
                            }
                        }

                        // Interaction message
                        if !interactionMsg.isEmpty {
                            Text(interactionMsg)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.xAccent)
                                .clipShape(Capsule())
                                .transition(.scale.combined(with: .opacity))
                        }

                        // Status bars
                        VStack(spacing: 12) {
                            StatusBarView(label: "饱食度", sfSymbol: "fork.knife",
                                          symbolColor: .orange, value: pet.hunger)
                            StatusBarView(label: "饮水度", sfSymbol: "drop.fill",
                                          symbolColor: .blue,   value: pet.thirst)
                            StatusBarView(label: "心情值", sfSymbol: pet.mood.sfSymbol,
                                          symbolColor: pet.mood.color, value: pet.moodScore)
                        }
                        .padding(16)
                        .cardStyle()
                        .padding(.horizontal, 20)

                        // Needs alerts
                        needsSection

                        // Interaction buttons
                        HStack(spacing: 16) {
                            interactionButton(symbol: "hand.raised.fill",
                                              color: Color.xPrimary,
                                              label: "摸摸") { handlePet() }
                            interactionButton(symbol: "figure.wave",
                                              color: Color.xAccent,
                                              label: "抱抱") { handleHug() }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("\(pet.name) 的状态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.xPrimary)
                }
            }
        }
    }

    // MARK: - Needs alerts
    private var needsSection: some View {
        VStack(spacing: 8) {
            if pet.needsFood {
                needsAlert(symbol: "fork.knife", color: .orange,
                           message: "\(pet.name) 有点饿了，去商店买点吃的吧！")
            }
            if pet.needsWater {
                needsAlert(symbol: "drop.fill", color: .blue,
                           message: "\(pet.name) 口渴了，快喂点水吧！")
            }
            if pet.needsLove {
                needsAlert(symbol: "heart.fill", color: Color.xAccent,
                           message: "\(pet.name) 需要多一点爱！完成任务让它开心吧～")
            }
        }
        .padding(.horizontal, 20)
    }

    private func needsAlert(symbol: String, color: Color, message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 28)
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.xText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(color.opacity(0.28), lineWidth: 1))
    }

    // MARK: - Interaction buttons
    private func interactionButton(symbol: String, color: Color, label: String,
                                   action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 32))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .cardStyle()
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Actions
    private func handlePet() {
        store.petThePet()
        showMessage(["好舒服～", "摸摸真好！", "咕噜咕噜～", "喜欢～"])
    }

    private func handleHug() {
        store.hugPet()
        showMessage(["好温暖！", "抱抱最棒了！", "超级喜欢！", "开心！！"])
        withAnimation(.bouncy) { showHugEffect = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation { showHugEffect = false }
        }
    }

    private func showMessage(_ messages: [String]) {
        interactionMsg = messages.randomElement() ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { interactionMsg = "" }
        }
    }
}
