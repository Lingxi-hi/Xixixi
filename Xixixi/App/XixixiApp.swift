import SwiftUI

@main
struct XixixiApp: App {
    @StateObject private var gameStore = GameStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(gameStore)
        }
    }
}
