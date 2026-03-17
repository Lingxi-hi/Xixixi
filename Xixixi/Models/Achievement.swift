import Foundation
import SwiftUI

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var emoji: String
    var isUnlocked: Bool
    var unlockedAt: Date?

    init(id: String, title: String, description: String, emoji: String, isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.emoji = emoji
        self.isUnlocked = isUnlocked
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_task",
                    title: "第一步！",
                    description: "完成了第一个任务",
                    emoji: "⭐"),
        Achievement(id: "week_streak",
                    title: "坚持一周",
                    description: "连续7天都完成了任务",
                    emoji: "🏆"),
        Achievement(id: "first_home_item",
                    title: "小小装修师",
                    description: "放置了第一个家园物品",
                    emoji: "🏠"),
        Achievement(id: "pet_happy",
                    title: "宠物超开心",
                    description: "让宠物心情达到超级开心",
                    emoji: "🥰"),
        Achievement(id: "shop_first",
                    title: "第一次购物",
                    description: "在商店买了第一件东西",
                    emoji: "🛍️"),
        Achievement(id: "coins_10",
                    title: "小财主",
                    description: "累计获得了10枚金币",
                    emoji: "🪙"),
        Achievement(id: "coins_50",
                    title: "大土豪",
                    description: "累计获得了50枚金币",
                    emoji: "💰"),
        Achievement(id: "three_tasks_day",
                    title: "超级棒！",
                    description: "一天完成了3个以上的任务",
                    emoji: "🌟"),
        Achievement(id: "spring_decoration",
                    title: "春天来了",
                    description: "放置了春天装饰品",
                    emoji: "🌸"),
        Achievement(id: "winter_decoration",
                    title: "冬天来了",
                    description: "放置了冬天装饰品",
                    emoji: "⛄"),
    ]
}
