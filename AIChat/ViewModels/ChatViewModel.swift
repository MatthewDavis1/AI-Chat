import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var messages: [ChatMessage] = [
        ChatMessage(message: TextMessage(text: "Hello! How can I assist you today?"), id: 0, isUser: false)
    ]
    @Published var isAtBottom: Bool = true
    @Published var showNewMessageAlert: Bool = false
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe changes to messages to handle auto-scrolling and alerts
        $messages
            .sink { [weak self] newMessages in
                guard let self = self else { return }
                if self.isAtBottom {
                    // Automatically scroll to bottom if already there
                    // Handled in View via onChange
                } else {
                    // Show alert if new message arrives and not at bottom
                    self.showNewMessageAlert = true
                }
            }
            .store(in: &cancellables)
    }

    func clearMessages() {
        messages.removeAll()
        // Optionally, add a default message after clearing
        messages.append(ChatMessage(message: TextMessage(text: "Chat cleared."), id: messages.count, isUser: false))
    }

    func sendMessage() {
        guard !inputText.isEmpty else { return }
        let newMessage = TextMessage(text: inputText)
        let userChatMessage = ChatMessage(message: newMessage, id: messages.count, isUser: true)
        messages.append(userChatMessage)
        inputText = ""

        isLoading = true

        ChatAPI.shared.sendMessage(message: newMessage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let responseMessage):
                    let botChatMessage = ChatMessage(message: responseMessage, id: self.messages.count, isUser: false)
                    self.messages.append(botChatMessage)
                case .failure(let error):
                    // Handle error (e.g., show an alert)
                    let errorMessage = TextMessage(text: "Error: \(error.localizedDescription)")
                    let errorChatMessage = ChatMessage(message: errorMessage, id: self.messages.count, isUser: false)
                    self.messages.append(errorChatMessage)
                }
            }
        }
    }

    func sendResponseMessage(_ message: TextMessage) {
        isLoading = true

        ChatAPI.shared.sendMessage(message: message) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let responseMessage):
                    let botChatMessage = ChatMessage(message: responseMessage, id: self.messages.count, isUser: false)
                    self.messages.append(botChatMessage)
                case .failure(let error):
                    let errorMessage = TextMessage(text: "Error: \(error.localizedDescription)")
                    let errorChatMessage = ChatMessage(message: errorMessage, id: self.messages.count, isUser: false)
                    self.messages.append(errorChatMessage)
                }
            }
        }
    }
}
