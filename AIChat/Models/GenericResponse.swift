import Foundation

// This is the message that the server will send to the client

struct GenericResponse: Codable {
    let message_type: String
    let json_content: String
}
