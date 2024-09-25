import SwiftUI

struct ChatView: View {
    @State private var inputText: String = ""
    @State private var messages: [any Message] = [
        TextMessage(id: 0, text: "Hello! How can I assist you today?", isUser: false),
        TextMessage(id: 1, text: "I need some help with my project.", isUser: true)
    ]
    @State private var isAtBottom: Bool = true
    @State private var showNewMessageAlert: Bool = false
    
    var body: some View {
        VStack { // Wrap ZStack in a VStack
            ZStack {
                ThemeColors.backgroundDarkNavyBlue.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                                    HStack {
                                        if message.isUser {
                                            Spacer()
                                            UserTextMessageView(message: message as! TextMessage)
                                        } else {
                                            Group {
                                                switch message {
                                                case let pickerMessage as PickerMessage:
                                                    BotPickerMessageView(message: pickerMessage)
                                                case let multiSelectMessage as MultiSelectMessage:
                                                    BotMultiSelectMessageView(message: multiSelectMessage)
                                                case let yesNoMessage as YesNoMessage:
                                                    BotYesNoMessageView(message: yesNoMessage)
                                                case let ratingMessage as RatingMessage:
                                                    BotRatingMessageView(message: ratingMessage)
                                                default:
                                                    BotTextMessageView(message: message as! TextMessage)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(GeometryReader { geo -> Color in
                                DispatchQueue.main.async {
                                    let contentHeight = geo.frame(in: .global).height
                                    let scrollViewHeight = geo.size.height
                                    isAtBottom = contentHeight <= scrollViewHeight
                                }
                                return Color.clear
                            })
                        }
                        .onChange(of: messages.count) { _ in
                            if isAtBottom {
                                withAnimation {
                                    scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                            } else {
                                showNewMessageAlert = true
                            }
                        }
                        
                        if showNewMessageAlert {
                            Button(action: {
                                withAnimation {
                                    scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                                showNewMessageAlert = false
                            }) {
                                Text("New Message!")
                                    .fontWeight(.bold)
                                    .foregroundColor(ThemeColors.textWhite)
                                    .padding()
                                    .background(ThemeColors.accentDeepBlue)
                                    .cornerRadius(8)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    
                    Divider().background(ThemeColors.accentDeepBlue)
                    
                    HStack(spacing: 10) {
                        TextField("Type a message...", text: $inputText)
                            .padding(.horizontal, 10)
                            .frame(height: 40)
                            .background(ThemeColors.inputBackgroundDarkGrayishPurple)
                            .foregroundColor(ThemeColors.inputTextWhite)
                            .accentColor(ThemeColors.accentLightPinkishRed)
                            .cornerRadius(20) // Roundedness of text input window
                            .textFieldStyle(PlainTextFieldStyle()) // Ensures the cursor is positioned correctly
                            .onSubmit {
                                sendMessage()
                            }
                        
                        Button(action: sendMessage) {
                            Text("Send")
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.textWhite)
                                .frame(height: 40)
                                .padding(.horizontal, 16)
                                .background(ThemeColors.accentDeepBlue)
                                .cornerRadius(20)
                        }
                        .disabled(inputText.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }
            .contextMenu {
                Button(action: clearMessages) {
                    Text("Clear Chat")
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    func clearMessages() {
        messages.removeAll()
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        let userMessageCount = messages.filter { $0.isUser }.count
        let newMessage = TextMessage(id: messages.count, text: inputText, isUser: true)
        messages.append(newMessage)
        inputText = ""

        let botMessage: any Message
        
        switch userMessageCount % 6 { // Updated to 6 to include PickerMessage
        case 0:
            botMessage = RatingMessage(id: messages.count, text: "How would you rate your day? (1-10)", isUser: false, range: 1...10, step: 1, scaleType: .oneToTen, isInteger: true)
        case 1:
            botMessage = MultiSelectMessage(id: messages.count, text: "Select your hobbies:", isUser: false, options: ["Reading", "Sports", "Music", "Cooking"])
        case 2:
            botMessage = RatingMessage(id: messages.count, text: "Rate your experience (0.0-5.0)", isUser: false, range: 0.0...5.0, step: 0.1, scaleType: .zeroToHundred, isInteger: false)
        case 3:
            botMessage = RatingMessage(id: messages.count, text: "How satisfied are you with our service? (0-100)", isUser: false, range: 0...100, step: 1, scaleType: .zeroToHundred, isInteger: true)
        case 4:
            botMessage = YesNoMessage(id: messages.count, text: "Do you enjoy programming?", isUser: false)
        case 5: // New case for PickerMessage
            let options = ["Option 1", "Option 2", "Option 3"]
            botMessage = PickerMessage(id: messages.count, text: "Choose an option:", isUser: false, options: options)
        default:
            botMessage = TextMessage(id: messages.count, text: "I didn't understand that.", isUser: false)
        }
        
        messages.append(botMessage)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
    }
}
