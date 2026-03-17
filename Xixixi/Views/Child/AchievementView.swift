import SwiftUI

// MARK: - Achievement / Album View (成长相册/成就页)
struct AchievementView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 14)]

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Stats row
                        statsRow

                        // Achievement grid
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, 16)

                        // History preview
                        if !store.taskHistory.isEmpty {
                            historySection
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("⭐ 成长相册")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(Color.xPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
    }

    // MARK: - Stats row
    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(value: "\(store.totalCoinsEarned)", label: "获得金币", emoji: "🪙")
            Divider().frame(height: 40)
            statCell(value: "\(store.taskHistory.count)", label: "完成天数", emoji: "📅")
            Divider().frame(height: 40)
            statCell(value: "\(store.achievements.filter { $0.isUnlocked }.count)", label: "成就解锁", emoji: "🏆")
        }
        .padding(.vertical, 14)
        .cardStyle()
        .padding(.horizontal, 16)
    }

    private func statCell(value: String, label: String, emoji: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 22))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color.xSubtext)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - History section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📖 最近记录")
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

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? Color.xPrimary.opacity(0.2)
                          : Color.gray.opacity(0.1))
                    .frame(width: 64, height: 64)

                Text(achievement.isUnlocked ? achievement.emoji : "🔒")
                    .font(.system(size: 36))
                    .grayscale(achievement.isUnlocked ? 0 : 1.0)
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
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - History Row
struct HistoryRowView: View {
    let record: DayRecord

    var body: some View {
        HStack(spacing: 14) {
            // Date
            VStack(alignment: .center, spacing: 2) {
                Text(dayString)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
                Text(monthString)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Color.xSubtext)
            }
            .frame(width: 40)

            // Divider
            Rectangle()
                .fill(Color.xPrimary.opacity(0.4))
                .frame(width: 2, height: 44)
                .clipShape(Capsule())

            // Info
            VStack(alignment: .leading, spacing: 4) {
                let approved = record.tasks.filter { $0.isApproved }.count
                Text("完成了 \(approved)/\(record.tasks.count) 个任务")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                HStack(spacing: 6) {
                    Text("🪙 +\(record.coinsEarned)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.xCoin)
                    if record.coinsDeducted > 0 {
                        Text("🔻 -\(record.coinsDeducted)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color.xDanger)
                    }
                }
            }

            Spacer()

            // Completion indicator
            ZStack {
                Circle()
                    .stroke(Color.xSubtext.opacity(0.2), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: record.completionRate)
                    .stroke(Color.xSecondary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
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
