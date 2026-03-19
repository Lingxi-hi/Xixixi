import SwiftUI

// MARK: - Main Garden (横屏主界面)
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
            // Sky background (全屏)
            LinearGradient(
                colors: store.currentSeason.skyGradient,
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            // Weather particles
            WeatherOverlayView(weather: store.currentWeather)

            // Grass ground
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(store.currentSeason.grassColor)
                    .frame(height: 200)
                    .overlay(grassDecoration, alignment: .topLeading)
            }
            .ignoresSafeArea(edges: .bottom)

            // 横屏布局：左侧导航栏 + 右侧顶部信息栏 + 中央花园
            HStack(spacing: 0) {
                // ── 左侧竖向导航栏 ──
                leftSidebar

                // ── 中央花园 ──
                ZStack {
                    // 放置物品
                    gardenItemsLayer

                    // 宠物（偏右居中）
                    PetAnimationView(pet: store.pet, size: 110) {
                        showPetSheet = true
                    }
                    .offset(x: 40, y: -20)

                    // 金币飞出动画
                    if store.showCoinAnimation {
                        CoinFlyView(delta: store.lastCoinDelta)
                            .offset(x: 40, y: -120)
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ── 右侧信息面板 ──
                rightInfoPanel
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

    // MARK: - 左侧导航栏
    private var leftSidebar: some View {
        VStack(spacing: 6) {
            // 家长入口（顶部）
            Button(action: onParentTap) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.xSubtext)
                    .frame(width: 50, height: 50)
                    .background(Color.xCard.opacity(0.85))
                    .clipShape(Circle())
            }
            .padding(.bottom, 6)

            Divider().frame(width: 40).opacity(0.3)

            // 四个主导航按钮
            navButton(symbol: "bag.fill",
                      color: Color(red:1.0, green:0.55, blue:0.20),
                      label: "商店")       { activeSheet = .shop  }

            navButton(symbol: "hammer.fill",
                      color: Color(red:0.40, green:0.72, blue:0.40),
                      label: "建造")       { activeSheet = .build }

            navButton(symbol: "list.bullet.clipboard.fill",
                      color: Color(red:0.35, green:0.65, blue:1.0),
                      label: "任务")       { activeSheet = .tasks }
                .overlay(taskBadge, alignment: .topTrailing)

            navButton(symbol: "trophy.fill",
                      color: Color(red:1.0, green:0.78, blue:0.20),
                      label: "成就")       { activeSheet = .album }

            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 6)
        .frame(width: 72)
        .background(
            Color.xCard.opacity(0.88)
                .ignoresSafeArea(edges: .vertical)
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(width: 1),
            alignment: .trailing
        )
    }

    private func navButton(symbol: String, color: Color, label: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            .frame(width: 56, height: 56)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var taskBadge: some View {
        let n = store.dailyTasks.filter { !$0.isApproved }.count
        return Group {
            if n > 0 {
                Text("\(n)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(3)
                    .background(Color.xDanger)
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }
        }
    }

    // MARK: - 右侧信息面板
    private var rightInfoPanel: some View {
        VStack(spacing: 10) {
            // 金币
            CoinBadgeView(coins: store.coins)

            // 季节天气
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: store.currentSeason.sfSymbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(store.currentSeason.symbolColor)
                    Text(store.currentSeason.displayName)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.xText)
                }
                HStack(spacing: 4) {
                    Image(systemName: store.currentWeather.sfSymbol)
                        .font(.system(size: 12))
                        .foregroundStyle(store.currentWeather.symbolColor)
                    Text(store.currentWeather.displayName)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }
            .padding(8)
            .cardStyle(cornerRadius: 14)

            // 宠物状态迷你栏
            petMiniStatus

            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 8)
        .frame(width: 120)
        .background(
            Color.xCard.opacity(0.88)
                .ignoresSafeArea(edges: .vertical)
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(width: 1),
            alignment: .leading
        )
    }

    private var petMiniStatus: some View {
        VStack(spacing: 6) {
            Text(store.pet.name)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color.xText)
                .lineLimit(1)

            miniBar(symbol: "fork.knife", value: store.pet.hunger,    color: .orange)
            miniBar(symbol: "drop.fill",  value: store.pet.thirst,    color: .blue)
            miniBar(symbol: "heart.fill", value: store.pet.moodScore, color: .pink)
        }
        .padding(8)
        .cardStyle(cornerRadius: 14)
    }

    private func miniBar(symbol: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 9))
                .foregroundStyle(color)
                .frame(width: 12)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.18))
                    Capsule().fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                        .animation(.gentle, value: value)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - 草地装饰
    private var grassDecoration: some View {
        let plants: [(String, Color)] = [
            ("leaf.fill",       Color(red: 0.35, green: 0.75, blue: 0.40)),
            ("leaf.fill",       Color(red: 0.45, green: 0.80, blue: 0.30)),
            ("staroflife.fill", Color(red: 0.95, green: 0.55, blue: 0.70)),
            ("leaf.fill",       Color(red: 0.30, green: 0.70, blue: 0.45)),
            ("leaf.fill",       Color(red: 0.40, green: 0.78, blue: 0.35)),
        ]
        return HStack(spacing: 18) {
            ForEach(plants.indices, id: \.self) { i in
                Image(systemName: plants[i].0)
                    .font(.system(size: 18))
                    .foregroundStyle(plants[i].1)
            }
        }
        .padding(.top, -10)
        .padding(.leading, 20)
    }

    // MARK: - 花园物品
    private var gardenItemsLayer: some View {
        ZStack {
            ForEach(store.homeItems) { item in
                Image(systemName: item.storeItem.sfSymbol)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(item.storeItem.symbolColor)
                    .shadow(color: .black.opacity(0.10), radius: 2, x: 0, y: 1)
                    .position(x: item.positionX, y: item.positionY)
                    .gesture(
                        DragGesture()
                            .onEnded { store.moveItem(item, to: $0.location) }
                    )
            }
        }
    }
}
