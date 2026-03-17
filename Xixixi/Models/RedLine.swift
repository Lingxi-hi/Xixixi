import Foundation

// MARK: - Red Line (家长设置的红线行为)
struct RedLine: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var penalty: Int     // 1–2 coins
    var isActive: Bool

    init(title: String, penalty: Int = 1, isActive: Bool = true) {
        self.title = title
        self.penalty = max(1, min(2, penalty))
        self.isActive = isActive
    }
}

extension RedLine {
    static let templates: [RedLine] = [
        RedLine(title: "大喊大叫",      penalty: 1),
        RedLine(title: "乱扔玩具",      penalty: 1),
        RedLine(title: "故意打人",      penalty: 2),
        RedLine(title: "哭闹不起床",    penalty: 1),
        RedLine(title: "故意损坏物品",  penalty: 2),
        RedLine(title: "不听劝说撒泼",  penalty: 1),
    ]

    static var defaults: [RedLine] {
        [templates[0], templates[1]]
    }
}
