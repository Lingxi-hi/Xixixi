import Foundation

// MARK: - Task Category
enum TaskCategory: String, Codable, CaseIterable {
    case hygiene        = "hygiene"       // 生活卫生
    case selfCare       = "selfCare"      // 自理能力
    case housework      = "housework"     // 家务帮忙
    case emotion        = "emotion"       // 情绪行为
    case learning       = "learning"      // 学习习惯

    var displayName: String {
        switch self {
        case .hygiene:   return "生活卫生"
        case .selfCare:  return "自理能力"
        case .housework: return "家务帮忙"
        case .emotion:   return "情绪行为"
        case .learning:  return "学习习惯"
        }
    }

    var emoji: String {
        switch self {
        case .hygiene:   return "🪥"
        case .selfCare:  return "👕"
        case .housework: return "🧹"
        case .emotion:   return "💛"
        case .learning:  return "📚"
        }
    }
}

// MARK: - Daily Task
struct DailyTask: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var category: TaskCategory
    var reward: Int          // 1–3 coins
    var isSubmitted: Bool    // child tapped "我做到了"
    var isApproved: Bool     // parent confirmed
    var isRejected: Bool     // parent rejected
    var submittedAt: Date?
    var approvedAt: Date?
    var note: String         // optional parent note

    init(
        title: String,
        category: TaskCategory,
        reward: Int = 1,
        isSubmitted: Bool = false,
        isApproved: Bool = false,
        isRejected: Bool = false,
        submittedAt: Date? = nil,
        approvedAt: Date? = nil,
        note: String = ""
    ) {
        self.title = title
        self.category = category
        self.reward = max(1, min(3, reward))
        self.isSubmitted = isSubmitted
        self.isApproved = isApproved
        self.isRejected = isRejected
        self.submittedAt = submittedAt
        self.approvedAt = approvedAt
        self.note = note
    }

    var statusDescription: String {
        if isApproved { return "已完成 ✓" }
        if isRejected { return "未通过" }
        if isSubmitted { return "等待确认..." }
        return "还没做哦"
    }

    var isComplete: Bool { isApproved }
    var isPending: Bool  { isSubmitted && !isApproved && !isRejected }
}

// MARK: - Task Templates (default tasks for new users)
extension DailyTask {
    static let templates: [DailyTask] = [
        DailyTask(title: "早上刷牙",        category: .hygiene,   reward: 1),
        DailyTask(title: "晚上刷牙",        category: .hygiene,   reward: 1),
        DailyTask(title: "自己穿好衣服",    category: .selfCare,  reward: 2),
        DailyTask(title: "饭前洗手",        category: .hygiene,   reward: 1),
        DailyTask(title: "把玩具收拾好",    category: .housework, reward: 2),
        DailyTask(title: "帮忙摆碗筷",      category: .housework, reward: 2),
        DailyTask(title: "午睡不闹觉",      category: .emotion,   reward: 2),
        DailyTask(title: "好好吃饭不挑食",  category: .emotion,   reward: 3),
        DailyTask(title: "看绘本10分钟",    category: .learning,  reward: 2),
        DailyTask(title: "独立穿鞋子",      category: .selfCare,  reward: 2),
    ]

    static var defaults: [DailyTask] {
        Array(templates.prefix(3))
    }
}

// MARK: - Day Record (for history)
struct DayRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var tasks: [DailyTask]
    var redLineTriggers: [RedLineTrigger]
    var coinsEarned: Int
    var coinsDeducted: Int
    var petMoodAtEnd: Int

    var netCoins: Int { coinsEarned - coinsDeducted }
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        let approved = tasks.filter { $0.isApproved }.count
        return Double(approved) / Double(tasks.count)
    }

    static func makeEmpty() -> DayRecord {
        DayRecord(date: Date(), tasks: [], redLineTriggers: [], coinsEarned: 0, coinsDeducted: 0, petMoodAtEnd: 80)
    }
}

// MARK: - Red Line Trigger (history record)
struct RedLineTrigger: Codable, Identifiable {
    var id: UUID = UUID()
    var redLineTitle: String
    var penalty: Int
    var triggeredAt: Date
}
