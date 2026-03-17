import SwiftUI

// MARK: - Pending Approval View (待确认任务)
struct PendingApprovalView: View {
    @EnvironmentObject var store: GameStore
    @State private var showApproveAllConfirm = false

    var pendingTasks: [DailyTask] { store.pendingTasks }

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                if pendingTasks.isEmpty {
                    emptyState
                } else {
                    List {
                        // Approve all button
                        if pendingTasks.count > 1 {
                            Section {
                                Button(action: { showApproveAllConfirm = true }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.xSecondary)
                                        Text("全部通过 (\(pendingTasks.count) 个)")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.xSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(Color.xSecondary.opacity(0.08))
                            }
                        }

                        // Individual tasks
                        Section("等待你确认的任务") {
                            ForEach(pendingTasks) { task in
                                ApprovalTaskRow(task: task)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("⏳ 待确认 (\(pendingTasks.count))")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("确认全部通过？", isPresented: $showApproveAllConfirm, titleVisibility: .visible) {
                Button("全部通过") { approveAll() }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 60))
            Text("暂无待确认任务")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text("孩子提交任务后会在这里出现")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func approveAll() {
        for task in pendingTasks {
            store.approveTask(task)
        }
    }
}

// MARK: - Approval Task Row
struct ApprovalTaskRow: View {
    @EnvironmentObject var store: GameStore
    let task: DailyTask

    @State private var showNote = false
    @State private var note: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Task info
            HStack(spacing: 12) {
                Text(task.category.emoji).font(.system(size: 24))

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.xText)
                    if let submittedAt = task.submittedAt {
                        Text("提交于 \(submittedAt, style: .time)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color.xSubtext)
                    }
                }

                Spacer()

                Text("🪙 \(task.reward)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xCoin)
            }

            // Action buttons
            HStack(spacing: 12) {
                // Approve
                Button(action: { store.approveTask(task) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("通过")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.xSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())

                // Reject
                Button(action: { store.rejectTask(task) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle")
                        Text("再做做")
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.xDanger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.xDanger.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(Color.xCard)
    }
}
