import Foundation

// This is the message that the server will send to the client

struct GenericMessage: Codable {
    let message_type: String
    let json_content: String
}

