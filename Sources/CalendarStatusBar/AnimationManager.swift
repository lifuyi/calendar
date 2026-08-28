import SwiftUI
import Foundation

/// 动画管理器 - 提供统一的动画配置和性能优化
class AnimationManager: ObservableObject {
    static let shared = AnimationManager()
    
    /// 动画配置
    struct AnimationConfig {
        let duration: Double
        let timingCurve: Animation
        let dampingFraction: Double
        let response: Double
        
        static let smooth = AnimationConfig(
            duration: 0.3,
            timingCurve: .interpolatingSpring(stiffness: 300, damping: 30),
            dampingFraction: 0.8,
            response: 0.3
        )
        
        static let quick = AnimationConfig(
            duration: 0.2,
            timingCurve: .interpolatingSpring(stiffness: 400, damping: 25),
            dampingFraction: 0.7,
            response: 0.2
        )
        
        static let gentle = AnimationConfig(
            duration: 0.5,
            timingCurve: .interpolatingSpring(stiffness: 200, damping: 35),
            dampingFraction: 0.9,
            response: 0.5
        )
        
        static let bounce = AnimationConfig(
            duration: 0.6,
            timingCurve: .interpolatingSpring(stiffness: 250, damping: 20),
            dampingFraction: 0.6,
            response: 0.4
        )
    }
    
    private init() {}
    
    /// 获取优化的动画配置
    func getAnimation(for type: AnimationType) -> Animation {
        switch type {
        case .theme:
            return AnimationConfig.gentle.timingCurve
        case .settings:
            return AnimationConfig.quick.timingCurve
        case .popup:
            return AnimationConfig.bounce.timingCurve
        case .fade:
            return .easeInOut(duration: 0.25)
        case .scale:
            return .interpolatingSpring(stiffness: 300, damping: 30)
        }
    }
    
    /// 获取动画时长
    func getDuration(for type: AnimationType) -> Double {
        switch type {
        case .theme:
            return AnimationConfig.gentle.duration
        case .settings:
            return AnimationConfig.quick.duration
        case .popup:
            return AnimationConfig.bounce.duration
        case .fade:
            return 0.25
        case .scale:
            return 0.3
        }
    }
}

/// 动画类型枚举
enum AnimationType {
    case theme     // 主题切换动画
    case settings  // 设置界面动画
    case popup     // 弹出动画
    case fade      // 淡入淡出
    case scale     // 缩放动画
}

/// 动画视图修饰器
extension View {
    /// 应用优化的动画过渡
    func animatedTransition(
        _ type: AnimationType,
        value: some Equatable,
        delay: Double = 0
    ) -> some View {
        self.animation(
            AnimationManager.shared.getAnimation(for: type).delay(delay),
            value: value
        )
    }
    
    /// 应用淡入淡出动画
    func fadeTransition(
        isVisible: Bool,
        duration: Double = 0.25,
        delay: Double = 0
    ) -> some View {
        self
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(
                .easeInOut(duration: duration).delay(delay),
                value: isVisible
            )
    }
    
    /// 应用缩放过渡动画
    func scaleTransition(
        isVisible: Bool,
        scale: CGFloat = 0.8,
        duration: Double = 0.3,
        delay: Double = 0
    ) -> some View {
        self
            .scaleEffect(isVisible ? 1.0 : scale)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(
                AnimationManager.shared.getAnimation(for: .scale).delay(delay),
                value: isVisible
            )
    }
    
    /// 应用滑动过渡动画
    func slideTransition(
        isVisible: Bool,
        edge: Edge = .bottom,
        distance: CGFloat = 20,
        duration: Double = 0.3,
        delay: Double = 0
    ) -> some View {
        let offset: CGSize = {
            switch edge {
            case .top: return CGSize(width: 0, height: isVisible ? 0 : -distance)
            case .bottom: return CGSize(width: 0, height: isVisible ? 0 : distance)
            case .leading: return CGSize(width: isVisible ? 0 : -distance, height: 0)
            case .trailing: return CGSize(width: isVisible ? 0 : distance, height: 0)
            }
        }()
        
        return self
            .offset(offset)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(
                AnimationManager.shared.getAnimation(for: .settings).delay(delay),
                value: isVisible
            )
    }
}

/// 性能优化的动画容器
struct OptimizedAnimationContainer<Content: View>: View {
    let content: Content
    let isEnabled: Bool
    
    init(enabled: Bool = true, @ViewBuilder content: () -> Content) {
        self.isEnabled = enabled
        self.content = content()
    }
    
    var body: some View {
        if isEnabled {
            content
                .drawingGroup() // 启用GPU渲染优化
        } else {
            content
        }
    }
}