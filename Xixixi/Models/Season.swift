import Foundation
import SwiftUI

// MARK: - Season
enum Season: String, Codable, CaseIterable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"

    var displayName: String {
        switch self {
        case .spring: return "春天"
        case .summer: return "夏天"
        case .autumn: return "秋天"
        case .winter: return "冬天"
        }
    }

    var emoji: String {
        switch self {
        case .spring: return "🌸"
        case .summer: return "☀️"
        case .autumn: return "🍂"
        case .winter: return "❄️"
        }
    }

    var grassColor: Color {
        switch self {
        case .spring: return Color(red: 0.56, green: 0.86, blue: 0.45)
        case .summer: return Color(red: 0.36, green: 0.76, blue: 0.25)
        case .autumn: return Color(red: 0.72, green: 0.80, blue: 0.40)
        case .winter: return Color(red: 0.85, green: 0.92, blue: 0.88)
        }
    }

    var skyGradient: [Color] {
        switch self {
        case .spring: return [Color(red: 0.85, green: 0.95, blue: 1.0), Color(red: 0.96, green: 0.88, blue: 0.96)]
        case .summer: return [Color(red: 0.60, green: 0.85, blue: 1.0), Color(red: 0.98, green: 0.92, blue: 0.76)]
        case .autumn: return [Color(red: 1.0,  green: 0.88, blue: 0.70), Color(red: 0.98, green: 0.80, blue: 0.60)]
        case .winter: return [Color(red: 0.85, green: 0.92, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0)]
        }
    }

    // Seasonal special decorations unlocked per season
    var specialDecoration: String {
        switch self {
        case .spring: return "🌷"
        case .summer: return "🌻"
        case .autumn: return "🍁"
        case .winter: return "⛄"
        }
    }

    static func current() -> Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3, 4, 5: return .spring
        case 6, 7, 8: return .summer
        case 9, 10, 11: return .autumn
        default: return .winter
        }
    }
}

// MARK: - Weather
enum Weather: String, Codable, CaseIterable {
    case sunny  = "sunny"
    case cloudy = "cloudy"
    case rainy  = "rainy"
    case snowy  = "snowy"

    var displayName: String {
        switch self {
        case .sunny:  return "晴天"
        case .cloudy: return "多云"
        case .rainy:  return "下雨"
        case .snowy:  return "下雪"
        }
    }

    var emoji: String {
        switch self {
        case .sunny:  return "☀️"
        case .cloudy: return "⛅"
        case .rainy:  return "🌧️"
        case .snowy:  return "🌨️"
        }
    }

    // Weather particle effect symbol
    var particle: String? {
        switch self {
        case .sunny:  return nil
        case .cloudy: return nil
        case .rainy:  return "💧"
        case .snowy:  return "❄️"
        }
    }
}
