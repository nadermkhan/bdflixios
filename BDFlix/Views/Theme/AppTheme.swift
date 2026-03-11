import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var hue: CGFloat = 0.0
    
    private var colorTimer: Timer?
    
    init() {
        hue = CGFloat.random(in: 0...1)
    }
    
    func startColorCycle() {
        colorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.hue += 0.0008
            if self.hue >= 1.0 { self.hue = 0.0 }
        }
    }
    
    deinit {
        colorTimer?.invalidate()
    }
    
    // MARK: - Dynamic Colors
    
    var primary: Color {
        Color(hue: hue, saturation: 0.65, brightness: 0.55)
    }
    
    var secondary: Color {
        blend(primary, Color(red: 180/255, green: 200/255, blue: 220/255), amount: 0.4)
    }
    
    var accent: Color {
        blend(primary, Color(red: 200/255, green: 240/255, blue: 245/255), amount: 0.5)
    }
    
    var warm: Color {
        Color(red: 255/255, green: 230/255, blue: 185/255)
    }
    
    var textColor: Color {
        Color(red: 220/255, green: 225/255, blue: 232/255)
    }
    
    var dim: Color {
        Color(red: 120/255, green: 135/255, blue: 155/255)
    }
    
    var faint: Color {
        Color(red: 55/255, green: 65/255, blue: 80/255)
    }
    
    var background: Color {
        blend(Color(red: 14/255, green: 17/255, blue: 23/255), primary, amount: 0.04)
    }
    
    var card: Color {
        blend(Color(red: 22/255, green: 27/255, blue: 36/255), primary, amount: 0.05)
    }
    
    var cardAlt: Color {
        blend(Color(red: 26/255, green: 32/255, blue: 42/255), primary, amount: 0.05)
    }
    
    var editBackground: Color {
        blend(Color(red: 18/255, green: 22/255, blue: 30/255), primary, amount: 0.06)
    }
    
    var selectionBackground: Color {
        blend(Color(red: 20/255, green: 30/255, blue: 50/255), primary, amount: 0.25)
    }
    
    var tabHover: Color {
        blend(Color(red: 32/255, green: 40/255, blue: 52/255), primary, amount: 0.10)
    }
    
    var progressBackground: Color {
        blend(Color(red: 30/255, green: 36/255, blue: 48/255), primary, amount: 0.06)
    }
    
    var green: Color {
        Color(red: 80/255, green: 200/255, blue: 120/255)
    }
    
    var red: Color {
        Color(red: 220/255, green: 80/255, blue: 80/255)
    }
    
    var yellow: Color {
        Color(red: 240/255, green: 200/255, blue: 80/255)
    }
    
    // MARK: - Blend Helper
    
    private func blend(_ c1: Color, _ c2: Color, amount: CGFloat) -> Color {
        let uic1 = UIColor(c1)
        let uic2 = UIColor(c2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uic1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uic2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let t = amount
        return Color(
            red: r1 * (1 - t) + r2 * t,
            green: g1 * (1 - t) + g2 * t,
            blue: b1 * (1 - t) + b2 * t
        )
    }
}
