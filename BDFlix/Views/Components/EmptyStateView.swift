import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 42))
                .foregroundColor(themeManager.faint)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(themeManager.dim)
            
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(themeManager.faint)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.card)
    }
}
