import SwiftUI

// MARK: - Store View (商店页)
struct StoreView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: ItemCategory? = nil
    @State private var purchasedItem: StoreItem?       = nil
    @State private var showPurchaseSuccess             = false
    @State private var showInsufficientCoins           = false

    var filteredItems: [StoreItem] {
        guard let cat = selectedCategory else { return StoreItem.catalog }
        return StoreItem.catalog.filter { $0.category == cat }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Coin row
                    HStack {
                        Text("你的金币")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color.xSubtext)
                        Spacer()
                        CoinBadgeView(coins: store.coins)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            categoryChip(nil, label: "全部", symbol: "square.grid.2x2.fill",
                                         color: Color.xSubtext)
                            ForEach(ItemCategory.allCases, id: \.self) { cat in
                                categoryChip(cat, label: cat.displayName,
                                             symbol: cat.sfSymbol, color: cat.symbolColor)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }

                    // Item grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 150), spacing: 14)],
                            spacing: 14
                        ) {
                            ForEach(filteredItems) { item in
                                StoreItemCard(
                                    item: item,
                                    canAfford: store.canAfford(item),
                                    onBuy: { purchase(item) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }

                // Success overlay
                if showPurchaseSuccess, let item = purchasedItem {
                    purchaseSuccessOverlay(item: item)
                }

                if showInsufficientCoins {
                    insufficientCoinsOverlay
                }
            }
            .navigationTitle("商店")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "bag.fill")
                        .foregroundStyle(Color(red:1.0, green:0.55, blue:0.20))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(Color.xPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
    }

    // MARK: - Category chip
    private func categoryChip(_ category: ItemCategory?, label: String,
                               symbol: String, color: Color) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: { selectedCategory = category }) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : color)
                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color.xText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.xPrimary : Color.xCard)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Purchase
    private func purchase(_ item: StoreItem) {
        guard store.canAfford(item) else {
            withAnimation(.bouncy) { showInsufficientCoins = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { showInsufficientCoins = false }
            }
            return
        }
        store.purchase(item)
        purchasedItem = item
        withAnimation(.bouncy) { showPurchaseSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { showPurchaseSuccess = false }
        }
    }

    // MARK: - Overlays
    private func purchaseSuccessOverlay(item: StoreItem) -> some View {
        VStack(spacing: 12) {
            Image(systemName: item.sfSymbol)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(item.symbolColor)
                .scaleEffect(showPurchaseSuccess ? 1.0 : 0.4)

            Text("买到了！\(item.name)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if item.isPlaceable {
                Text("在「建造」里摆放它吧～")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(30)
        .background(Color.xSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        .transition(.scale.combined(with: .opacity))
    }

    private var insufficientCoinsOverlay: some View {
        VStack(spacing: 10) {
            CoinIcon(size: 44)
            Text("金币不够哦～")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("完成任务可以获得更多金币！")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(28)
        .background(Color.xDanger)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Store Item Card
struct StoreItemCard: View {
    let item: StoreItem
    let canAfford: Bool
    let onBuy: () -> Void
    @State private var tapped = false

    var body: some View {
        Button(action: {
            withAnimation(.bouncy) { tapped = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { tapped = false }
            onBuy()
        }) {
            VStack(spacing: 10) {
                // Item icon
                ZStack {
                    Circle()
                        .fill(item.symbolColor.opacity(0.15))
                        .frame(width: 70, height: 70)
                    Image(systemName: item.sfSymbol)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(item.symbolColor)
                }

                // Name
                Text(item.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)

                // Description
                Text(item.description)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Color.xSubtext)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Boost indicators
                HStack(spacing: 4) {
                    if item.hungerBoost > 0 {
                        boostPill("fork.knife", value: item.hungerBoost, color: .orange)
                    }
                    if item.thirstBoost > 0 {
                        boostPill("drop.fill",  value: item.thirstBoost, color: .blue)
                    }
                    if item.moodBoost > 0 {
                        boostPill("heart.fill", value: item.moodBoost,  color: .pink)
                    }
                }

                // Price
                HStack(spacing: 4) {
                    CoinIcon(size: 14)
                    Text("\(item.price)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(canAfford ? .white : Color.xSubtext)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(canAfford ? Color.xPrimary : Color.gray.opacity(0.3))
                .clipShape(Capsule())
            }
            .padding(14)
            .cardStyle()
            .opacity(canAfford ? 1.0 : 0.7)
            .scaleEffect(tapped ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func boostPill(_ symbol: String, value: Int, color: Color) -> some View {
        HStack(spacing: 2) {
            Image(systemName: symbol).font(.system(size: 9))
            Text("+\(value)").font(.system(size: 9, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}
