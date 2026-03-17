import SwiftUI

// MARK: - Root View (decides child vs parent mode)
struct RootView: View {
    @EnvironmentObject var store: GameStore

    // Whether the parent unlock sheet is presented
    @State private var showParentUnlock = false

    var body: some View {
        ZStack {
            if store.isParentMode {
                // Parent mode
                ParentHomeView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal:   .move(edge: .trailing)
                    ))
            } else {
                // Child mode (main game)
                MainGardenView(onParentTap: {
                    showParentUnlock = true
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal:   .move(edge: .leading)
                ))
            }
        }
        .animation(.gentle, value: store.isParentMode)
        // Parent unlock sheet
        .sheet(isPresented: $showParentUnlock) {
            ParentUnlockView(isShowing: $showParentUnlock)
        }
        // Auto-exit parent mode when store flag changes
        .onChange(of: store.isParentMode) { isParent in
            if !isParent {
                showParentUnlock = false
            }
        }
    }
}
