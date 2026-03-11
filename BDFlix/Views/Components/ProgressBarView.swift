import SwiftUI

struct AnimatedProgressBar: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var offset: CGFloat = -0.25
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(themeManager.progressBackground)
                
                Rectangle()
                    .fill(themeManager.primary)
                    .frame(width: geometry.size.width * 0.25)
                    .offset(x: offset * geometry.size.width)
            }
        }
        .clipped()
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                offset = 1.0
            }
        }
    }
}
