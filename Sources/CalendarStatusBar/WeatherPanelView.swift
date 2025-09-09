import SwiftUI

struct WeatherPanelView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 天气信息区域
            VStack(alignment: .leading, spacing: 8) {
                // 当前位置显示
                if !viewModel.locationService.city.isEmpty {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                        Text(viewModel.locationService.city)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                // 加载状态指示器
                if viewModel.isWeatherLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("正在获取天气数据...")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                // 错误信息
                if let error = viewModel.weatherError {
                    Text("错误: \(error)")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // 天气数据显示
                if !viewModel.isWeatherLoading && viewModel.weatherError == nil {
                    Group {
                        WeatherInfoRow(label: "天气状况:", value: viewModel.weatherInfo)
                        WeatherInfoRow(label: "当前温度:", value: "\(viewModel.temperature)°C")
                        WeatherInfoRow(label: "体感温度:", value: "\(viewModel.feelTemperature)°C")
                        WeatherInfoRow(label: "湿度:", value: "\(viewModel.humidity)%")
                        WeatherInfoRow(label: "气压:", value: "\(viewModel.airPressure)hPa")
                        WeatherInfoRow(label: "降水量:", value: "\(viewModel.rain)mm")
                    }
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
    }
}

struct WeatherInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.system(size: 11, weight: .medium))
        }
    }
}