import Foundation
import Combine
import SwiftUI

// MARK: - GameStore (Central State Management)
class GameStore: ObservableObject {

    // MARK: - Child-facing state
    @Published var pet: Pet
    @Published var coins: Int
    @Published var homeItems: [HomeItem]
    @Published var inventory: [StoreItem]      // items in bag, ready to place
    @Published var achievements: [Achievement]
    @Published var currentSeason: Season
    @Published var currentWeather: Weather
    @Published var totalCoinsEarned: Int       // lifetime total

    // MARK: - Task / reward state
    @Published var dailyTasks: [DailyTask]     // today's tasks
    @Published var redLines: [RedLine]
    @Published var taskHistory: [DayRecord]

    // MARK: - Parent settings
    @Published var parentPassword: String
    @Published var soundEnabled: Bool
    @Published var isParentMode: Bool = false

    // MARK: - UI state
    @Published var showCoinAnimation: Bool = false
    @Published var lastCoinDelta: Int = 0
    @Published var showPetHappyAnimation: Bool = false

    // MARK: - Persistence key
    private let saveKey = "xixixi_game_state_v1"

    // MARK: - Init
    init() {
        // Try to load from UserDefaults, fall back to defaults
        if let saved = GameStore.loadSavedState() {
            self.pet = saved.pet
            self.coins = saved.coins
            self.homeItems = saved.homeItems
            self.inventory = saved.inventory
            self.achievements = saved.achievements
            self.currentSeason = saved.currentSeason
            self.currentWeather = saved.currentWeather
            self.totalCoinsEarned = saved.totalCoinsEarned
            self.dailyTasks = saved.dailyTasks
            self.redLines = saved.redLines
            self.taskHistory = saved.taskHistory
            self.parentPassword = saved.parentPassword
            self.soundEnabled = saved.soundEnabled
        } else {
            self.pet = Pet.makeDefault()
            self.coins = 5
            self.homeItems = []
            self.inventory = []
            self.achievements = Achievement.allAchievements
            self.currentSeason = Season.current()
            self.currentWeather = .sunny
            self.totalCoinsEarned = 0
            self.dailyTasks = DailyTask.defaults
            self.redLines = RedLine.defaults
            self.taskHistory = []
            self.parentPassword = "1234"
            self.soundEnabled = true
        }
    }

    // MARK: - Task Actions

    func submitTask(_ task: DailyTask) {
        update(task: task) { t in
            t.isSubmitted = true
            t.isRejected = false
            t.submittedAt = Date()
        }
        saveState()
    }

    func approveTask(_ task: DailyTask) {
        update(task: task) { t in
            t.isApproved = true
            t.approvedAt = Date()
        }
        addCoins(task.reward)
        checkAchievements()
        saveState()
    }

    func rejectTask(_ task: DailyTask) {
        update(task: task) { t in
            t.isSubmitted = false
            t.isRejected = true
        }
        saveState()
    }

    var pendingTasks: [DailyTask] {
        dailyTasks.filter { $0.isPending }
    }

    var approvedTasksToday: [DailyTask] {
        dailyTasks.filter { $0.isApproved }
    }

    // MARK: - Red Line Actions

    func triggerRedLine(_ redLine: RedLine) {
        let deducted = min(coins, redLine.penalty)
        coins -= deducted
        // The deduction record goes into today's settlement via saveState
        saveState()
    }

    // MARK: - Store & Inventory

    func canAfford(_ item: StoreItem) -> Bool {
        coins >= item.price
    }

    @discardableResult
    func purchase(_ item: StoreItem) -> Bool {
        guard coins >= item.price else { return false }
        coins -= item.price

        if item.isPlaceable {
            inventory.append(item)
        } else {
            // Consumable – apply immediately
            applyConsumable(item)
        }

        checkAchievements(trigger: "shop_first")
        saveState()
        return true
    }

    private func applyConsumable(_ item: StoreItem) {
        pet.hunger    = min(100, pet.hunger    + item.hungerBoost)
        pet.thirst    = min(100, pet.thirst    + item.thirstBoost)
        pet.moodScore = min(100, pet.moodScore + item.moodBoost)

        if pet.moodScore >= 81 {
            triggerHappyAnimation()
        }
        saveState()
    }

    // MARK: - Home / Garden

    func placeItem(_ item: StoreItem, at position: CGPoint) {
        let homeItem = HomeItem(storeItem: item, position: position)
        homeItems.append(homeItem)
        // Remove from inventory
        if let idx = inventory.firstIndex(of: item) {
            inventory.remove(at: idx)
        }
        pet.moodScore = min(100, pet.moodScore + item.moodBoost)
        checkAchievements(trigger: "first_home_item")
        saveState()
    }

    func moveItem(_ item: HomeItem, to position: CGPoint) {
        if let idx = homeItems.firstIndex(where: { $0.id == item.id }) {
            homeItems[idx].position = position
        }
        saveState()
    }

    func removeHomeItem(_ item: HomeItem) {
        homeItems.removeAll { $0.id == item.id }
        saveState()
    }

    // MARK: - Pet Interaction

    func petThePet() {
        pet.moodScore = min(100, pet.moodScore + 5)
        if pet.moodScore >= 81 { triggerHappyAnimation() }
        saveState()
    }

    func hugPet() {
        pet.moodScore = min(100, pet.moodScore + 10)
        if pet.moodScore >= 81 { triggerHappyAnimation() }
        saveState()
    }

    // MARK: - Daily Settlement

    func doSettlement() {
        let approved = dailyTasks.filter { $0.isApproved }
        let earned = approved.reduce(0) { $0 + $1.reward }
        let record = DayRecord(
            date: Date(),
            tasks: dailyTasks,
            redLineTriggers: [],
            coinsEarned: earned,
            coinsDeducted: 0,
            petMoodAtEnd: pet.moodScore
        )
        taskHistory.insert(record, at: 0)

        // Reset today's tasks for next day
        for i in dailyTasks.indices {
            dailyTasks[i].isSubmitted = false
            dailyTasks[i].isApproved  = false
            dailyTasks[i].isRejected  = false
            dailyTasks[i].submittedAt = nil
            dailyTasks[i].approvedAt  = nil
        }
        saveState()
    }

    // MARK: - Task Management (parent)

    func addTask(_ task: DailyTask) {
        guard dailyTasks.count < 5 else { return }
        dailyTasks.append(task)
        saveState()
    }

    func removeTask(at offsets: IndexSet) {
        dailyTasks.remove(atOffsets: offsets)
        saveState()
    }

    func updateTask(_ task: DailyTask) {
        update(task: task) { t in t = task }
        saveState()
    }

    func addRedLine(_ redLine: RedLine) {
        guard redLines.count < 3 else { return }
        redLines.append(redLine)
        saveState()
    }

    func removeRedLine(at offsets: IndexSet) {
        redLines.remove(atOffsets: offsets)
        saveState()
    }

    // MARK: - Season & Weather

    func refreshSeasonAndWeather() {
        currentSeason = Season.current()
        let weathers: [Weather] = [.sunny, .sunny, .sunny, .cloudy, .cloudy, .rainy]
        currentWeather = weathers.randomElement() ?? .sunny
        if currentSeason == .winter {
            currentWeather = [.snowy, .cloudy, .sunny].randomElement() ?? .sunny
        }
        saveState()
    }

    // MARK: - Achievements

    private func checkAchievements(trigger: String? = nil) {
        // Specific trigger
        if let t = trigger {
            unlockAchievement(id: t)
        }

        // Coin milestones
        if totalCoinsEarned >= 10 { unlockAchievement(id: "coins_10") }
        if totalCoinsEarned >= 50 { unlockAchievement(id: "coins_50") }

        // Pet happiness
        if pet.moodScore >= 81    { unlockAchievement(id: "pet_happy") }

        // Tasks in one day
        if approvedTasksToday.count >= 3 { unlockAchievement(id: "three_tasks_day") }

        // First task ever
        if !taskHistory.isEmpty || !approvedTasksToday.isEmpty {
            unlockAchievement(id: "first_task")
        }

        // 7-day streak
        if consecutiveDays() >= 7 { unlockAchievement(id: "week_streak") }
    }

    private func unlockAchievement(id: String) {
        guard let idx = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) else { return }
        achievements[idx].isUnlocked = true
        achievements[idx].unlockedAt = Date()
    }

    private func consecutiveDays() -> Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        for record in taskHistory.sorted(by: { $0.date > $1.date }) {
            let recordDay = calendar.startOfDay(for: record.date)
            if recordDay == checkDate && record.completionRate > 0 {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Coin helpers

    private func addCoins(_ amount: Int) {
        coins += amount
        totalCoinsEarned += amount
        lastCoinDelta = amount
        withAnimation { showCoinAnimation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showCoinAnimation = false
        }
    }

    private func triggerHappyAnimation() {
        showPetHappyAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showPetHappyAnimation = false
        }
    }

    // MARK: - Helpers

    private func update(task: DailyTask, mutate: (inout DailyTask) -> Void) {
        guard let idx = dailyTasks.firstIndex(where: { $0.id == task.id }) else { return }
        mutate(&dailyTasks[idx])
    }

    // MARK: - Persistence

    func saveState() {
        let snapshot = GameSnapshot(store: self)
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private static func loadSavedState() -> GameSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: "xixixi_game_state_v1"),
              let snapshot = try? JSONDecoder().decode(GameSnapshot.self, from: data) else {
            return nil
        }
        return snapshot
    }
}

// MARK: - GameSnapshot (Codable wrapper for persistence)
struct GameSnapshot: Codable {
    var pet: Pet
    var coins: Int
    var homeItems: [HomeItem]
    var inventory: [StoreItem]
    var achievements: [Achievement]
    var currentSeason: Season
    var currentWeather: Weather
    var totalCoinsEarned: Int
    var dailyTasks: [DailyTask]
    var redLines: [RedLine]
    var taskHistory: [DayRecord]
    var parentPassword: String
    var soundEnabled: Bool

    init(store: GameStore) {
        self.pet = store.pet
        self.coins = store.coins
        self.homeItems = store.homeItems
        self.inventory = store.inventory
        self.achievements = store.achievements
        self.currentSeason = store.currentSeason
        self.currentWeather = store.currentWeather
        self.totalCoinsEarned = store.totalCoinsEarned
        self.dailyTasks = store.dailyTasks
        self.redLines = store.redLines
        self.taskHistory = store.taskHistory
        self.parentPassword = store.parentPassword
        self.soundEnabled = store.soundEnabled
    }
}
