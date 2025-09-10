import SwiftUI

#if canImport(AppKit)
import AppKit

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var opacity: Double
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.alphaValue = CGFloat(opacity)
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.alphaValue = CGFloat(opacity)
    }
}

#elseif canImport(UIKit)
import UIKit

struct VisualEffectBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var opacity: Double
    
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