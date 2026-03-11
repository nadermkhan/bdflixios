import SwiftUI

struct AboutView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isFacebookLoading = false
    @State private var showRipple = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 30)
                
                // App icon
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(themeManager.accent)
                    .padding(.bottom, 12)
                
                // App name
                Text("BDFlix")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(themeManager.accent)
                    .padding(.bottom, 4)
                
                // Version
                Text("Version 2.0.0")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.dim)
                    .padding(.bottom, 20)
                
                // Separator
                Rectangle()
                    .fill(themeManager.faint)
                    .frame(width: 160, height: 1)
                    .padding(.bottom, 18)
                
                // Developer
                Text("Developer")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.textColor)
                    .padding(.bottom, 6)
                
                Text("Nader Mahbub Khan")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.warm)
                    .padding(.bottom, 30)
                
                // Facebook button
                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isFacebookLoading = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let url = URL(string: "https://www.facebook.com/nadermahbubkhan") {
                            UIApplication.shared.open(url)
                        }
                        isFacebookLoading = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isFacebookLoading {
                            SpinnerView(lineWidth: 2, color: .white)
                                .frame(width: 18, height: 18)
                        } else {
                            Image(systemName: "link")
                                .font(.system(size: 14))
                            Text("Connect on Facebook")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 220, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 24/255, green: 119/255, blue: 242/255))
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.bottom, 40)
                
                // Copyright
                Text("Copyright © 2026 All rights reserved.")
                    .font(.system(size: 10))
                    .foregroundColor(themeManager.dim)
                    .padding(.bottom, 16)
                
                // Icon row
                HStack(spacing: 30) {
                    Image(systemName: "magnifyingglass")
                    Image(systemName: "arrow.down.circle")
                    Image(systemName: "info.circle")
                    Image(systemName: "arrow.up.right.square")
                }
                .font(.system(size: 16))
                .foregroundColor(themeManager.faint)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(themeManager.background)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
