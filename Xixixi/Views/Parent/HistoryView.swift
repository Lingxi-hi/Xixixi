import SwiftUI

// MARK: - History View (历史记录 + 趋势)
struct HistoryView: View {
    @EnvironmentObject var store: GameStore

    private let chartHeight: CGFloat = 120

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                if store.taskHistory.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Stats overview
                            statsOverview

                            // Completion rate trend chart
                            trendChart

                            // Day-by-day list
                            historyList

                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("📊 历史记录")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Stats overview
    private var statsOverview: some View {
        let totalDays = store.taskHistory.count
        let avgRate   = store.taskHistory.map { $0.completionRate }.reduce(0, +) / max(1, Double(totalDays))
        let totalCoins = store.totalCoinsEarned
        let streak = consecutiveDays()

        return HStack(spacing: 0) {
            overviewCell(value: "\(totalDays)", label: "累计天数",  emoji: "📅")
            Divider().frame(height: 50)
            overviewCell(value: "\(Int(avgRate * 100))%", label: "平均完成率", emoji: "📈")
            Divider().frame(height: 50)
            overviewCell(value: "\(totalCoins) 🪙", label: "总获金币", emoji: "")
            Divider().frame(height: 50)
            overviewCell(value: "\(streak)天", label: "当前连续", emoji: "🔥")
        }
        .padding(.vertical, 14)
        .cardStyle()
    }

    private func overviewCell(value: String, label: String, emoji: String) -> some View {
        VStack(spacing: 4) {
            if !emoji.isEmpty { Text(emoji).font(.system(size: 16)) }
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Trend chart (bar chart of completion rate)
    private var trendChart: some View {
        let recent = Array(store.taskHistory.prefix(14).reversed())

        return VStack(alignment: .leading, spacing: 12) {
            Text("最近完成率趋势")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(recent) { record in
                    VStack(spacing: 4) {
                        let rate = record.completionRate
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(barColor(rate))
                            .frame(height: max(4, chartHeight * rate))

                        Text(dayLabel(record.date))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(Color.xSubtext)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: chartHeight + 20)

            // Legend
            HStack(spacing: 16) {
                legendItem(color: Color.xSecondary, label: "100%")
                legendItem(color: Color.xPrimary, label: "50%+")
                legendItem(color: Color.xDanger.opacity(0.6), label: "50%以下")
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func barColor(_ rate: Double) -> Color {
        if rate >= 1.0 { return Color.xSecondary }
        if rate >= 0.5 { return Color.xPrimary }
        return Color.xDanger.opacity(0.6)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d"
        return fmt.string(from: date)
    }

    // MARK: - History list
    private var historyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每日详情")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)

            ForEach(store.taskHistory) { record in
                HistoryDetailRow(record: record)
            }
        }
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("📊")
                .font(.system(size: 60))
            Text("还没有历史记录")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text("完成今日结算后记录会出现在这里")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers
    private func consecutiveDays() -> Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        for record in store.taskHistory.sorted(by: { $0.date > $1.date }) {
            let recordDay = calendar.startOfDay(for: record.date)
            if recordDay == checkDate && record.completionRate > 0 {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        return streak
    }
}

// MARK: - History Detail Row
struct HistoryDetailRow: View {
    let record: DayRecord
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button(action: { withAnimation(.gentle) { expanded.toggle() } }) {
                HStack(spacing: 12) {
                    // Date block
                    VStack(spacing: 0) {
                        Text(dayString)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color.xText)
                        Text(monthString)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Color.xSubtext)
                    }
                    .frame(width: 36)

                    // Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(record.tasks.filter { $0.isApproved }.count)/\(record.tasks.count) 任务")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.xText)
                            Spacer()
                            Text("+\(record.coinsEarned) 🪙")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color.xCoin)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.gray.opacity(0.15))
                                Capsule()
                                    .fill(Color.xSecondary)
                                    .frame(width: geo.size.width * record.completionRate)
                            }
                        }
                        .frame(height: 6)
                    }

                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color.xSubtext)
                }
                .padding(12)
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded task detail
            if expanded {
                Divider().padding(.horizontal, 12)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(record.tasks) { task in
                        HStack(spacing: 8) {
                            Image(systemName: task.isApproved ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isApproved ? Color.xSecondary : Color.gray.opacity(0.4))
                                .font(.system(size: 14))
                            Text(task.title)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(task.isApproved ? Color.xText : Color.xSubtext)
                            Spacer()
                            if task.isApproved {
                                Text("+\(task.reward) 🪙")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.xCoin)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cardStyle(cornerRadius: 16)
    }

    private var dayString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d"
        return fmt.string(from: record.date)
    }

    private var monthString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "M月"
        return fmt.string(from: record.date)
    }
}
