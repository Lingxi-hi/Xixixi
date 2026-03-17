import SwiftUI

// MARK: - Red Line View (红线管理)
struct RedLineView: View {
    @EnvironmentObject var store: GameStore

    @State private var showAddRedLine = false
    @State private var triggeringRedLine: RedLine? = nil
    @State private var showTriggerConfirm = false
    @State private var showFeedback = false
    @State private var feedbackMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                List {
                    // Info section
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("红线行为")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.xText)
                                Text("触发时扣除金币，最多设置3条，最少扣到0")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(Color.xSubtext)
                            }
                        }
                        .listRowBackground(Color.orange.opacity(0.08))
                    }

                    // Red lines
                    Section("当前红线（\(store.redLines.count)/3）") {
                        if store.redLines.isEmpty {
                            Text("暂未设置红线行为")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color.xSubtext)
                                .listRowBackground(Color.xCard)
                        }
                        ForEach(store.redLines) { redLine in
                            RedLineRow(redLine: redLine) {
                                triggeringRedLine = redLine
                                showTriggerConfirm = true
                            }
                            .listRowBackground(Color.xCard)
                        }
                        .onDelete { store.removeRedLine(at: $0) }
                    }

                    // Templates section
                    Section("模板（点击快速添加）") {
                        ForEach(RedLine.templates) { template in
                            let alreadyAdded = store.redLines.contains { $0.title == template.title }
                            Button(action: { addFromTemplate(template) }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(template.title)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(alreadyAdded ? Color.xSubtext : Color.xText)
                                        Text("扣 \(template.penalty) 🪙")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Color.xDanger)
                                    }
                                    Spacer()
                                    if alreadyAdded {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.xSecondary)
                                    } else {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(store.redLines.count >= 3 ? Color.gray : Color.xPrimary)
                                    }
                                }
                            }
                            .disabled(alreadyAdded || store.redLines.count >= 3)
                            .listRowBackground(Color.xCard)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)

                // Trigger feedback
                if showFeedback {
                    VStack {
                        Text(feedbackMessage)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .clipShape(Capsule())
                            .transition(.move(edge: .top).combined(with: .opacity))
                        Spacer()
                    }
                    .padding(.top, 20)
                    .allowsHitTesting(false)
                }
            }
            .navigationTitle("🚨 红线设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddRedLine = true }) {
                        Label("添加", systemImage: "plus.circle.fill")
                    }
                    .disabled(store.redLines.count >= 3)
                    .foregroundColor(store.redLines.count >= 3 ? Color.gray : Color.xDanger)
                }
            }
            .sheet(isPresented: $showAddRedLine) {
                RedLineEditSheet { newRedLine in
                    store.addRedLine(newRedLine)
                }
            }
            .confirmationDialog(
                triggeringRedLine.map { "触发红线：\($0.title)，扣除 \($0.penalty) 金币" } ?? "",
                isPresented: $showTriggerConfirm,
                titleVisibility: .visible
            ) {
                Button("确认扣除", role: .destructive) {
                    if let rl = triggeringRedLine {
                        triggerRedLine(rl)
                    }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private func addFromTemplate(_ template: RedLine) {
        guard store.redLines.count < 3 else { return }
        let newRL = RedLine(title: template.title, penalty: template.penalty)
        store.addRedLine(newRL)
    }

    private func triggerRedLine(_ redLine: RedLine) {
        store.triggerRedLine(redLine)
        feedbackMessage = "已扣除 \(redLine.penalty) 🪙 (\(redLine.title))"
        withAnimation(.bouncy) { showFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showFeedback = false }
        }
    }
}

// MARK: - Red Line Row
struct RedLineRow: View {
    let redLine: RedLine
    let onTrigger: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Color.xDanger)
                .font(.system(size: 22))

            VStack(alignment: .leading, spacing: 3) {
                Text(redLine.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                Text("触发扣 \(redLine.penalty) 🪙")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color.xDanger)
            }

            Spacer()

            Button(action: onTrigger) {
                Text("触发")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.xDanger)
                    .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Red Line Edit Sheet
struct RedLineEditSheet: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (RedLine) -> Void

    @State private var title: String = ""
    @State private var penalty: Int = 1

    var body: some View {
        NavigationView {
            Form {
                Section("红线行为描述") {
                    TextField("例如：大喊大叫", text: $title)
                        .font(.system(size: 16, design: .rounded))
                }
                Section("扣除金币数") {
                    Stepper("\(penalty) 🪙", value: $penalty, in: 1...2)
                        .font(.system(size: 16, design: .rounded))
                    Text("扣分范围：1–2 金币")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }
            .navigationTitle("新增红线")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let rl = RedLine(title: title.trimmingCharacters(in: .whitespaces), penalty: penalty)
                        onSave(rl)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xDanger)
                }
            }
        }
    }
}
