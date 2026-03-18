import SwiftUI

// MARK: - Build / Garden Layout View (建造/摆放页)
struct BuildView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedInventoryItem: StoreItem? = nil
    @State private var placedFeedback: String?           = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    gardenCanvas
                        .frame(height: 320)

                    Divider().padding(.vertical, 4)

                    inventorySection
                }

                if let msg = placedFeedback {
                    Text(msg)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.xSecondary)
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                        .padding(.top, 20)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
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
        }
    }

    // MARK: - Garden canvas
    private var gardenCanvas: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: store.currentSeason.skyGradient,
                               startPoint: .top, endPoint: .center)

                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .fill(store.currentSeason.grassColor)
                        .frame(height: geo.size.height * 0.45)
                }

                ForEach(store.homeItems) { item in
                    draggableItem(item: item, in: geo.size)
                }

                // Pet preview
                Image(systemName: store.pet.type.sfSymbol)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(store.pet.type.bodyColor)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.60)

                if let selected = selectedInventoryItem {
                    dropZoneHint(selected, in: geo.size)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                if let item = selectedInventoryItem {
                    placeItem(item, at: location)
                }
            }
        }
    }

    private func draggableItem(item: HomeItem, in size: CGSize) -> some View {
        Image(systemName: item.storeItem.sfSymbol)
            .font(.system(size: 30, weight: .semibold))
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

    private func dropZoneHint(_ item: StoreItem, in size: CGSize) -> some View {
        VStack(spacing: 4) {
            Image(systemName: item.sfSymbol)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(item.symbolColor)
            Text("点击草地放置")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color.black.opacity(0.38))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .position(x: size.width / 2, y: 40)
    }

    // MARK: - Inventory section
    private var inventorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("背包")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.xText)
                Spacer()
                if selectedInventoryItem != nil {
                    Button("取消选择") { selectedInventoryItem = nil }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.xAccent)
                }
            }
            .padding(.horizontal, 16)

            if store.inventory.isEmpty {
                emptyInventory
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.inventory) { item in
                            inventoryItemCard(item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private func inventoryItemCard(_ item: StoreItem) -> some View {
        let isSelected = selectedInventoryItem?.id == item.id
        return Button(action: {
            withAnimation(.bouncy) {
                selectedInventoryItem = isSelected ? nil : item
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: item.sfSymbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(item.symbolColor)
                Text(item.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
            }
            .padding(12)
            .background(isSelected ? Color.xPrimary.opacity(0.18) : Color.xCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.xPrimary : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var emptyInventory: some View {
        VStack(spacing: 8) {
            Image(systemName: "bag.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color.xSubtext.opacity(0.4))
            Text("背包是空的～")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color.xSubtext)
            Text("去商店买些建材和装饰品吧！")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color.xSubtext.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    private func placeItem(_ item: StoreItem, at position: CGPoint) {
        store.placeItem(item, at: position)
        selectedInventoryItem = nil
        let msg = "\(item.name) 放好了！"
        withAnimation(.bouncy) { placedFeedback = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { placedFeedback = nil }
        }
    }
}
