import SwiftUI

struct SearchBar: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var text: String
    let onSubmit: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(themeManager.dim)
            
            TextField("Search files... (use -exclude \"exact phrase\")", text: $text)
                .font(.system(size: 14))
                .foregroundColor(themeManager.warm)
                .tint(themeManager.accent)
                .focused($isFocused)
                .onSubmit {
                    onSubmit()
                }
                .submitLabel(.search)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.dim)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeManager.editBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? themeManager.primary : themeManager.faint, lineWidth: 1)
                )
        )
        .onAppear {
            isFocused = true
        }
    }
}
