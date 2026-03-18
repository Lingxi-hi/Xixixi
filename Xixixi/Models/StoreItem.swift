import Foundation
import SwiftUI

// MARK: - Store Item Category
enum ItemCategory: String, Codable, CaseIterable {
    case food       = "food"
    case water      = "water"
    case building   = "building"
    case decoration = "decoration"
    case toy        = "toy"

    var displayName: String {
        switch self {
        case .food:       return "食物"
        case .water:      return "水"
        case .building:   return "建材"
        case .decoration: return "装饰"
        case .toy:        return "玩具"
        }
    }

    var sfSymbol: String {
        switch self {
        case .food:       return "fork.knife"
        case .water:      return "drop.fill"
        case .building:   return "house.fill"
        case .decoration: return "sparkles"
        case .toy:        return "star.fill"
        }
    }

    var symbolColor: Color {
        switch self {
        case .food:       return Color(red: 1.0,  green: 0.55, blue: 0.20)
        case .water:      return Color(red: 0.30, green: 0.65, blue: 1.0)
        case .building:   return Color(red: 0.55, green: 0.75, blue: 0.35)
        case .decoration: return Color(red: 0.90, green: 0.50, blue: 0.85)
        case .toy:        return Color(red: 1.0,  green: 0.78, blue: 0.20)
        }
    }

    // Legacy emoji
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
    var id: UUID
    var name: String
    var sfSymbol: String       // SF Symbol name for display
    var symbolColor: Color     // tint color for the SF Symbol
    var category: ItemCategory
    var price: Int
    var description: String
    var hungerBoost: Int
    var thirstBoost: Int
    var moodBoost: Int
    var isPlaceable: Bool

    // Codable support for Color
    enum CodingKeys: String, CodingKey {
        case id, name, sfSymbol, category, price, description
        case hungerBoost, thirstBoost, moodBoost, isPlaceable
        case symbolColorR, symbolColorG, symbolColorB
    }

    init(id: UUID, name: String, sfSymbol: String, symbolColor: Color,
         category: ItemCategory, price: Int, description: String,
         hungerBoost: Int, thirstBoost: Int, moodBoost: Int, isPlaceable: Bool) {
        self.id = id
        self.name = name
        self.sfSymbol = sfSymbol
        self.symbolColor = symbolColor
        self.category = category
        self.price = price
        self.description = description
        self.hungerBoost = hungerBoost
        self.thirstBoost = thirstBoost
        self.moodBoost = moodBoost
        self.isPlaceable = isPlaceable
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(UUID.self,          forKey: .id)
        name        = try c.decode(String.self,        forKey: .name)
        sfSymbol    = try c.decode(String.self,        forKey: .sfSymbol)
        category    = try c.decode(ItemCategory.self,  forKey: .category)
        price       = try c.decode(Int.self,           forKey: .price)
        description = try c.decode(String.self,        forKey: .description)
        hungerBoost = try c.decode(Int.self,           forKey: .hungerBoost)
        thirstBoost = try c.decode(Int.self,           forKey: .thirstBoost)
        moodBoost   = try c.decode(Int.self,           forKey: .moodBoost)
        isPlaceable = try c.decode(Bool.self,          forKey: .isPlaceable)
        let r = try c.decodeIfPresent(Double.self, forKey: .symbolColorR) ?? 1
        let g = try c.decodeIfPresent(Double.self, forKey: .symbolColorG) ?? 0.6
        let b = try c.decodeIfPresent(Double.self, forKey: .symbolColorB) ?? 0.2
        symbolColor = Color(red: r, green: g, blue: b)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,          forKey: .id)
        try c.encode(name,        forKey: .name)
        try c.encode(sfSymbol,    forKey: .sfSymbol)
        try c.encode(category,    forKey: .category)
        try c.encode(price,       forKey: .price)
        try c.encode(description, forKey: .description)
        try c.encode(hungerBoost, forKey: .hungerBoost)
        try c.encode(thirstBoost, forKey: .thirstBoost)
        try c.encode(moodBoost,   forKey: .moodBoost)
        try c.encode(isPlaceable, forKey: .isPlaceable)
        // Encode color as RGB doubles
        let ui = UIColor(symbolColor)
        var r: CGFloat = 1, g: CGFloat = 0.6, b: CGFloat = 0.2, a: CGFloat = 1
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        try c.encode(Double(r), forKey: .symbolColorR)
        try c.encode(Double(g), forKey: .symbolColorG)
        try c.encode(Double(b), forKey: .symbolColorB)
    }

    static func == (lhs: StoreItem, rhs: StoreItem) -> Bool { lhs.id == rhs.id }
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

// MARK: - Shop Catalog  (fixed UUIDs so persistence stays stable across launches)
extension StoreItem {
    static let catalog: [StoreItem] = [
        // Food
        .make("11111111-0001-0001-0001-000000000001", "小鱼干",   "fish.fill",
              Color(red:0.30,green:0.65,blue:0.90), .food, 1, "宠物最爱的零食",
              hunger:20, thirst:0,  mood:10, placeable:false),
        .make("11111111-0001-0001-0001-000000000002", "猫粮狗粮", "fork.knife",
              Color(red:0.85,green:0.55,blue:0.25), .food, 2, "营养丰富的主食",
              hunger:40, thirst:0,  mood:5,  placeable:false),
        .make("11111111-0001-0001-0001-000000000003", "小蛋糕",   "birthday.cake.fill",
              Color(red:1.00,green:0.55,blue:0.65), .food, 3, "特别的甜蜜零食",
              hunger:30, thirst:0,  mood:20, placeable:false),

        // Water
        .make("11111111-0001-0001-0001-000000000004", "清水",     "drop.fill",
              Color(red:0.40,green:0.70,blue:1.00), .water, 1, "新鲜干净的水",
              hunger:0,  thirst:25, mood:5,  placeable:false),
        .make("11111111-0001-0001-0001-000000000005", "牛奶",     "cup.and.saucer.fill",
              Color(red:0.95,green:0.90,blue:0.80), .water, 2, "香浓好喝的牛奶",
              hunger:5,  thirst:30, mood:10, placeable:false),

        // Toys
        .make("11111111-0001-0001-0001-000000000006", "毛线球",   "circle.dashed.inset.filled",
              Color(red:1.00,green:0.55,blue:0.65), .toy, 2, "让宠物开心的玩具",
              hunger:0,  thirst:0,  mood:20, placeable:true),
        .make("11111111-0001-0001-0001-000000000007", "小皮球",   "circle.fill",
              Color(red:1.00,green:0.65,blue:0.20), .toy, 3, "蹦蹦跳跳好快乐",
              hunger:0,  thirst:0,  mood:25, placeable:true),

        // Building
        .make("11111111-0001-0001-0001-000000000008", "食盆",     "tray.fill",
              Color(red:0.75,green:0.55,blue:0.35), .building, 3, "宠物专属的饭碗",
              hunger:0,  thirst:0,  mood:5,  placeable:true),
        .make("11111111-0001-0001-0001-000000000009", "水盆",     "drop.circle.fill",
              Color(red:0.40,green:0.70,blue:1.00), .building, 3, "专属饮水盆",
              hunger:0,  thirst:0,  mood:5,  placeable:true),
        .make("11111111-0001-0001-0001-000000000010", "小窝",     "house.fill",
              Color(red:0.90,green:0.70,blue:0.45), .building, 5, "温暖舒适的小家",
              hunger:0,  thirst:0,  mood:15, placeable:true),
        .make("11111111-0001-0001-0001-000000000011", "栅栏",     "square.split.2x1.fill",
              Color(red:0.75,green:0.62,blue:0.48), .building, 2, "漂亮的小栅栏",
              hunger:0,  thirst:0,  mood:2,  placeable:true),

        // Decorations
        .make("11111111-0001-0001-0001-000000000012", "小花",     "leaf.fill",
              Color(red:1.00,green:0.55,blue:0.70), .decoration, 1, "美丽的小花朵",
              hunger:0,  thirst:0,  mood:3,  placeable:true),
        .make("11111111-0001-0001-0001-000000000013", "大树",     "tree.fill",
              Color(red:0.30,green:0.70,blue:0.35), .decoration, 4, "可以乘凉的大树",
              hunger:0,  thirst:0,  mood:5,  placeable:true),
        .make("11111111-0001-0001-0001-000000000014", "彩虹桥",   "sun.and.horizon.fill",
              Color(red:1.00,green:0.78,blue:0.20), .decoration, 5, "雨后漂亮的彩虹",
              hunger:0,  thirst:0,  mood:10, placeable:true),
        .make("11111111-0001-0001-0001-000000000015", "小蘑菇",   "circle.hexagongrid.fill",
              Color(red:0.85,green:0.45,blue:0.30), .decoration, 2, "可爱的小蘑菇",
              hunger:0,  thirst:0,  mood:3,  placeable:true),
    ]

    private static func make(
        _ uuidStr: String, _ name: String, _ symbol: String,
        _ color: Color, _ cat: ItemCategory, _ price: Int, _ desc: String,
        hunger: Int, thirst: Int, mood: Int, placeable: Bool
    ) -> StoreItem {
        StoreItem(
            id: UUID(uuidString: uuidStr)!,
            name: name, sfSymbol: symbol, symbolColor: color,
            category: cat, price: price, description: desc,
            hungerBoost: hunger, thirstBoost: thirst, moodBoost: mood,
            isPlaceable: placeable
        )
    }
}
