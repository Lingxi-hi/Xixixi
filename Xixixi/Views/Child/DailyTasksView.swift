import SwiftUI

// MARK: - Daily Tasks View (今日任务页)
struct DailyTasksView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    @State private var submittingTask: DailyTask? = nil
    @State private var showConfirmSheet           = false
    @State private var showSuccessFor: UUID?      = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        summaryHeader

                        VStack(spacing: 12) {
                            ForEach(store.dailyTasks) { task in
                                TaskCard(task: task) {
                                    submittingTask = task
                                    showConfirmSheet = true
                                }
                                .overlay(
                                    Group {
                                        if showSuccessFor == task.id {
                                            successSparkles
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        encouragementView
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("今日任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .foregroundStyle(Color(red:0.35, green:0.65, blue:1.0))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(Color.xPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .confirmationDialog(
                submittingTask.map { "告诉爸爸妈妈：\($0.title) 做好了！" } ?? "",
                isPresented: $showConfirmSheet,
                titleVisibility: .visible
            ) {
                Button("我做到了！") {
                    if let task = submittingTask { confirmSubmit(task) }
                }
                Button("还没好", role: .cancel) { submittingTask = nil }
            }
        }
    }

    // MARK: - Summary header
    private var summaryHeader: some View {
        let approved     = store.dailyTasks.filter { $0.isApproved }.count
        let total        = store.dailyTasks.count
        let earnedToday  = store.dailyTasks.filter { $0.isApproved }.reduce(0) { $0 + $1.reward }

        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.xSubtext.opacity(0.18), lineWidth: 8)
                    .frame(width: 90, height: 90)
                Circle()
                    .trim(from: 0, to: total > 0 ? CGFloat(approved) / CGFloat(total) : 0)
                    .stroke(Color.xSecondary,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .animation(.gentle, value: approved)
                VStack(spacing: 0) {
                    Text("\(approved)/\(total)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.xText)
                    Text("完成")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }

            HStack(spacing: 5) {
                Text("今天赚了")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                CoinIcon(size: 16)
                Text("\(earnedToday)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xCoin)
                Text("金币")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
            }

            if approved == total && total > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("全部完成了！太棒了！")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.xSecondary)
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .cardStyle()
        .padding(.horizontal, 16)
    }

    // MARK: - Encouragement
    private var encouragementView: some View {
        let msgs: [(String, String)] = [
            ("star.fill",       "每完成一个任务，\(store.pet.name) 就更开心一点！"),
            ("heart.fill",      "做完任务可以赚金币，给\(store.pet.name)买好吃的！"),
            ("hand.thumbsup.fill", "坚持下去，你是最棒的！"),
        ]
        let msg = msgs.randomElement()!
        return HStack(spacing: 10) {
            Image(systemName: msg.0)
                .font(.system(size: 22))
                .foregroundStyle(Color.xPrimary)
            Text(msg.1)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.xSubtext)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.xPrimary.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
    }

    // MARK: - Success sparkles (SF Symbols)
    private var successSparkles: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 10...18)))
                    .foregroundStyle(Color.xCoin)
                    .offset(
                        x: CGFloat([-50,-30,0,30,50][i]),
                        y: CGFloat([-30,-20,-10,-25,-15][i])
                    )
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func confirmSubmit(_ task: DailyTask) {
        store.submitTask(task)
        withAnimation(.bouncy) { showSuccessFor = task.id }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { showSuccessFor = nil }
        submittingTask = nil
    }
}

// MARK: - Task Card
struct TaskCard: View {
    let task: DailyTask
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Category icon
            ZStack {
                Circle()
                    .fill(task.category.symbolColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: task.category.sfSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(task.category.symbolColor)
            }

            // Task info
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(task.isApproved ? Color.xSubtext : Color.xText)
                    .strikethrough(task.isApproved)

                HStack(spacing: 4) {
                    CoinIcon(size: 12)
                    Text("\(task.reward)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.xCoin)
                    Text("·")
                        .foregroundColor(Color.xSubtext)
                    Text(task.category.displayName)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }

            Spacer()
            statusView
        }
        .padding(14)
        .cardStyle()
        .opacity(task.isApproved ? 0.8 : 1.0)
    }

    @ViewBuilder
    private var statusView: some View {
        if task.isApproved {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(Color.xSecondary)
        } else if task.isPending {
            VStack(spacing: 2) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.xPrimary)
                Text("等待中")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(Color.xSubtext)
            }
        } else if task.isRejected {
            Button(action: onSubmit) {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.xDanger)
                    Text("再试试")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(Color.xDanger)
                }
            }
        } else {
            Button(action: onSubmit) {
                Text("我做到了")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.xPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}
