import Foundation
import Combine

// 天气服务类，用于获取和解析天气数据
class WeatherService: ObservableObject {
    // 发布属性，用于在UI中显示天气信息
    @Published var temperature: String = "--"
    @Published var weatherInfo: String = "--"
    @Published var humidity: String = "--"
    @Published var airPressure: String = "--"
    @Published var rain: String = "--"
    @Published var feelTemperature: String = "--"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // 位置信息
    private var latitude: Double
    private var longitude: Double
    
    // 定位服务
    private var locationService: IPLocationService?
    
    // 用于管理Combine订阅
    private var cancellables = Set<AnyCancellable>()
    
    // 天气代码映射到描述
    private let weatherCodes: [Int: String] = [
        0: "晴朗",
        1: "大部晴朗",
        2: "多云",
        3: "阴天",
        45: "雾",
        48: "霾",
        51: "小毛毛雨",
        53: "毛毛雨",
        55: "大毛毛雨",
        56: "小冻雨",
        57: "冻雨",
        61: "小雨",
        63: "中雨",
        65: "大雨",
        66: "小冻雨",
        67: "大冻雨",
        71: "小雪",
        73: "中雪",
        75: "大雪",
        77: "雪粒",
        80: "小阵雨",
        81: "阵雨",
        82: "强阵雨",
        85: "小阵雪",
        86: "阵雪",
        95: "雷暴",
        96: "雷暴伴小冰雹",
        99: "雷暴伴大冰雹"
    ]
    
    // 初始化方法
    init(latitude: Double = 39.9042, longitude: Double = 116.4074) {
        print("WeatherService: 初始化，初始位置 - 纬度: \(latitude), 经度: \(longitude)")
        self.latitude = latitude
        self.longitude = longitude
        
        // 监听位置更新通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationDidUpdate),
            name: Notification.Name("LocationUpdated"),
            object: nil
        )
    }
    
    // 位置更新通知处理
    @objc private func locationDidUpdate() {
        print("WeatherService: 收到位置更新通知，重新获取天气")
        print("WeatherService: 当前位置 - 纬度: \(latitude), 经度: \(longitude)")
        fetchWeather()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 设置定位服务
    func setLocationService(_ service: IPLocationService) {
        print("WeatherService: 设置定位服务")
        self.locationService = service
        
        // 监听位置变化
        service.$latitude.sink { [weak self] newLatitude in
            print("WeatherService: 纬度更新为 \(newLatitude)")
            self?.latitude = newLatitude
            self?.fetchWeather()
        }.store(in: &self.cancellables)
        
        service.$longitude.sink { [weak self] newLongitude in
            print("WeatherService: 经度更新为 \(newLongitude)")
            self?.longitude = newLongitude
            self?.fetchWeather()
        }.store(in: &self.cancellables)
    }
    
    // 更新位置信息
    func updateLocation(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // 测试网络连接
    func testNetworkConnectivity(completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=39.9042&longitude=116.4074¤t=temperature_2m&timezone=auto")!
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "网络连接失败: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(true, nil)
                } else {
                    completion(false, "HTTP错误: \(httpResponse.statusCode)")
                }
                return
            }
            
            completion(false, "未知响应类型")
        }
        
        task.resume()
    }
    
    // 获取天气数据
    func fetchWeather() {
        print("WeatherService: 开始获取天气数据，经纬度: \(latitude), \(longitude)")
        
        // 检查是否有有效的经纬度
        if latitude == 0.0 && longitude == 0.0 {
            print("WeatherService: 无效的经纬度，尝试获取位置信息")
            // 如果没有有效的经纬度，先尝试获取位置
            locationService?.fetchLocation()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"
        
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,surface_pressure"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        
        guard let url = components.url else {
            self.errorMessage = "无效的URL"
            self.isLoading = false
            return
        }
        
        print("WeatherService: 请求URL: \(url)")
        
        // 添加超时时间
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        
        // 添加超时机制
        let timeoutTask = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                if self?.isLoading == true {
                    print("WeatherService: 天气数据获取超时")
                    self?.isLoading = false
                    self?.errorMessage = "天气数据获取超时"
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: timeoutTask)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // 取消超时任务
            timeoutTask.cancel()
            
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("WeatherService: 获取天气失败: \(error.localizedDescription)")
                    self?.errorMessage = "获取天气失败: \(error.localizedDescription)"
                    return
                }
                
                // 检查HTTP响应状态
                if let httpResponse = response as? HTTPURLResponse {
                    print("WeatherService: HTTP响应状态: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        self?.errorMessage = "获取天气失败: HTTP \(httpResponse.statusCode)"
                        return
                    }
                }
                
                guard let data = data else {
                    print("WeatherService: 未收到天气数据")
                    self?.errorMessage = "未收到天气数据"
                    return
                }
                
                print("WeatherService: 收到天气数据，大小: \(data.count) 字节")
                
                // 调用类内部的解析方法
                self?.parseWeatherData(data: data)
            }
        }
        task.resume()
    }
    
    // 解析天气数据 (移到类内部并修复访问)
    private func parseWeatherData(data: Data) {
        do {
            // 打印接收到的原始数据用于调试
            if let jsonString = String(data: data, encoding: .utf8) {
                print("WeatherService: 原始天气数据: \(jsonString)")
            }
            
            // 解析JSON
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            
            // 更新UI数据
            if let current = weatherResponse.current {
                // 温度
                if let temp = current.temperature_2m {
                    self.temperature = String(format: "%.1f", temp)
                } else {
                    self.temperature = "--"
                }
                
                // 天气描述
                if let weatherCode = current.weather_code {
                    self.weatherInfo = self.getWeatherDescription(code: weatherCode) ?? "未知天气"
                } else {
                    self.weatherInfo = "--"
                }
                
                // 湿度
                if let humidity = current.relative_humidity_2m {
                    self.humidity = String(format: "%.0f", humidity)
                } else {
                    self.humidity = "--"
                }
                
                // 降雨量
                if let precipitation = current.precipitation {
                    self.rain = String(format: "%.1f", precipitation)
                } else {
                    self.rain = "--"
                }
                
                // 体感温度
                if let feelTemp = current.apparent_temperature {
                    self.feelTemperature = String(format: "%.1f", feelTemp)
                } else {
                    self.feelTemperature = "--"
                }
                
                // 气压
                if let pressure = current.surface_pressure {
                    self.airPressure = String(format: "%.0f", pressure)
                } else {
                    self.airPressure = "--"
                }
            } else {
                print("WeatherService: 天气响应中没有当前天气数据")
                self.errorMessage = "天气数据格式不正确"
            }
            self.errorMessage = nil // 解析成功，清除错误信息
        } catch {
            print("WeatherService: 解析天气数据失败: \(error)")
            self.errorMessage = "解析天气数据失败: \(error.localizedDescription)"
        }
    }
    
    // 获取天气描述的辅助方法
    private func getWeatherDescription(code: Int) -> String? {
        return weatherCodes[code]
    }
}

// Open-Meteo API 响应模型
struct WeatherResponse: Codable {
    let latitude: Double?
    let longitude: Double?
    let timezone: String?
    let current: CurrentWeather?
}

struct CurrentWeather: Codable {
    let time: String?
    let temperature_2m: Double?
    let relative_humidity_2m: Double?
    let apparent_temperature: Double?
    let precipitation: Double?
    let weather_code: Int?
    let surface_pressure: Double?
}