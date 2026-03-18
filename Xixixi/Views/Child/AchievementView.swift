import SwiftUI

// MARK: - Achievement / Album View
struct AchievementView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    // Map achievement id → SF Symbol
    private static let symbolMap: [String: (symbol: String, color: Color)] = [
        "first_task":        ("star.fill",                    .yellow),
        "week_streak":       ("trophy.fill",                  Color(red:1.0, green:0.78, blue:0.20)),
        "first_home_item":   ("house.fill",                   Color(red:0.55, green:0.75, blue:0.35)),
        "pet_happy":         ("heart.fill",                   .pink),
        "shop_first":        ("bag.fill",                     Color(red:1.0, green:0.55, blue:0.20)),
        "coins_10":          ("circle.fill",                  .yellow),
        "coins_50":          ("circle.fill",                  Color(red:1.0, green:0.82, blue:0.20)),
        "three_tasks_day":   ("sparkles",                     .orange),
        "spring_decoration": ("leaf.fill",                    .green),
        "winter_decoration": ("snowflake",                    Color(red:0.60, green:0.80, blue:1.0)),
    ]

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 14)]

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        statsRow
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.achievements) { achievement in
                                AchievementCard(
                                    achievement: achievement,
                                    sfSymbol: Self.symbolMap[achievement.id]?.symbol ?? "star.fill",
                                    symbolColor: Self.symbolMap[achievement.id]?.color ?? .yellow
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        if !store.taskHistory.isEmpty {
                            historySection
                        }
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("成长相册")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(Color(red:1.0, green:0.78, blue:0.20))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(Color.xPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(value: "\(store.totalCoinsEarned)", label: "获得金币",
                     symbol: "circle.fill", color: .yellow)
            Divider().frame(height: 40)
            statCell(value: "\(store.taskHistory.count)", label: "完成天数",
                     symbol: "calendar", color: Color.xPrimary)
            Divider().frame(height: 40)
            statCell(value: "\(store.achievements.filter { $0.isUnlocked }.count)", label: "成就解锁",
                     symbol: "trophy.fill", color: Color(red:1.0, green:0.78, blue:0.20))
        }
        .padding(.vertical, 14)
        .cardStyle()
        .padding(.horizontal, 16)
    }

    private func statCell(value: String, label: String, symbol: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundStyle(Color.xPrimary)
                Text("最近记录")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
                Spacer()
            }
            .padding(.horizontal, 16)

            ForEach(store.taskHistory.prefix(5)) { record in
                HistoryRowView(record: record)
            }
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    let sfSymbol: String
    let symbolColor: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? symbolColor.opacity(0.18)
                          : Color.gray.opacity(0.10))
                    .frame(width: 64, height: 64)

                if achievement.isUnlocked {
                    Image(systemName: sfSymbol)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(symbolColor)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
            }

            Text(achievement.title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(achievement.isUnlocked ? Color.xText : Color.xSubtext)
                .multilineTextAlignment(.center)

            Text(achievement.description)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color.xSubtext)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if achievement.isUnlocked, let date = achievement.unlockedAt {
                Text(date, style: .date)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(Color.xPrimary)
            }
        }
        .padding(14)
        .cardStyle()
        .opacity(achievement.isUnlocked ? 1.0 : 0.58)
    }
}

// MARK: - History Row
struct HistoryRowView: View {
    let record: DayRecord

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .center, spacing: 2) {
                Text(dayString)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
                Text(monthString)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Color.xSubtext)
            }
            .frame(width: 40)

            Rectangle()
                .fill(Color.xPrimary.opacity(0.4))
                .frame(width: 2, height: 44)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 4) {
                let approved = record.tasks.filter { $0.isApproved }.count
                Text("完成了 \(approved)/\(record.tasks.count) 个任务")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                HStack(spacing: 6) {
                    CoinIcon(size: 12)
                    Text("+\(record.coinsEarned)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.xCoin)
                    if record.coinsDeducted > 0 {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.xDanger)
                        Text("-\(record.coinsDeducted)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color.xDanger)
                    }
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.xSubtext.opacity(0.18), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: record.completionRate)
                    .stroke(Color.xSecondary,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(record.completionRate * 100))%")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            .frame(width: 36, height: 36)
        }
        .padding(12)
        .cardStyle(cornerRadius: 16)
        .padding(.horizontal, 16)
    }

    private var dayString: String {
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: record.date)
    }
    private var monthString: String {
        let f = DateFormatter(); f.dateFormat = "M月"; return f.string(from: record.date)
    }
}
