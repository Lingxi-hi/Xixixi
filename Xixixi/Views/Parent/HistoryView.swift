import SwiftUI

// MARK: - History View
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
                            statsOverview
                            trendChart
                            historyList
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var statsOverview: some View {
        let totalDays  = store.taskHistory.count
        let avgRate    = store.taskHistory.map { $0.completionRate }.reduce(0, +) / max(1, Double(totalDays))
        let streak     = consecutiveDays()

        return HStack(spacing: 0) {
            overviewCell(value: "\(totalDays)", label: "累计天数",
                         symbol: "calendar", color: Color.xPrimary)
            Divider().frame(height: 50)
            overviewCell(value: "\(Int(avgRate * 100))%", label: "平均完成率",
                         symbol: "chart.bar.fill", color: Color.xSecondary)
            Divider().frame(height: 50)
            overviewCell(value: "\(store.totalCoinsEarned)", label: "总获金币",
                         symbol: "circle.fill", color: Color.xCoin)
            Divider().frame(height: 50)
            overviewCell(value: "\(streak)天", label: "当前连续",
                         symbol: "flame.fill", color: .orange)
        }
        .padding(.vertical, 14)
        .cardStyle()
    }

    private func overviewCell(value: String, label: String, symbol: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity)
    }

    private var trendChart: some View {
        let recent = Array(store.taskHistory.prefix(14).reversed())
        return VStack(alignment: .leading, spacing: 12) {
            Text("最近完成率趋势")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(recent) { record in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(barColor(record.completionRate))
                            .frame(height: max(4, chartHeight * record.completionRate))
                        Text(dayLabel(record.date))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(Color.xSubtext)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: chartHeight + 20)

            HStack(spacing: 16) {
                legendItem(color: Color.xSecondary, label: "100%")
                legendItem(color: Color.xPrimary,   label: "50%+")
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
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 12, height: 12)
            Text(label).font(.system(size: 11, design: .rounded)).foregroundColor(Color.xSubtext)
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: date)
    }

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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.xSubtext.opacity(0.4))
            Text("还没有历史记录")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text("完成今日结算后记录会出现在这里")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func consecutiveDays() -> Int {
        var streak = 0
        let cal = Calendar.current
        var check = cal.startOfDay(for: Date())
        for record in store.taskHistory.sorted(by: { $0.date > $1.date }) {
            let day = cal.startOfDay(for: record.date)
            if day == check && record.completionRate > 0 {
                streak += 1
                check = cal.date(byAdding: .day, value: -1, to: check) ?? check
            } else { break }
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
            Button(action: { withAnimation(.gentle) { expanded.toggle() } }) {
                HStack(spacing: 12) {
                    VStack(spacing: 0) {
                        Text(dayString)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color.xText)
                        Text(monthString)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Color.xSubtext)
                    }
                    .frame(width: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(record.tasks.filter { $0.isApproved }.count)/\(record.tasks.count) 任务")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.xText)
                            Spacer()
                            HStack(spacing: 3) {
                                Text("+\(record.coinsEarned)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.xCoin)
                                CoinIcon(size: 12)
                            }
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.gray.opacity(0.15))
                                Capsule().fill(Color.xSecondary)
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

            if expanded {
                Divider().padding(.horizontal, 12)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(record.tasks) { task in
                        HStack(spacing: 8) {
                            Image(systemName: task.isApproved ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isApproved ? Color.xSecondary : Color.gray.opacity(0.4))
                                .font(.system(size: 14))
                            Text(task.title)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(task.isApproved ? Color.xText : Color.xSubtext)
                            Spacer()
                            if task.isApproved {
                                HStack(spacing: 2) {
                                    Text("+\(task.reward)")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.xCoin)
                                    CoinIcon(size: 11)
                                }
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
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: record.date)
    }
    private var monthString: String {
        let f = DateFormatter(); f.dateFormat = "M月"; return f.string(from: record.date)
    }
}
