import Foundation
import SwiftUI

// MARK: - Store Item Category
enum ItemCategory: String, Codable, CaseIterable {
    case food       = "food"        // 食物
    case water      = "water"       // 水
    case building   = "building"    // 建材
    case decoration = "decoration"  // 装饰
    case toy        = "toy"         // 玩具

    var displayName: String {
        switch self {
        case .food:       return "食物"
        case .water:      return "水"
        case .building:   return "建材"
        case .decoration: return "装饰"
        case .toy:        return "玩具"
        }
    }

    var emoji: String {
        switch self {
        case .food:       return "🍖"
        case .water:      return "💧"
        case .building:   return "🏠"
        case .decoration: return "🌸"
        case .toy:        return "🎾"
        }
    }
}

// MARK: - Store Item
struct StoreItem: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var emoji: String
    var category: ItemCategory
    var price: Int           // coin cost
    var description: String
    var hungerBoost: Int     // how much it fills hunger
    var thirstBoost: Int     // how much it fills thirst
    var moodBoost: Int       // how much it boosts mood
    var isPlaceable: Bool    // can be placed in garden

    static func == (lhs: StoreItem, rhs: StoreItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Placed Garden Item
struct HomeItem: Codable, Identifiable {
    var id: UUID = UUID()
    var storeItem: StoreItem
    var positionX: Double
    var positionY: Double

    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set { positionX = newValue.x; positionY = newValue.y }
    }

    init(storeItem: StoreItem, position: CGPoint) {
        self.storeItem = storeItem
        self.positionX = position.x
        self.positionY = position.y
    }
}

// MARK: - Shop Catalog
extension StoreItem {
    static let catalog: [StoreItem] = [
        // Food
        StoreItem(id: UUID(), name: "小鱼干", emoji: "🐟", category: .food, price: 1,
                  description: "宠物最爱的零食", hungerBoost: 20, thirstBoost: 0, moodBoost: 10, isPlaceable: false),
        StoreItem(id: UUID(), name: "猫粮狗粮", emoji: "🍖", category: .food, price: 2,
                  description: "营养丰富的主食", hungerBoost: 40, thirstBoost: 0, moodBoost: 5, isPlaceable: false),
        StoreItem(id: UUID(), name: "小蛋糕", emoji: "🎂", category: .food, price: 3,
                  description: "特别的甜蜜零食", hungerBoost: 30, thirstBoost: 0, moodBoost: 20, isPlaceable: false),

        // Water
        StoreItem(id: UUID(), name: "清水", emoji: "💧", category: .water, price: 1,
                  description: "新鲜干净的水", hungerBoost: 0, thirstBoost: 25, moodBoost: 5, isPlaceable: false),
        StoreItem(id: UUID(), name: "牛奶", emoji: "🥛", category: .water, price: 2,
                  description: "香浓好喝的牛奶", hungerBoost: 5, thirstBoost: 30, moodBoost: 10, isPlaceable: false),

        // Toys
        StoreItem(id: UUID(), name: "毛线球", emoji: "🧶", category: .toy, price: 2,
                  description: "让宠物开心的玩具", hungerBoost: 0, thirstBoost: 0, moodBoost: 20, isPlaceable: true),
        StoreItem(id: UUID(), name: "小皮球", emoji: "🎾", category: .toy, price: 3,
                  description: "蹦蹦跳跳好快乐", hungerBoost: 0, thirstBoost: 0, moodBoost: 25, isPlaceable: true),

        // Building / Home items
        StoreItem(id: UUID(), name: "食盆", emoji: "🥣", category: .building, price: 3,
                  description: "宠物专属的饭碗", hungerBoost: 0, thirstBoost: 0, moodBoost: 5, isPlaceable: true),
        StoreItem(id: UUID(), name: "水盆", emoji: "🪣", category: .building, price: 3,
                  description: "专属饮水盆", hungerBoost: 0, thirstBoost: 0, moodBoost: 5, isPlaceable: true),
        StoreItem(id: UUID(), name: "小窝", emoji: "🏠", category: .building, price: 5,
                  description: "温暖舒适的小家", hungerBoost: 0, thirstBoost: 0, moodBoost: 15, isPlaceable: true),
        StoreItem(id: UUID(), name: "栅栏", emoji: "🔰", category: .building, price: 2,
                  description: "漂亮的小栅栏", hungerBoost: 0, thirstBoost: 0, moodBoost: 2, isPlaceable: true),

        // Decorations
        StoreItem(id: UUID(), name: "小花", emoji: "🌸", category: .decoration, price: 1,
                  description: "美丽的小花朵", hungerBoost: 0, thirstBoost: 0, moodBoost: 3, isPlaceable: true),
        StoreItem(id: UUID(), name: "大树", emoji: "🌳", category: .decoration, price: 4,
                  description: "可以乘凉的大树", hungerBoost: 0, thirstBoost: 0, moodBoost: 5, isPlaceable: true),
        StoreItem(id: UUID(), name: "彩虹", emoji: "🌈", category: .decoration, price: 5,
                  description: "雨后漂亮的彩虹", hungerBoost: 0, thirstBoost: 0, moodBoost: 10, isPlaceable: true),
        StoreItem(id: UUID(), name: "小蘑菇", emoji: "🍄", category: .decoration, price: 2,
                  description: "可爱的小蘑菇", hungerBoost: 0, thirstBoost: 0, moodBoost: 3, isPlaceable: true),
    ]
}
