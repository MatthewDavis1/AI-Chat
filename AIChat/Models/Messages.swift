import Foundation

protocol BaseMessage: Codable {
    var text: String { get }
}

struct TextMessage: BaseMessage {
    let text: String
}

struct MultiSelectMessage: BaseMessage {
    let text: String
    let options: [String]
}

struct PickerMessage: BaseMessage {
    let text: String
    let options: [String]
}

struct RatingMessage: BaseMessage {
    let text: String
    let rangeLow: Int
    let rangeHigh: Int
}

struct YesNoMessage: BaseMessage {
    let text: String
}
