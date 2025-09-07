# IFLOW.md - 状态栏日历应用

## 项目概述

这是一个 macOS 状态栏应用程序，使用 Swift 和 SwiftUI 开发。该应用在系统状态栏显示当前日期、星期和时间，点击可展开显示完整的日历视图，包含以下功能：

- 状态栏实时显示日期时间（格式：MM月dd日 HH:mm E）
- 展开式日历视图，支持年份选择（1900-2075年）和月份切换
- 农历日期显示
- 中国法定节假日和节气标记
- 当天日历事件显示（需要用户授权）
- 天气信息显示（温度、天气状况、湿度、气压、降水量、体感温度）

## 技术栈

- **语言**: Swift 5.5+
- **框架**: SwiftUI, AppKit, EventKit, CoreText, CoreGraphics, ServiceManagement
- **平台**: macOS 12.0+
- **构建工具**: Swift Package Manager

## 项目结构

```
calendar/
├── Sources/
│   └── CalendarStatusBar/
│       ├── App.swift              # 应用主入口和 AppDelegate
│       ├── main.swift             # 程序入口点
│       ├── CalendarView.swift     # 主日历视图
│       ├── CalendarHeaderView.swift # 日历头部视图
│       ├── CalendarGridView.swift  # 日历网格视图
│       ├── CalendarViewModel.swift # 日历视图模型
│       ├── EventsDrawerView.swift  # 事件抽屉视图
│       ├── EventManager.swift     # 日历事件管理器
│       ├── WeatherPanelView.swift  # 天气面板视图
│       ├── WeatherService.swift   # 天气服务
│       ├── ChineseCalendarHelper.swift # 农历助手
│       ├── HolidayManager.swift   # 节假日管理器
│       ├── DayInfo.swift          # 日期信息模型
│       ├── Info.plist             # 应用配置文件
│       ├── assets/                # 资源文件（字体等）
│       ├── Holidays/              # 节假日数据
│       └── Media.xcassets/        # 图像资源
├── Package.swift                  # Swift Package 配置
├── README.md                      # 项目说明文档
└── mainland-china.json            # 中国节假日数据
```

## 构建和运行

### 系统要求
- macOS 12.0 或更高版本
- Xcode 13.0 或更高版本（用于开发）

### 命令行构建和运行

```bash
# 克隆项目
git clone [项目地址]
cd calendar

# 构建项目
swift build

# 运行项目
swift run
```

### Xcode 构建和运行
1. 打开 Xcode
2. 选择 "Open a project or file"
3. 选择项目目录中的 `Package.swift` 文件
4. 点击 "Open"
5. 点击 "Run" 按钮或按 `Cmd+R`

## 核心功能模块

### 1. 日历显示模块
- **CalendarView**: 主视图，包含日历网格、农历信息、节假日标记等
- **CalendarHeaderView**: 日历头部，包含年份选择器、月份导航等
- **CalendarGridView**: 日历网格，显示日期、农历、节假日等信息
- **CalendarViewModel**: 视图模型，处理日期逻辑和数据

### 2. 日历事件模块
- **EventManager**: 管理日历事件访问权限和事件加载
- **EventsDrawerView**: 显示当天日历事件的抽屉视图

### 3. 天气信息模块
- **WeatherService**: 获取和解析天气数据
- **WeatherPanelView**: 显示天气信息的面板视图

### 4. 农历和节假日模块
- **ChineseCalendarHelper**: 处理农历日期、生肖、节气等计算
- **HolidayManager**: 管理法定节假日和调休数据
- **mainland-china.json**: 包含中国节假日和调休数据

## 开发约定

### 代码风格
- 使用 Swift 标准命名约定
- 使用中文注释和用户界面文本
- 遵循 SwiftUI 视图架构模式
- 使用 @Published 属性包装器进行状态管理

### 资源管理
- 字体文件放在 `assets` 目录
- 图像资源使用 `Media.xcassets`
- 节假日数据放在 `Holidays` 目录

### 权限处理
- 日历访问需要用户授权，通过 `EventManager` 处理
- Info.plist 中配置了 `NSCalendarsUsageDescription` 权限说明

## 故障排除

### 日历权限问题
如果应用无法访问日历：
1. 检查系统偏好设置 > 安全性与隐私 > 隐私 > 日历中是否已授权
2. 完全退出应用并重新启动
3. 使用应用内的"重新请求权限"按钮

### 天气信息不显示
如果天气信息无法加载：
1. 检查网络连接
2. 确认可以访问 https://api.open-meteo.com
3. 查看控制台输出的错误信息

## 未来开发计划

- [ ] 添加自定义主题
- [ ] 添加日程提醒功能