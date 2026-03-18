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
            // Sky background
            LinearGradient(
                colors: store.currentSeason.skyGradient,
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            // Weather particles
            WeatherOverlayView(weather: store.currentWeather)

            // Ground / grass
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(store.currentSeason.grassColor)
                    .frame(height: 280)
                    .overlay(grassDecoration, alignment: .topLeading)
            }
            .ignoresSafeArea(edges: .bottom)

            // Placed garden items
            gardenItemsLayer

            // Main pet (center)
            VStack {
                Spacer()
                PetAnimationView(pet: store.pet, size: 110) {
                    showPetSheet = true
                }
                .padding(.bottom, 120)
            }

            // Coin animation overlay
            if store.showCoinAnimation {
                VStack {
                    CoinFlyView(delta: store.lastCoinDelta)
                    Spacer()
                }
                .padding(.top, 140)
                .allowsHitTesting(false)
            }

            // UI overlay
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
        HStack(alignment: .top) {
            // Season / weather info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(store.currentSeason.emoji)
                    Text(store.currentSeason.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.xText)
                }
                HStack(spacing: 4) {
                    Text(store.currentWeather.emoji)
                    Text(store.currentWeather.displayName)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }
            .padding(10)
            .cardStyle(cornerRadius: 16)

            Spacer()

            // Coin badge
            CoinBadgeView(coins: store.coins)

            // Parent entry button (small, tucked in corner)
            Button(action: onParentTap) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.xSubtext)
                    .padding(10)
                    .background(Color.xCard.opacity(0.8))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Bottom navigation
    private var bottomNav: some View {
        HStack(spacing: 12) {
            navButton(emoji: "🛍️", label: "商店")    { activeSheet = .shop  }
            navButton(emoji: "🏗️", label: "建造")    { activeSheet = .build }
            navButton(emoji: "📋", label: "今日任务") { activeSheet = .tasks }
                .overlay(taskBadge, alignment: .topTrailing)
            navButton(emoji: "⭐", label: "成就")    { activeSheet = .album }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color.xCard.opacity(0.95)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func navButton(emoji: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 26))
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
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
                    .offset(x: 4, y: -4)
            }
        }
    }

    // MARK: - Grass decoration
    private var grassDecoration: some View {
        HStack(spacing: 16) {
            ForEach(["🌿", "🌱", "🍀", "🌸"].indices, id: \.self) { i in
                Text(["🌿", "🌱", "🍀", "🌸"][i]).font(.system(size: 20))
            }
        }
        .padding(.top, -12)
        .padding(.leading, 20)
    }

    // MARK: - Garden items
    private var gardenItemsLayer: some View {
        ZStack {
            ForEach(store.homeItems) { item in
                Text(item.storeItem.emoji)
                    .font(.system(size: 36))
                    .position(x: item.positionX, y: item.positionY)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                store.moveItem(item, to: value.location)
                            }
                    )
            }
        }
    }
}
