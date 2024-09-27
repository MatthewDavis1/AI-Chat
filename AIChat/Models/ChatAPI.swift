import Foundation

enum ChatError: Error {
    case invalidURL
    case noData
    case decodingError
}

class ChatAPI {
    static let shared = ChatAPI()
    private init() {}
    
    let baseURL = "http://127.0.0.1:8000" // Update if different
    
    func sendMessage(message: BaseMessage, completion: @escaping (Result<any BaseMessage, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat") else {
            completion(.failure(ChatError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(message)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ChatError.noData))
                return
            }
            
            // Decode to GenericMessage first
            do {
                let genericMessage = try JSONDecoder().decode(GenericResponse.self, from: data)
                let jsonData = Data(genericMessage.json_content.utf8)
                
                switch genericMessage.message_type {
                case "TextMessage":
                    if let message = try? JSONDecoder().decode(TextMessage.self, from: jsonData) {
                        completion(.success(message))
                    } else {
                        completion(.failure(ChatError.decodingError))
                    }
                case "MultiSelectMessage":
                    if let message = try? JSONDecoder().decode(MultiSelectMessage.self, from: jsonData) {
                        completion(.success(message))
                    } else {
                        completion(.failure(ChatError.decodingError))
                    }
                case "PickerMessage":
                    if let message = try? JSONDecoder().decode(PickerMessage.self, from: jsonData) {
                        completion(.success(message))
                    } else {
                        completion(.failure(ChatError.decodingError))
                    }
                case "RatingMessage":
                    if let message = try? JSONDecoder().decode(RatingMessage.self, from: jsonData) {
                        completion(.success(message))
                    } else {
                        completion(.failure(ChatError.decodingError))
                    }
                case "YesNoMessage":
                    if let message = try? JSONDecoder().decode(YesNoMessage.self, from: jsonData) {
                        completion(.success(message))
                    } else {
                        completion(.failure(ChatError.decodingError))
                    }
                default:
                    completion(.failure(ChatError.decodingError))
                }
            } catch {
                completion(.failure(ChatError.decodingError))
            }
        }
        
        task.resume()
    }
}
