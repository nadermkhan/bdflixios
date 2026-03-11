import SwiftUI

struct AnimatedGradientBackground: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                themeManager.background,
                themeManager.card
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}
