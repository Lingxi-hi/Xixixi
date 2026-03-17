import SwiftUI

// MARK: - Daily Settlement View (今日结算)
struct DailySettlementView: View {
    @EnvironmentObject var store: GameStore
    @State private var showSettleConfirm = false
    @State private var showSettled = false

    var totalEarned: Int {
        store.approvedTasksToday.reduce(0) { $0 + $1.reward }
    }

    var completionRate: Double {
        guard !store.dailyTasks.isEmpty else { return 0 }
        return Double(store.approvedTasksToday.count) / Double(store.dailyTasks.count)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Summary card
                        summaryCard

                        // Pet current status
                        petStatusCard

                        // Task summary
                        taskSummaryCard

                        // Settle button
                        settleButton

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }

                // Settled overlay
                if showSettled {
                    settledOverlay
                }
            }
            .navigationTitle("💰 今日结算")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("确认结算今天吗？结算后今日任务状态将重置。",
                                isPresented: $showSettleConfirm,
                                titleVisibility: .visible) {
                Button("确认结算") { doSettle() }
                Button("取消", role: .cancel) {}
            }
        }
    }

    // MARK: - Summary card
    private var summaryCard: some View {
        VStack(spacing: 16) {
            Text("今日总结")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)

            HStack(spacing: 0) {
                summaryCell(value: "\(store.approvedTasksToday.count)/\(store.dailyTasks.count)",
                            label: "完成任务", emoji: "✅")
                Divider().frame(height: 50)
                summaryCell(value: "+\(totalEarned) 🪙",
                            label: "今日获得", emoji: "")
                Divider().frame(height: 50)
                summaryCell(value: "\(store.coins) 🪙",
                            label: "当前余额", emoji: "")
            }

            // Completion rate bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("完成率")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                    Spacer()
                    Text("\(Int(completionRate * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color.xSecondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.xSubtext.opacity(0.15))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.xSecondary)
                            .frame(width: geo.size.width * completionRate)
                            .animation(.gentle, value: completionRate)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 4)
        }
        .padding(20)
        .cardStyle()
    }

    private func summaryCell(value: String, label: String, emoji: String) -> some View {
        VStack(spacing: 4) {
            if !emoji.isEmpty { Text(emoji).font(.system(size: 16)) }
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Pet status card
    private var petStatusCard: some View {
        HStack(spacing: 16) {
            Text(store.pet.type.happyEmoji)
                .font(.system(size: 44))
                .padding(10)
                .background(store.pet.mood.color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(store.pet.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
                Text(store.pet.mood.description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(store.pet.mood.color)

                HStack(spacing: 8) {
                    miniBar("🍖", value: store.pet.hunger)
                    miniBar("💧", value: store.pet.thirst)
                    miniBar("💛", value: store.pet.moodScore)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func miniBar(_ emoji: String, value: Int) -> some View {
        HStack(spacing: 3) {
            Text(emoji).font(.system(size: 12))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule().fill(Color.xPrimary.opacity(0.7))
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                }
            }
            .frame(width: 40, height: 6)
        }
    }

    // MARK: - Task summary card
    private var taskSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("任务完成情况")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)

            ForEach(store.dailyTasks) { task in
                HStack(spacing: 10) {
                    Image(systemName: task.isApproved ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isApproved ? Color.xSecondary : Color.gray.opacity(0.4))
                        .font(.system(size: 18))

                    Text(task.title)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(task.isApproved ? Color.xText : Color.xSubtext)
                        .strikethrough(!task.isApproved)

                    Spacer()

                    if task.isApproved {
                        Text("+\(task.reward) 🪙")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.xCoin)
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Settle button
    private var settleButton: some View {
        Button(action: { showSettleConfirm = true }) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                Text("完成今日结算")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Color.xPrimary, Color.xAccent],
                               startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.xPrimary.opacity(0.35), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Settled overlay
    private var settledOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("🎉")
                    .font(.system(size: 60))
                Text("结算完成！")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("今天 \(store.pet.name) 很开心～")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(36)
            .background(
                LinearGradient(colors: [Color.xPrimary, Color.xSecondary],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Actions
    private func doSettle() {
        store.doSettlement()
        withAnimation(.bouncy) { showSettled = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showSettled = false }
        }
    }
}
