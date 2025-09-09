import Foundation
import CoreLocation

// IP地理位置服务类，用于通过外部IP获取位置信息
class IPLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    // 发布属性，用于在UI中显示位置信息
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var city: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Core Location管理器
    private var locationManager: CLLocationManager?
    
    // 获取位置信息
    func fetchLocation() {
        isLoading = true
        errorMessage = nil
        
        // 先尝试使用系统定位服务
        useCLLocationService()
    }
    
    // 使用系统内置定位服务
    private func useCLLocationService() {
        // 初始化位置管理器
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        // 请求授权
        locationManager?.requestWhenInUseAuthorization()
        
        // 开始定位
        locationManager?.startUpdatingLocation()
    }
    
    // 使用IP定位作为备选方案
    private func useIPLocation() {
        // 使用ip-api.com服务获取地理位置信息
        let urlString = "http://ip-api.com/json/?fields=status,message,country,regionName,city,lat,lon"
        
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
                    self?.errorMessage = "获取位置失败: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "未收到位置数据"
                    return
                }
                
                // 解析位置数据
                self?.parseLocationData(data: data)
            }
        }
        task.resume()
    }
    
    // 解析位置数据
    private func parseLocationData(data: Data) {
        do {
            let decoder = JSONDecoder()
            let locationResponse = try decoder.decode(IPLocationResponse.self, from: data)
            
            if locationResponse.status == "success" {
                self.latitude = locationResponse.lat ?? 0.0
                self.longitude = locationResponse.lon ?? 0.0
                self.city = locationResponse.city ?? ""
                self.errorMessage = nil
            } else {
                self.errorMessage = locationResponse.message ?? "获取位置信息失败"
            }
        } catch {
            self.errorMessage = "解析位置数据失败: \(error.localizedDescription)"
        }
    }
    
    // CLLocationManagerDelegate方法
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 更新位置信息
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.errorMessage = nil
        
        // 反向地理编码获取城市名称
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                // 反向地理编码失败，记录错误但不中断流程
                self?.errorMessage = "位置解析失败: \(error.localizedDescription)"
                return
            }
            
            if let placemark = placemarks?.first {
                self?.city = placemark.locality ?? placemark.administrativeArea ?? ""
            }
        }
        
        // 停止定位
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorMessage = "定位服务失败: \(error.localizedDescription)"
        locationManager?.stopUpdatingLocation()
        
        // 系统定位失败，尝试使用IP定位
        useIPLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // 授权成功，开始定位
            locationManager?.startUpdatingLocation()
        case .denied, .restricted:
            // 授权被拒绝，尝试使用IP定位
            self.errorMessage = "定位服务授权被拒绝"
            locationManager?.stopUpdatingLocation()
            useIPLocation()
        case .notDetermined:
            // 还未决定，不需要处理
            break
        @unknown default:
            // 未知状态
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