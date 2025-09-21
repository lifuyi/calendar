import SwiftUI

#if canImport(AppKit)
import AppKit

/// Enhanced blur effect with optimized performance and visual quality
struct OptimizedBlurEffect: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let opacity: Double
    let blurBackground: Bool
    let cornerRadius: CGFloat
    let intensity: BlurIntensity
    
    enum BlurIntensity {
        case subtle     // 轻微虚化，适合浅色主题
        case moderate   // 中等虚化，适合大多数情况
        case strong     // 强烈虚化，适合深色主题
        case dramatic   // 戏剧性虚化，适合特殊效果
        
        var multiplier: Double {
            switch self {
            case .subtle: return 0.6
            case .moderate: return 0.8
            case .strong: return 0.9
            case .dramatic: return 1.0
            }
        }
        
        var additionalBlur: Bool {
            switch self {
            case .subtle, .moderate: return false
            case .strong, .dramatic: return true
            }
        }
    }
    
    init(
        material: NSVisualEffectView.Material = .menu,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
        opacity: Double = 0.8,
        blurBackground: Bool = true,
        cornerRadius: CGFloat = 10,
        intensity: BlurIntensity = .moderate
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.opacity = opacity
        self.blurBackground = blurBackground
        self.cornerRadius = cornerRadius
        self.intensity = intensity
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        configureView(view)
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        configureView(nsView)
    }
    
    private func configureView(_ view: NSVisualEffectView) {
        // 使用 CATransaction 包装所有变更以提高性能
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        view.material = material
        view.blendingMode = blurBackground ? .behindWindow : blendingMode
        view.alphaValue = CGFloat(opacity * intensity.multiplier)
        view.state = .active
        
        // Enhanced visual properties
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        
        // Optimize based on blur direction and intensity
        if blurBackground {
            // Background blur optimizations - 针对背景虚化优化
            view.layer?.masksToBounds = false
            view.layer?.shouldRasterize = false
            view.layer?.allowsEdgeAntialiasing = true
            
            // 减少不必要的阴影计算
            if intensity.additionalBlur {
                view.layer?.shadowOpacity = 0.08  // 减少阴影强度以提高性能
                view.layer?.shadowRadius = 1.5
                view.layer?.shadowOffset = CGSize(width: 0, height: 0.5)
                view.layer?.shadowColor = NSColor.black.cgColor
                view.layer?.shadowPath = CGPath(roundedRect: view.bounds, 
                                               cornerWidth: cornerRadius, 
                                               cornerHeight: cornerRadius, 
                                               transform: nil)
            }
        } else {
            // Foreground blur optimizations - 针对前景虚化优化
            view.layer?.masksToBounds = true
            view.layer?.shouldRasterize = true
            view.layer?.rasterizationScale = NSScreen.main?.backingScaleFactor ?? 2.0
            
            // 仅在需要时添加边框
            if intensity == .subtle {
                view.layer?.borderWidth = 0.5
                view.layer?.borderColor = NSColor.controlAccentColor.withAlphaComponent(0.15).cgColor
            }
        }
        
        // 增强的性能优化
        view.layer?.drawsAsynchronously = true
        view.layerUsesCoreImageFilters = false
        
        // 禁用隐式动画以提高性能
        view.layer?.actions = [
            "opacity": NSNull(),
            "transform": NSNull(),
            "position": NSNull(),
            "bounds": NSNull()
        ]
        
        // 优化合成
        view.layer?.isOpaque = false
        view.layer?.allowsGroupOpacity = true
        
        // 针对高 DPI 显示器的优化
        if let screen = NSScreen.main, screen.backingScaleFactor > 1.0 {
            view.layer?.contentsScale = screen.backingScaleFactor
        }
        
        CATransaction.commit()
    }
}

// Convenience extensions for common blur effects
extension View {
    /// Apply optimized background blur
    func optimizedBackgroundBlur(
        material: NSVisualEffectView.Material = .menu,
        opacity: Double = 0.8,
        intensity: OptimizedBlurEffect.BlurIntensity = .moderate,
        enabled: Bool = true
    ) -> some View {
        self.background(
            OptimizedBlurEffect(
                material: material,
                blendingMode: .behindWindow,
                opacity: opacity,
                blurBackground: true,
                cornerRadius: 10,
                intensity: intensity
            )
        )
    }
    
    /// Apply optimized foreground blur
    func optimizedForegroundBlur(
        material: NSVisualEffectView.Material = .menu,
        opacity: Double = 0.8,
        intensity: OptimizedBlurEffect.BlurIntensity = .moderate,
        enabled: Bool = true
    ) -> some View {
        self.overlay(
            OptimizedBlurEffect(
                material: material,
                blendingMode: .withinWindow,
                opacity: opacity,
                blurBackground: false,
                cornerRadius: 10,
                intensity: intensity
            )
        )
    }
}

#else

// iOS fallback
struct OptimizedBlurEffect: UIViewRepresentable {
    let style: UIBlurEffect.Style
    let opacity: Double
    let intensity: BlurIntensity
    
    enum BlurIntensity {
        case subtle, moderate, strong, dramatic
        
        var multiplier: Double {
            switch self {
            case .subtle: return 0.6
            case .moderate: return 0.8
            case .strong: return 0.9
            case .dramatic: return 1.0
            }
        }
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.alpha = CGFloat(opacity * intensity.multiplier)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
        uiView.alpha = CGFloat(opacity * intensity.multiplier)
    }
}

#endif