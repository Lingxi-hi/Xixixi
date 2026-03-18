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

    // SF Symbol name (iOS 16 / SF Symbols 4)
    var sfSymbol: String {
        switch self {
        case .cat: return "cat"
        case .dog: return "dog"
        }
    }

    // Body tint color
    var bodyColor: Color {
        switch self {
        case .cat: return Color(red: 1.0, green: 0.78, blue: 0.50)
        case .dog: return Color(red: 0.85, green: 0.65, blue: 0.42)
        }
    }

    // Legacy emoji kept for codable compatibility — not used in UI
    var idleEmoji:  String { self == .cat ? "🐱" : "🐶" }
    var happyEmoji: String { self == .cat ? "😸" : "🐕" }
    var sadEmoji:   String { self == .cat ? "😿" : "🐩" }
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
        case .happy:    return "很开心～"
        case .content:  return "还不错哦"
        case .sad:      return "有点难过..."
        case .unhappy:  return "好难过呀..."
        }
    }

    // SF Symbol for mood bubble overlay
    var sfSymbol: String {
        switch self {
        case .ecstatic: return "star.fill"
        case .happy:    return "heart.fill"
        case .content:  return "face.smiling"
        case .sad:      return "cloud.drizzle.fill"
        case .unhappy:  return "cloud.rain.fill"
        }
    }

    var color: Color {
        switch self {
        case .ecstatic: return Color(red: 1.0, green: 0.82, blue: 0.2)
        case .happy:    return Color(red: 0.35, green: 0.80, blue: 0.55)
        case .content:  return Color(red: 0.45, green: 0.78, blue: 0.80)
        case .sad:      return Color(red: 0.60, green: 0.60, blue: 0.65)
        case .unhappy:  return Color(red: 0.45, green: 0.60, blue: 0.85)
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

    var mood: PetMood {
        switch moodScore {
        case 81...100: return .ecstatic
        case 61...80:  return .happy
        case 41...60:  return .content
        case 21...40:  return .sad
        default:       return .unhappy
        }
    }

    var needsFood:  Bool { hunger    < 40 }
    var needsWater: Bool { thirst    < 40 }
    var needsLove:  Bool { moodScore < 40 }

    var overallStatus: Int { (hunger + thirst + moodScore) / 3 }

    static func makeDefault(type: PetType = .cat, name: String = "小毛球") -> Pet {
        Pet(type: type, name: name, hunger: 80, thirst: 80, moodScore: 85)
    }
}
