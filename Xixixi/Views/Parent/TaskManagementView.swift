import SwiftUI

// MARK: - Task Management View
struct TaskManagementView: View {
    @EnvironmentObject var store: GameStore
    @State private var showAddTask   = false
    @State private var showTemplates = false
    @State private var editingTask: DailyTask? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()
                List {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("今日任务")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.xText)
                                Text("最多5个，完成可获得金币奖励")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(Color.xSubtext)
                            }
                            Spacer()
                            Text("\(store.dailyTasks.count)/5")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(store.dailyTasks.count >= 5 ? Color.xDanger : Color.xPrimary)
                        }
                        .listRowBackground(Color.xCard)
                    }

                    Section("任务列表") {
                        if store.dailyTasks.isEmpty {
                            Text("还没有任务，点击右上角 + 添加")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color.xSubtext)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .listRowBackground(Color.xCard)
                        }
                        ForEach(store.dailyTasks) { task in
                            ParentTaskRow(task: task) { editingTask = task }
                                .listRowBackground(Color.xCard)
                        }
                        .onDelete { store.removeTask(at: $0) }
                        .onMove { from, to in store.dailyTasks.move(fromOffsets: from, toOffset: to) }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("今日任务管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showTemplates = true }) {
                        Label("模板", systemImage: "doc.text.fill")
                            .font(.system(size: 13, design: .rounded))
                    }
                    .foregroundColor(Color.xSubtext)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }
                    .disabled(store.dailyTasks.count >= 5)
                    .foregroundColor(store.dailyTasks.count >= 5 ? Color.gray : Color.xPrimary)
                }
            }
            .sheet(isPresented: $showAddTask) {
                TaskEditSheet(task: nil) { store.addTask($0) }
            }
            .sheet(item: $editingTask) { task in
                TaskEditSheet(task: task) { store.updateTask($0) }
            }
            .sheet(isPresented: $showTemplates) {
                TaskTemplatesView()
            }
        }
    }
}

// MARK: - Parent Task Row
struct ParentTaskRow: View {
    let task: DailyTask
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.category.sfSymbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(task.category.symbolColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                HStack(spacing: 4) {
                    CoinIcon(size: 12)
                    Text("\(task.reward)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.xCoin)
                    Text("·")
                        .foregroundColor(Color.xSubtext)
                    Text(task.category.displayName)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }

            Spacer()
            statusBadge

            Button(action: onEdit) {
                Image(systemName: "pencil.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.xSubtext)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if task.isApproved {
            Label("已确认", systemImage: "checkmark.circle.fill")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color.xSecondary)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Color.xSecondary.opacity(0.15))
                .clipShape(Capsule())
        } else if task.isPending {
            Label("待审核", systemImage: "clock.fill")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color.xPrimary)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Color.xPrimary.opacity(0.15))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Task Edit Sheet
struct TaskEditSheet: View {
    @Environment(\.dismiss) var dismiss
    let task: DailyTask?
    let onSave: (DailyTask) -> Void

    @State private var title:    String       = ""
    @State private var category: TaskCategory = .hygiene
    @State private var reward:   Int          = 1

    var body: some View {
        NavigationView {
            Form {
                Section("任务内容") {
                    TextField("例如：早上刷牙", text: $title)
                        .font(.system(size: 16, design: .rounded))
                }
                Section("任务类型") {
                    Picker("类型", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.sfSymbol).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("金币奖励") {
                    Stepper(value: $reward, in: 1...3) {
                        HStack(spacing: 4) {
                            CoinIcon(size: 14)
                            Text("\(reward)")
                                .font(.system(size: 16, design: .rounded))
                        }
                    }
                    Text("奖励范围：1–3 金币")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }
            .navigationTitle(task != nil ? "编辑任务" : "添加任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.xPrimary)
                }
            }
            .onAppear {
                if let t = task { title = t.title; category = t.category; reward = t.reward }
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var t = task ?? DailyTask(title: trimmed, category: category, reward: reward)
        t.title = trimmed; t.category = category; t.reward = reward
        onSave(t); dismiss()
    }
}

// MARK: - Task Templates View
struct TaskTemplatesView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("点击任务直接添加到今日") {
                    ForEach(DailyTask.templates) { template in
                        let added = store.dailyTasks.contains { $0.title == template.title }
                        Button(action: { addTemplate(template) }) {
                            HStack {
                                Image(systemName: template.category.sfSymbol)
                                    .font(.system(size: 20))
                                    .foregroundStyle(template.category.symbolColor)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(added ? Color.xSubtext : Color.xText)
                                    HStack(spacing: 4) {
                                        CoinIcon(size: 11)
                                        Text("\(template.reward)  ·  \(template.category.displayName)")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Color.xSubtext)
                                    }
                                }
                                Spacer()
                                Image(systemName: added ? "checkmark.circle.fill" : "plus.circle")
                                    .foregroundColor(added ? Color.xSecondary : Color.xPrimary)
                            }
                        }
                        .disabled(store.dailyTasks.count >= 5 || added)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("任务模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }.foregroundColor(Color.xPrimary)
                }
            }
        }
    }

    private func addTemplate(_ template: DailyTask) {
        guard store.dailyTasks.count < 5 else { return }
        store.addTask(DailyTask(title: template.title, category: template.category, reward: template.reward))
    }
}
