import SwiftUI

// MARK: - Parent Unlock (密码 / Face ID 入口)
struct ParentUnlockView: View {
    @EnvironmentObject var store: GameStore
    @Binding var isShowing: Bool

    @State private var enteredPin: String = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var showWrongPin = false

    private let pinLength = 4

    var body: some View {
        ZStack {
            Color.xBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 54))
                        .foregroundColor(Color.xPrimary)

                    Text("家长专区")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color.xText)

                    Text("请输入密码进入")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
                .padding(.top, 60)

                // PIN dots
                HStack(spacing: 18) {
                    ForEach(0..<pinLength, id: \.self) { i in
                        Circle()
                            .fill(i < enteredPin.count ? Color.xPrimary : Color.gray.opacity(0.3))
                            .frame(width: 18, height: 18)
                            .animation(.bouncy, value: enteredPin.count)
                    }
                }
                .offset(x: shakeOffset)

                // Wrong PIN message
                if showWrongPin {
                    Text("密码不对哦，再试试 😅")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.xDanger)
                        .transition(.opacity)
                }

                // Numpad
                numpad
                    .padding(.horizontal, 40)

                // Cancel
                Button("返回") { isShowing = false }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xSubtext)
                    .padding(.bottom, 40)

                Spacer()
            }
        }
    }

    // MARK: - Numpad
    private var numpad: some View {
        let rows: [[String]] = [
            ["1","2","3"],
            ["4","5","6"],
            ["7","8","9"],
            ["","0","⌫"]
        ]

        return VStack(spacing: 14) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 14) {
                    ForEach(row, id: \.self) { key in
                        numpadKey(key)
                    }
                }
            }
        }
    }

    private func numpadKey(_ key: String) -> some View {
        Button(action: { handleKey(key) }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(key.isEmpty ? Color.clear : Color.xCard)
                    .shadow(color: .black.opacity(key.isEmpty ? 0 : 0.07), radius: 4, x: 0, y: 2)
                if !key.isEmpty {
                    Text(key)
                        .font(.system(size: key == "⌫" ? 20 : 22, weight: .semibold, design: .rounded))
                        .foregroundColor(key == "⌫" ? Color.xDanger : Color.xText)
                }
            }
            .frame(height: 64)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(key.isEmpty)
    }

    // MARK: - Key handling
    private func handleKey(_ key: String) {
        if key == "⌫" {
            if !enteredPin.isEmpty { enteredPin.removeLast() }
            withAnimation { showWrongPin = false }
            return
        }

        guard enteredPin.count < pinLength else { return }
        enteredPin.append(key)

        if enteredPin.count == pinLength {
            validatePin()
        }
    }

    private func validatePin() {
        if enteredPin == store.parentPassword {
            store.isParentMode = true
            isShowing = false
        } else {
            withAnimation(.bouncy) {
                shakeOffset = 10
                showWrongPin = true
            }
            withAnimation(.bouncy.delay(0.1)) { shakeOffset = -10 }
            withAnimation(.bouncy.delay(0.2)) { shakeOffset = 8 }
            withAnimation(.bouncy.delay(0.3)) { shakeOffset = 0 }
            enteredPin = ""
        }
    }
}
