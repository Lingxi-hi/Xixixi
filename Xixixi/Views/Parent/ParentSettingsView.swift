import SwiftUI

// MARK: - Parent Settings View
struct ParentSettingsView: View {
    @EnvironmentObject var store: GameStore

    @State private var petName:          String   = ""
    @State private var currentPassword:  String   = ""
    @State private var newPassword:      String   = ""
    @State private var confirmPassword:  String   = ""
    @State private var passwordError:    String?  = nil
    @State private var showSaveSuccess           = false
    @State private var showExitConfirm           = false
    @State private var petTypeSelection: PetType = .cat

    var body: some View {
        NavigationView {
            Form {
                // Pet
                Section("宠物设置") {
                    HStack {
                        Label("宠物名字", systemImage: "pencil")
                        Spacer()
                        TextField("小毛球", text: $petName)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color.xPrimary)
                    }

                    Picker("宠物类型", selection: $petTypeSelection) {
                        ForEach(PetType.allCases, id: \.self) { type in
                            Label {
                                Text(type.displayName)
                            } icon: {
                                Image(systemName: type.sfSymbol)
                            }
                            .tag(type)
                        }
                    }

                    Button(action: savePetSettings) {
                        Label("保存宠物设置", systemImage: "checkmark.circle")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.xPrimary)
                    }
                }

                // Sound
                Section("声音设置") {
                    Toggle(isOn: $store.soundEnabled) {
                        Label(
                            store.soundEnabled ? "游戏音效已开启" : "游戏音效已关闭",
                            systemImage: store.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"
                        )
                        .font(.system(size: 15, design: .rounded))
                    }
                    .tint(Color.xPrimary)
                }

                // Password
                Section("修改密码") {
                    SecureField("当前密码", text: $currentPassword)
                        .font(.system(size: 15, design: .rounded))
                    SecureField("新密码（4位数字）", text: $newPassword)
                        .font(.system(size: 15, design: .rounded))
                        .keyboardType(.numberPad)
                    SecureField("确认新密码", text: $confirmPassword)
                        .font(.system(size: 15, design: .rounded))
                        .keyboardType(.numberPad)
                    if let err = passwordError {
                        Label(err, systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color.xDanger)
                    }
                    Button(action: changePassword) {
                        Label("修改密码", systemImage: "lock.rotation")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.xDanger)
                    }
                }

                // Stats
                Section("数据信息") {
                    dataRow(label: "总获金币", value: "\(store.totalCoinsEarned)",
                            symbol: "circle.fill", color: Color.xCoin)
                    dataRow(label: "当前金币", value: "\(store.coins)",
                            symbol: "circle.fill", color: Color.xCoin)
                    dataRow(label: "历史记录", value: "\(store.taskHistory.count) 天",
                            symbol: "calendar", color: Color.xPrimary)
                    dataRow(label: "已解锁成就", value: "\(store.achievements.filter { $0.isUnlocked }.count) 个",
                            symbol: "trophy.fill", color: Color(red:1.0, green:0.78, blue:0.20))
                }

                // Exit
                Section {
                    Button(action: { showExitConfirm = true }) {
                        HStack {
                            Spacer()
                            Label("退出家长模式", systemImage: "arrow.uturn.left.circle.fill")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.xSubtext)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                petName = store.pet.name
                petTypeSelection = store.pet.type
            }
            .overlay(
                Group {
                    if showSaveSuccess {
                        Label("保存成功", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(Color.xSecondary)
                            .clipShape(Capsule())
                            .padding(.top, 20)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            )
            .confirmationDialog("退出家长模式？", isPresented: $showExitConfirm, titleVisibility: .visible) {
                Button("退出") { store.isParentMode = false }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private func dataRow(label: String, value: String, symbol: String, color: Color) -> some View {
        HStack {
            Label(label, systemImage: symbol)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color.xText)
                .labelStyle(.titleAndIcon)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
    }

    private func savePetSettings() {
        let trimmed = petName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.pet.name = trimmed
        store.pet.type = petTypeSelection
        store.saveState()
        withAnimation(.bouncy) { showSaveSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showSaveSuccess = false }
        }
    }

    private func changePassword() {
        passwordError = nil
        guard currentPassword == store.parentPassword else { passwordError = "当前密码不正确"; return }
        guard newPassword.count == 4, newPassword.allSatisfy({ $0.isNumber }) else {
            passwordError = "新密码必须是4位数字"; return
        }
        guard newPassword == confirmPassword else { passwordError = "两次输入的密码不一致"; return }
        store.parentPassword = newPassword
        store.saveState()
        currentPassword = ""; newPassword = ""; confirmPassword = ""
        withAnimation(.bouncy) { showSaveSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showSaveSuccess = false }
        }
    }
}
