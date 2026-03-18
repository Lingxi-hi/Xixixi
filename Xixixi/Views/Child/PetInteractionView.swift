import SwiftUI

// MARK: - Pet Interaction Sheet (宠物互动页)
struct PetInteractionView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    @State private var showHugEffect  = false
    @State private var showPetEffect  = false
    @State private var interactionMsg = ""

    var pet: Pet { store.pet }

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Pet large display
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [pet.mood.color.opacity(0.3), Color.clear],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 220, height: 220)

                            PetAnimationView(pet: pet, size: 140) {
                                handlePet()
                            }

                            if showHugEffect {
                                Text("🤗")
                                    .font(.system(size: 40))
                                    .transition(.scale.combined(with: .opacity))
                                    .offset(y: -80)
                            }
                        }
                        .padding(.top, 20)

                        // Mood description
                        VStack(spacing: 6) {
                            Text(pet.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color.xText)
                            Text(pet.mood.description)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(pet.mood.color)
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
                            StatusBarView(label: "饱食度", emoji: "🍖",
                                          value: pet.hunger,
                                          color: .orange)
                            StatusBarView(label: "饮水度", emoji: "💧",
                                          value: pet.thirst,
                                          color: .blue)
                            StatusBarView(label: "心情值", emoji: "💛",
                                          value: pet.moodScore,
                                          color: pet.mood.color)
                        }
                        .padding(16)
                        .cardStyle()
                        .padding(.horizontal, 20)

                        // Needs alerts
                        needsSection

                        // Interaction buttons
                        HStack(spacing: 16) {
                            interactionButton(emoji: "🤚", label: "摸摸") {
                                handlePet()
                            }
                            interactionButton(emoji: "🤗", label: "抱抱") {
                                handleHug()
                            }
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
                needsAlert(emoji: "🍖", message: "\(pet.name) 有点饿了，去商店买点吃的吧！", color: .orange)
            }
            if pet.needsWater {
                needsAlert(emoji: "💧", message: "\(pet.name) 口渴了，快喂点水吧！", color: .blue)
            }
            if pet.needsLove {
                needsAlert(emoji: "💛", message: "\(pet.name) 需要多一点爱！完成任务让它开心吧～", color: Color.xAccent)
            }
        }
        .padding(.horizontal, 20)
    }

    private func needsAlert(emoji: String, message: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(emoji).font(.system(size: 22))
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.xText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(color.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Interaction buttons
    private func interactionButton(emoji: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji).font(.system(size: 36))
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
        withAnimation(.bouncy) { showPetEffect = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showPetEffect = false
        }
    }

    private func handleHug() {
        store.hugPet()
        showMessage(["好温暖！", "抱抱最棒了！", "超级喜欢！", "开心！！"])
        withAnimation(.bouncy) { showHugEffect = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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

// MARK: - Scale button style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.bouncy, value: configuration.isPressed)
    }
}
