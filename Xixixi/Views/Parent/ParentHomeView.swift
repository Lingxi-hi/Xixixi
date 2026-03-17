import SwiftUI

// MARK: - Parent Home View (家长端入口)
struct ParentHomeView: View {
    @EnvironmentObject var store: GameStore
    @State private var activeTab: ParentTab = .tasks

    enum ParentTab: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        case tasks      = "tasks"
        case pending    = "pending"
        case redlines   = "redlines"
        case settlement = "settlement"
        case history    = "history"
        case settings   = "settings"

        var label: String {
            switch self {
            case .tasks:      return "今日任务"
            case .pending:    return "待确认"
            case .redlines:   return "红线"
            case .settlement: return "今日结算"
            case .history:    return "历史记录"
            case .settings:   return "设置"
            }
        }

        var emoji: String {
            switch self {
            case .tasks:      return "📝"
            case .pending:    return "⏳"
            case .redlines:   return "🚨"
            case .settlement: return "💰"
            case .history:    return "📊"
            case .settings:   return "⚙️"
            }
        }
    }

    var body: some View {
        TabView(selection: $activeTab) {
            TaskManagementView()
                .tabItem { Label(ParentTab.tasks.label, systemImage: "list.bullet.clipboard") }
                .tag(ParentTab.tasks)

            PendingApprovalView()
                .tabItem { Label(ParentTab.pending.label, systemImage: "clock.badge.checkmark") }
                .badge(store.pendingTasks.count)
                .tag(ParentTab.pending)

            RedLineView()
                .tabItem { Label(ParentTab.redlines.label, systemImage: "exclamationmark.triangle") }
                .tag(ParentTab.redlines)

            DailySettlementView()
                .tabItem { Label(ParentTab.settlement.label, systemImage: "dollarsign.circle") }
                .tag(ParentTab.settlement)

            HistoryView()
                .tabItem { Label(ParentTab.history.label, systemImage: "chart.bar") }
                .tag(ParentTab.history)

            ParentSettingsView()
                .tabItem { Label(ParentTab.settings.label, systemImage: "gearshape") }
                .tag(ParentTab.settings)
        }
        .accentColor(Color.xPrimary)
    }
}
