import SwiftUI

#if canImport(AppKit)
import AppKit

/// Optimized blur effect wrapper using modern material API
struct OptimizedBlurEffect: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let opacity: Double
    let blurBackground: Bool
    let cornerRadius: CGFloat
    
    init(
        material: NSVisualEffectView.Material = .menu,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
        opacity: Double = 0.8,
        blurBackground: Bool = true,
        cornerRadius: CGFloat = 10,
        intensity: Any? = nil
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.opacity = opacity
        self.blurBackground = blurBackground
        self.cornerRadius = cornerRadius
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blurBackground ? .behindWindow : blendingMode
        view.alphaValue = CGFloat(opacity)
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.layer?.masksToBounds = false
        view.layer?.allowsEdgeAntialiasing = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blurBackground ? .behindWindow : blendingMode
        nsView.alphaValue = CGFloat(opacity)
    }
}

extension View {
    func optimizedBackgroundBlur(
        material: NSVisualEffectView.Material = .menu,
        opacity: Double = 0.8,
        enabled: Bool = true
    ) -> some View {
        self.background(
            OptimizedBlurEffect(
                material: material,
                blendingMode: .behindWindow,
                opacity: opacity,
                blurBackground: true
            )
        )
    }
    
    func optimizedForegroundBlur(
        material: NSVisualEffectView.Material = .menu,
        opacity: Double = 0.8,
        enabled: Bool = true
    ) -> some View {
        self.overlay(
            OptimizedBlurEffect(
                material: material,
                blendingMode: .withinWindow,
                opacity: opacity,
                blurBackground: false
            )
        )
    }
}

#else

struct OptimizedBlurEffect: UIViewRepresentable {
    let style: UIBlurEffect.Style
    let opacity: Double
    
    init(style: UIBlurEffect.Style = .regular, opacity: Double = 0.8, blurBackground: Bool = true, cornerRadius: CGFloat = 10, intensity: Any? = nil) {
        self.style = style
        self.opacity = opacity
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.alpha = CGFloat(opacity)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
        uiView.alpha = CGFloat(opacity)
    }
}

#endif
