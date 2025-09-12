import Foundation
import CoreLocation

// IP地理位置服务类，用于通过外部IP获取位置信息
class IPLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    // 单例实例
    static let shared = IPLocationService()
    
    // 发布属性，用于在UI中显示位置信息
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var city: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Core Location管理器
    private var locationManager: CLLocationManager?
    
    // 私有初始化方法，防止外部创建实例
    private override init() {
        super.init()
    }
    
    // 获取位置信息
    func fetchLocation() {
        print("IPLocationService: 开始获取位置信息")
        isLoading = true
        errorMessage = nil
        
        // 添加超时机制
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) { [weak self] in
            if self?.isLoading == true && self?.latitude == 0.0 && self?.longitude == 0.0 {
                print("IPLocationService: 位置获取超时，尝试使用IP定位")
                self?.useIPLocation()
            }
        }
        
        // 先尝试使用系统定位服务
        useCLLocationService()
    }
    
    // 强制刷新位置信息
    func forceRefreshLocation() {
        print("IPLocationService: 强制刷新位置信息")
        locationManager?.stopUpdatingLocation()
        fetchLocation()
    }
    
    // 使用系统内置定位服务
    private func useCLLocationService() {
        print("IPLocationService: 使用系统内置定位服务")
        
        // 初始化位置管理器
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager?.distanceFilter = 1000 // 1公里距离过滤器
        
        // 检查当前授权状态
        let status = locationManager?.authorizationStatus ?? .notDetermined
        print("IPLocationService: 当前定位服务授权状态: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("IPLocationService: 已授权，开始定位")
            // 已授权，开始定位
            locationManager?.startUpdatingLocation()
        case .notDetermined:
            print("IPLocationService: 请求授权")
            // 请求授权
            locationManager?.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("IPLocationService: 授权被拒绝，尝试使用IP定位")
            // 授权被拒绝，尝试使用IP定位
            self.errorMessage = "定位服务授权被拒绝"
            locationManager?.stopUpdatingLocation()
            useIPLocation()
        @unknown default:
            print("IPLocationService: 未知状态，尝试使用IP定位")
            // 未知状态，尝试使用IP定位
            self.errorMessage = "未知的定位服务授权状态"
            locationManager?.stopUpdatingLocation()
            useIPLocation()
        }
    }
    
    // 使用IP定位作为备选方案
    private func useIPLocation() {
        print("IPLocationService: 使用IP定位作为备选方案")
        
        // 使用ip-api.com服务获取地理位置信息
        let urlString = "http://ip-api.com/json/?fields=status,message,country,regionName,city,lat,lon"
        print("IPLocationService: 请求IP定位URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("IPLocationService: 无效的URL")
            self.errorMessage = "无效的URL"
            self.isLoading = false
            return
        }
        
        // 添加超时时间
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                print("IPLocationService: 收到IP定位响应")
                self?.isLoading = false
                
                if let error = error {
                    print("IPLocationService: 获取位置失败: \(error.localizedDescription)")
                    self?.errorMessage = "获取位置失败: \(error.localizedDescription)"
                    return
                }
                
                // 检查HTTP响应状态
                if let httpResponse = response as? HTTPURLResponse {
                    print("IPLocationService: IP定位HTTP响应状态: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        self?.errorMessage = "获取位置失败: HTTP \(httpResponse.statusCode)"
                        return
                    }
                }
                
                guard let data = data else {
                    print("IPLocationService: 未收到位置数据")
                    self?.errorMessage = "未收到位置数据"
                    return
                }
                
                print("IPLocationService: 收到位置数据，大小: \(data.count) 字节")
                
                // 解析位置数据
                self?.parseLocationData(data: data)
            }
        }
        task.resume()
    }
    
    // 解析位置数据
    private func parseLocationData(data: Data) {
        do {
            // 打印接收到的原始数据用于调试
            if let jsonString = String(data: data, encoding: .utf8) {
                print("IPLocationService: 原始位置数据: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let locationResponse = try decoder.decode(IPLocationResponse.self, from: data)
            
            print("IPLocationService: 解析位置数据成功，状态: \(locationResponse.status ?? "未知")")
            
            if locationResponse.status == "success" {
                self.latitude = locationResponse.lat ?? 0.0
                self.longitude = locationResponse.lon ?? 0.0
                self.city = locationResponse.city ?? ""
                print("IPLocationService: 位置信息更新 - 纬度: \(self.latitude), 经度: \(self.longitude), 城市: \(self.city)")
                self.errorMessage = nil
            } else {
                print("IPLocationService: 位置获取失败，消息: \(locationResponse.message ?? "未知错误")")
                self.errorMessage = locationResponse.message ?? "获取位置信息失败"
            }
        } catch {
            print("IPLocationService: 解析位置数据失败: \(error)")
            self.errorMessage = "解析位置数据失败: \(error.localizedDescription)"
        }
    }
    
    // CLLocationManagerDelegate方法
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("IPLocationService: 获取到位置信息 - 纬度: \(location.coordinate.latitude), 经度: \(location.coordinate.longitude)")
        
        // 更新位置信息
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.errorMessage = nil
        
        // 反向地理编码获取城市名称
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                // 反向地理编码失败，记录错误但不中断流程
                print("IPLocationService: 位置解析失败: \(error.localizedDescription)")
                self?.errorMessage = "位置解析失败: \(error.localizedDescription)"
                return
            }
            
            if let placemark = placemarks?.first {
                self?.city = placemark.locality ?? placemark.administrativeArea ?? ""
                print("IPLocationService: 城市信息: \(self?.city ?? "未知")")
            }
        }
        
        // 停止定位
        locationManager?.stopUpdatingLocation()
        
        // 通知天气服务更新天气
        NotificationCenter.default.post(name: Notification.Name("LocationUpdated"), object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("IPLocationService: 定位服务失败: \(error.localizedDescription)")
        self.errorMessage = "定位服务失败: \(error.localizedDescription)"
        locationManager?.stopUpdatingLocation()
        
        // 系统定位失败，尝试使用IP定位
        useIPLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("IPLocationService: 定位服务授权状态变更: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("IPLocationService: 定位服务已授权，开始定位")
            // 授权成功，开始定位
            locationManager?.startUpdatingLocation()
        case .denied, .restricted:
            print("IPLocationService: 定位服务授权被拒绝，尝试使用IP定位")
            // 授权被拒绝，尝试使用IP定位
            self.errorMessage = "定位服务授权被拒绝"
            locationManager?.stopUpdatingLocation()
            useIPLocation()
        case .notDetermined:
            // 还未决定，不需要处理
            print("IPLocationService: 定位服务授权状态未确定")
            break
        @unknown default:
            // 未知状态
            print("IPLocationService: 未知的定位服务授权状态")
            self.errorMessage = "未知的定位服务授权状态"
            locationManager?.stopUpdatingLocation()
        }
    }
}

// IP地理位置响应模型
struct IPLocationResponse: Codable {
    let status: String?
    let message: String?
    let country: String?
    let regionName: String?
    let city: String?
    let lat: Double?
    let lon: Double?
}