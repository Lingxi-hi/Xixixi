import SwiftUI

// MARK: - Main Garden (首页/主家园页)
struct MainGardenView: View {
    @EnvironmentObject var store: GameStore
    var onParentTap: () -> Void

    @State private var activeSheet: ChildSheet? = nil
    @State private var showPetSheet = false

    enum ChildSheet: String, Identifiable {
        var id: String { rawValue }
        case shop, build, tasks, album
    }

    var body: some View {
        ZStack {
            // Sky gradient
            LinearGradient(
                colors: store.currentSeason.skyGradient,
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            // Weather particle overlay
            WeatherOverlayView(weather: store.currentWeather)

            // Grass ground
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(store.currentSeason.grassColor)
                    .frame(height: 280)
                    .overlay(grassDecoration, alignment: .topLeading)
            }
            .ignoresSafeArea(edges: .bottom)

            // Placed garden items (draggable)
            gardenItemsLayer

            // Pet (center stage)
            VStack {
                Spacer()
                PetAnimationView(pet: store.pet, size: 110) {
                    showPetSheet = true
                }
                .padding(.bottom, 120)
            }

            // Coin fly animation
            if store.showCoinAnimation {
                VStack {
                    CoinFlyView(delta: store.lastCoinDelta)
                    Spacer()
                }
                .padding(.top, 140)
                .allowsHitTesting(false)
            }

            // UI chrome
            VStack {
                topBar
                Spacer()
                bottomNav
            }
        }
        .sheet(isPresented: $showPetSheet) {
            PetInteractionView()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .shop:   StoreView()
            case .build:  BuildView()
            case .tasks:  DailyTasksView()
            case .album:  AchievementView()
            }
        }
        .onAppear {
            store.refreshSeasonAndWeather()
        }
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack(alignment: .top, spacing: 10) {
            // Season + weather chip
            HStack(spacing: 6) {
                Image(systemName: store.currentSeason.sfSymbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(store.currentSeason.symbolColor)
                Text(store.currentSeason.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                Image(systemName: store.currentWeather.sfSymbol)
                    .font(.system(size: 13))
                    .foregroundStyle(store.currentWeather.symbolColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .cardStyle(cornerRadius: 14)

            Spacer()

            // Coin badge
            CoinBadgeView(coins: store.coins)

            // Parent entry
            Button(action: onParentTap) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.xSubtext)
                    .padding(10)
                    .background(Color.xCard.opacity(0.85))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Bottom navigation (all SF Symbols)
    private var bottomNav: some View {
        HStack(spacing: 0) {
            navButton(symbol: "bag.fill",
                      color: Color(red:1.0, green:0.55, blue:0.20),
                      label: "商店")       { activeSheet = .shop  }
            navButton(symbol: "hammer.fill",
                      color: Color(red:0.40, green:0.72, blue:0.40),
                      label: "建造")       { activeSheet = .build }
            navButton(symbol: "list.bullet.clipboard.fill",
                      color: Color(red:0.35, green:0.65, blue:1.0),
                      label: "今日任务")   { activeSheet = .tasks }
                .overlay(taskBadge, alignment: .topTrailing)
            navButton(symbol: "trophy.fill",
                      color: Color(red:1.0, green:0.78, blue:0.20),
                      label: "成就")       { activeSheet = .album }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color.xCard.opacity(0.96)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func navButton(symbol: String, color: Color, label: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var taskBadge: some View {
        let notDone = store.dailyTasks.filter { !$0.isApproved }.count
        return Group {
            if notDone > 0 {
                Text("\(notDone)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.xDanger)
                    .clipShape(Circle())
                    .offset(x: 2, y: -2)
            }
        }
    }

    // MARK: - Grass decoration (SF Symbols, no emoji)
    private var grassDecoration: some View {
        let plants: [(symbol: String, color: Color)] = [
            ("leaf.fill",   Color(red: 0.35, green: 0.75, blue: 0.40)),
            ("leaf.fill",   Color(red: 0.45, green: 0.80, blue: 0.30)),
            ("staroflife.fill", Color(red: 0.95, green: 0.55, blue: 0.70)),
            ("leaf.fill",   Color(red: 0.30, green: 0.70, blue: 0.45)),
        ]
        return HStack(spacing: 14) {
            ForEach(plants.indices, id: \.self) { i in
                Image(systemName: plants[i].symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(plants[i].color)
            }
        }
        .padding(.top, -10)
        .padding(.leading, 18)
    }

    // MARK: - Garden items layer
    private var gardenItemsLayer: some View {
        ZStack {
            ForEach(store.homeItems) { item in
                Image(systemName: item.storeItem.sfSymbol)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(item.storeItem.symbolColor)
                    .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
                    .position(x: item.positionX, y: item.positionY)
                    .gesture(
                        DragGesture()
                            .onEnded { store.moveItem(item, to: $0.location) }
                    )
            }
        }
    }
}
