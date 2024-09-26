import SwiftUI

struct ChatView: View {
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(message: TextMessage(text: "Hello! How can I assist you today?"), id: 0, isUser: false),
        ChatMessage(message: TextMessage(text: "I need some help with my project."), id: 1, isUser: true)
    ]
    @State private var isAtBottom: Bool = true
    @State private var showNewMessageAlert: Bool = false
    @State private var isLoading: Bool = false
    
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
                                            UserTextMessageView(message: message.message as! TextMessage)
                                        } else {
                                            Group {
                                                switch message.message {
                                                case let pickerMessage as PickerMessage:
                                                    BotPickerMessageView(message: pickerMessage)
                                                case let multiSelectMessage as MultiSelectMessage:
                                                    BotMultiSelectMessageView(message: multiSelectMessage)
                                                case let yesNoMessage as YesNoMessage:
                                                    BotYesNoMessageView(message: yesNoMessage)
                                                case let ratingMessage as RatingMessage:
                                                    BotRatingMessageView(message: ratingMessage)
                                                default:
                                                    BotTextMessageView(message: message.message as! TextMessage)
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
                        .onChange(of: messages.count) { newCount, oldCount in
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
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                                .background(ThemeColors.cardBackgroundSlightlyLighterNavyBlue)
                                .cornerRadius(8)
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
                                .background(inputText.isEmpty ? ThemeColors.disabledTextDarkGray : ThemeColors.accentDeepBlue)
                                .cornerRadius(20)
                        }
                        .disabled(inputText.isEmpty || isLoading)
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
        let newMessage = TextMessage(text: inputText)
        messages.append(ChatMessage(message: newMessage, id: messages.count, isUser: true))
        inputText = ""
        
        isLoading = true
        
        ChatAPI.shared.sendMessage(message: newMessage) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let responseMessage):
                    messages.append(ChatMessage(message: responseMessage, id: messages.count, isUser: false))
                case .failure(let error):
                    // Handle error (e.g., show an alert)
                    let errorMessage = TextMessage(text: "Error: \(error.localizedDescription)")
                    messages.append(ChatMessage(message: errorMessage, id: messages.count, isUser: false))
                }
            }
        }
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
