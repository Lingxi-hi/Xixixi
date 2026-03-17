import Foundation
import SwiftUI

// MARK: - Pet Type
enum PetType: String, Codable, CaseIterable {
    case cat = "cat"
    case dog = "dog"

    var displayName: String {
        switch self {
        case .cat: return "小猫咪"
        case .dog: return "小狗狗"
        }
    }

    var idleEmoji: String {
        switch self {
        case .cat: return "🐱"
        case .dog: return "🐶"
        }
    }

    var happyEmoji: String {
        switch self {
        case .cat: return "😸"
        case .dog: return "🐕"
        }
    }

    var sadEmoji: String {
        switch self {
        case .cat: return "😿"
        case .dog: return "🐩"
        }
    }
}

// MARK: - Pet Mood
enum PetMood: String, Codable {
    case ecstatic   // 100–81
    case happy      // 80–61
    case content    // 60–41
    case sad        // 40–21
    case unhappy    // 20–0

    var description: String {
        switch self {
        case .ecstatic: return "超级开心！"
        case .happy: return "很开心～"
        case .content: return "还不错哦"
        case .sad: return "有点难过..."
        case .unhappy: return "好难过呀..."
        }
    }

    var emoji: String {
        switch self {
        case .ecstatic: return "🥰"
        case .happy: return "😊"
        case .content: return "😌"
        case .sad: return "😔"
        case .unhappy: return "😢"
        }
    }

    var color: Color {
        switch self {
        case .ecstatic: return .yellow
        case .happy: return .green
        case .content: return .mint
        case .sad: return .gray
        case .unhappy: return .blue
        }
    }
}

// MARK: - Pet Model
struct Pet: Codable, Identifiable {
    var id: UUID = UUID()
    var type: PetType
    var name: String

    // Status bars (0–100)
    var hunger: Int      // 饱食度
    var thirst: Int      // 饮水度
    var moodScore: Int   // 心情值

    // Computed mood level
    var mood: PetMood {
        switch moodScore {
        case 81...100: return .ecstatic
        case 61...80:  return .happy
        case 41...60:  return .content
        case 21...40:  return .sad
        default:       return .unhappy
        }
    }

    // Whether the pet needs attention
    var needsFood: Bool   { hunger < 40 }
    var needsWater: Bool  { thirst < 40 }
    var needsLove: Bool   { moodScore < 40 }

    // Overall health status affects pet interaction
    var overallStatus: Int {
        (hunger + thirst + moodScore) / 3
    }

    static func makeDefault(type: PetType = .cat, name: String = "小毛球") -> Pet {
        Pet(type: type, name: name, hunger: 80, thirst: 80, moodScore: 85)
    }
}
