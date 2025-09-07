import Foundation

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
    private let latitude: Double
    private let longitude: Double
    
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
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // 获取天气数据
    func fetchWeather() {
        isLoading = true
        errorMessage = nil
        
        // 构建URL
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,surface_pressure&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "无效的URL"
            self.isLoading = false
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "获取天气失败: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "未收到天气数据"
                    return
                }
                
                // 调用类内部的解析方法
                self?.parseWeatherData(data: data)
            }
        }
        task.resume()
    }
    
    // 解析天气数据 (移到类内部并修复访问)
    private func parseWeatherData(data: Data) {
        do {
            // 解析JSON
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            
            // 更新UI数据
            if let current = weatherResponse.current {
                // 温度
                if let temp = current.temperature_2m {
                    self.temperature = String(format: "%.1f", temp)
                }
                
                // 天气描述
                if let weatherCode = current.weather_code {
                    self.weatherInfo = self.getWeatherDescription(code: weatherCode) ?? "未知天气" // 使用 self.weatherCodes
                }
                
                // 湿度
                if let humidity = current.relative_humidity_2m {
                    self.humidity = String(format: "%.0f", humidity)
                }
                
                // 降雨量
                if let precipitation = current.precipitation {
                    self.rain = String(format: "%.1f", precipitation)
                }
                
                // 体感温度
                if let feelTemp = current.apparent_temperature {
                    self.feelTemperature = String(format: "%.1f", feelTemp)
                }
                
                // 气压
                if let pressure = current.surface_pressure {
                    self.airPressure = String(format: "%.0f", pressure)
                }
            }
            self.errorMessage = nil // 解析成功，清除错误信息
        } catch {
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