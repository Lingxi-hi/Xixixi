import SwiftUI

// MARK: - Build / Garden Layout View (横屏)
struct BuildView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedInventoryItem: StoreItem? = nil
    @State private var placedFeedback: String?           = nil

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // ── 左侧：花园画布（占大部分宽度）──
                gardenCanvas
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ── 右侧：背包面板 ──
                inventoryPanel
                    .frame(width: 160)
            }
            .background(Color.xBackground)
            .navigationTitle("布置家园")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "hammer.fill")
                        .foregroundStyle(Color(red:0.40, green:0.72, blue:0.40))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.xPrimary)
                }
            }
            .overlay(
                Group {
                    if let msg = placedFeedback {
                        Text(msg)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(Color.xSecondary)
                            .clipShape(Capsule())
                            .transition(.scale.combined(with: .opacity))
                            .padding(.top, 12)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .allowsHitTesting(false)
                    }
                }
            )
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - 花园画布
    private var gardenCanvas: some View {
        GeometryReader { geo in
            ZStack {
                // 天空
                LinearGradient(colors: store.currentSeason.skyGradient,
                               startPoint: .top, endPoint: .center)

                // 草地
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .fill(store.currentSeason.grassColor)
                        .frame(height: geo.size.height * 0.42)
                }

                // 已放置物品
                ForEach(store.homeItems) { item in
                    draggableItem(item: item, in: geo.size)
                }

                // 宠物预览
                Image(systemName: store.pet.type.sfSymbol)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(store.pet.type.bodyColor)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.58)

                // 放置提示
                if let selected = selectedInventoryItem {
                    dropHint(selected, in: geo.size)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                if let item = selectedInventoryItem { placeItem(item, at: location) }
            }
        }
    }

    private func draggableItem(item: HomeItem, in size: CGSize) -> some View {
        Image(systemName: item.storeItem.sfSymbol)
            .font(.system(size: 28, weight: .semibold))
            .foregroundStyle(item.storeItem.symbolColor)
            .shadow(color: .black.opacity(0.10), radius: 2, x: 0, y: 1)
            .position(
                x: max(20, min(size.width  - 20, item.positionX)),
                y: max(20, min(size.height - 20, item.positionY))
            )
            .gesture(DragGesture().onEnded { store.moveItem(item, to: $0.location) })
            .contextMenu {
                Button(role: .destructive) {
                    withAnimation { store.removeHomeItem(item) }
                } label: {
                    Label("移走", systemImage: "trash")
                }
            }
    }

    private func dropHint(_ item: StoreItem, in size: CGSize) -> some View {
        VStack(spacing: 4) {
            Image(systemName: item.sfSymbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(item.symbolColor)
            Text("点击草地放置")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color.black.opacity(0.38))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .position(x: size.width / 2, y: 38)
    }

    // MARK: - 右侧背包面板（竖向滚动）
    private var inventoryPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Panel header
            HStack {
                Image(systemName: "bag.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.xPrimary)
                Text("背包")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 6)

            if selectedInventoryItem != nil {
                Button("取消选择") { selectedInventoryItem = nil }
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color.xAccent)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
            }

            Divider()

            if store.inventory.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.xSubtext.opacity(0.35))
                    Text("背包是空的")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                    Text("去商店购买吧")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color.xSubtext.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(store.inventory) { item in
                            inventoryCard(item)
                        }
                    }
                    .padding(10)
                }
            }
        }
        .background(Color.xCard.opacity(0.96))
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(width: 1),
            alignment: .leading
        )
    }

    private func inventoryCard(_ item: StoreItem) -> some View {
        let isSelected = selectedInventoryItem?.id == item.id
        return Button(action: {
            withAnimation(.bouncy) {
                selectedInventoryItem = isSelected ? nil : item
            }
        }) {
            VStack(spacing: 5) {
                Image(systemName: item.sfSymbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(item.symbolColor)
                Text(item.name)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.xPrimary.opacity(0.16) : Color.xBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.xPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func placeItem(_ item: StoreItem, at position: CGPoint) {
        store.placeItem(item, at: position)
        selectedInventoryItem = nil
        withAnimation(.bouncy) { placedFeedback = "\(item.name) 放好了！" }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { placedFeedback = nil }
        }
    }
}
