import Foundation
import Combine

/// 定时数据更新管理器，负责定期更新地理位置和相关数据
class PeriodicUpdateManager: ObservableObject {
    // 单例实例
    static let shared = PeriodicUpdateManager()
    
    // 定时器
    private var locationUpdateTimer: Timer?
    
    // 位置服务
    private var locationService: IPLocationService?
    private var weatherService: WeatherService?
    
    // 更新间隔（4小时 = 4 * 60 * 60 秒）
    private let updateInterval: TimeInterval = 4 * 60 * 60
    
    // 是否已启动
    private var isStarted = false
    
    // 上次更新时间
    @Published var lastUpdateTime: Date?
    
    // 下次更新时间
    @Published var nextUpdateTime: Date?
    
    // 更新状态
    @Published var isUpdating: Bool = false
    
    // 私有初始化方法
    private init() {
        print("PeriodicUpdateManager: 初始化")
    }
    
    // 设置服务
    func setServices(locationService: IPLocationService, weatherService: WeatherService) {
        self.locationService = locationService
        self.weatherService = weatherService
        print("PeriodicUpdateManager: 设置服务完成")
    }
    
    // 启动定时更新
    func startPeriodicUpdates() {
        guard !isStarted else {
            print("PeriodicUpdateManager: 定时更新已启动")
            return
        }
        
        print("PeriodicUpdateManager: 启动定时更新，间隔: \(updateInterval)秒")
        
        // 立即执行一次更新
        performUpdate()
        
        // 设置定时器
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            print("PeriodicUpdateManager: 定时器触发，执行更新")
            self?.performUpdate()
        }
        
        // 计算下次更新时间
        updateNextUpdateTime()
        
        isStarted = true
    }
    
    // 停止定时更新
    func stopPeriodicUpdates() {
        guard isStarted else {
            print("PeriodicUpdateManager: 定时更新未启动")
            return
        }
        
        print("PeriodicUpdateManager: 停止定时更新")
        
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        
        isStarted = false
        nextUpdateTime = nil
    }
    
    // 手动触发更新
    func manualUpdate() {
        print("PeriodicUpdateManager: 手动触发更新")
        performUpdate()
    }
    
    // 执行更新
    private func performUpdate() {
        guard !isUpdating else {
            print("PeriodicUpdateManager: 正在更新中，跳过本次更新")
            return
        }
        
        print("PeriodicUpdateManager: 开始执行更新")
        isUpdating = true
        
        // 更新位置信息
        locationService?.forceRefreshLocation()
        
        // 位置更新后会自动触发天气更新（通过通知机制）
        
        // 更新上次更新时间
        lastUpdateTime = Date()
        
        // 计算下次更新时间
        updateNextUpdateTime()
        
        // 模拟更新完成（实际更新是异步的）
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            self?.isUpdating = false
            print("PeriodicUpdateManager: 更新完成")
        }
    }
    
    // 更新下次更新时间
    private func updateNextUpdateTime() {
        nextUpdateTime = Date().addingTimeInterval(updateInterval)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let nextTime = nextUpdateTime {
            print("PeriodicUpdateManager: 下次更新时间: \(formatter.string(from: nextTime))")
        }
    }
    
    // 获取距离下次更新的时间
    func getTimeUntilNextUpdate() -> String {
        guard let nextTime = nextUpdateTime else {
            return "未知"
        }
        
        let now = Date()
        let interval = nextTime.timeIntervalSince(now)
        
        if interval <= 0 {
            return "即将更新"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    // 获取上次更新时间的描述
    func getLastUpdateTimeDescription() -> String {
        guard let lastTime = lastUpdateTime else {
            return "从未更新"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: lastTime)
    }
    
    deinit {
        stopPeriodicUpdates()
    }
}