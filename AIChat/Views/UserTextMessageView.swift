import SwiftUI

struct UserTextMessageView: View {
    var message: TextMessage
    
    var body: some View {
        Text(message.text)
            .padding(10)
            .background(ThemeColors.accentDeepBlue)
            .foregroundColor(ThemeColors.textWhite)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(ThemeColors.accentLightPinkishRed, lineWidth: 2)
            )
            .shadow(color: ThemeColors.accentDeepBlue.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

