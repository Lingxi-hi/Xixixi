import SwiftUI

// MARK: - Task Management View (家长端 - 今日任务管理)
struct TaskManagementView: View {
    @EnvironmentObject var store: GameStore

    @State private var showAddTask    = false
    @State private var showTemplates  = false
    @State private var editingTask: DailyTask? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.xBackground.ignoresSafeArea()

                List {
                    // Capacity header
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

                    // Task list
                    Section("任务列表") {
                        if store.dailyTasks.isEmpty {
                            Text("还没有任务，点击下方添加")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color.xSubtext)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .listRowBackground(Color.xCard)
                        }
                        ForEach(store.dailyTasks) { task in
                            ParentTaskRow(task: task) {
                                editingTask = task
                            }
                            .listRowBackground(Color.xCard)
                        }
                        .onDelete { store.removeTask(at: $0) }
                        .onMove { from, to in
                            store.dailyTasks.move(fromOffsets: from, toOffset: to)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("📝 今日任务管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("模板") { showTemplates = true }
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTask = true }) {
                        Label("添加", systemImage: "plus.circle.fill")
                    }
                    .disabled(store.dailyTasks.count >= 5)
                    .foregroundColor(store.dailyTasks.count >= 5 ? Color.gray : Color.xPrimary)
                }
            }
            .sheet(isPresented: $showAddTask) {
                TaskEditSheet(task: nil) { newTask in
                    store.addTask(newTask)
                }
            }
            .sheet(item: $editingTask) { task in
                TaskEditSheet(task: task) { updated in
                    store.updateTask(updated)
                }
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
            Text(task.category.emoji).font(.system(size: 22))

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.xText)
                HStack(spacing: 6) {
                    Text("🪙 \(task.reward)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.xCoin)
                    Text(task.category.displayName)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }

            Spacer()

            // Status badge
            statusBadge

            Button(action: onEdit) {
                Image(systemName: "pencil.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color.xSubtext)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if task.isApproved {
            Text("✓ 已确认")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color.xSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.xSecondary.opacity(0.15))
                .clipShape(Capsule())
        } else if task.isPending {
            Text("待审核")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color.xPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
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

    @State private var title: String = ""
    @State private var category: TaskCategory = .hygiene
    @State private var reward: Int = 1

    var isEditing: Bool { task != nil }

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
                            Label(cat.displayName, systemImage: "")
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("金币奖励") {
                    Stepper("\(reward) 🪙", value: $reward, in: 1...3)
                        .font(.system(size: 16, design: .rounded))
                    Text("奖励范围：1–3 金币")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.xSubtext)
                }
            }
            .navigationTitle(isEditing ? "编辑任务" : "添加任务")
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
                if let task = task {
                    title    = task.title
                    category = task.category
                    reward   = task.reward
                }
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var newTask = task ?? DailyTask(title: trimmed, category: category, reward: reward)
        newTask.title    = trimmed
        newTask.category = category
        newTask.reward   = reward
        onSave(newTask)
        dismiss()
    }
}

// MARK: - Task Templates View
struct TaskTemplatesView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("点击任务可直接添加到今日任务") {
                    ForEach(DailyTask.templates) { template in
                        Button(action: { addTemplate(template) }) {
                            HStack {
                                Text(template.category.emoji).font(.system(size: 22))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color.xText)
                                    Text("🪙 \(template.reward)  ·  \(template.category.displayName)")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(Color.xSubtext)
                                }
                                Spacer()
                                let alreadyAdded = store.dailyTasks.contains { $0.title == template.title }
                                if alreadyAdded {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.xSecondary)
                                } else {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(Color.xPrimary)
                                }
                            }
                        }
                        .disabled(store.dailyTasks.count >= 5 || store.dailyTasks.contains { $0.title == template.title })
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("任务模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(Color.xPrimary)
                }
            }
        }
    }

    private func addTemplate(_ template: DailyTask) {
        guard store.dailyTasks.count < 5 else { return }
        let newTask = DailyTask(title: template.title, category: template.category, reward: template.reward)
        store.addTask(newTask)
    }
}
