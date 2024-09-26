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
    
    func sendMessage(message: TextMessage, completion: @escaping (Result<any Message, Error>) -> Void) {
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
            
            do {
                // Decode to any of the possible message types
                if let textMessage = try? JSONDecoder().decode(TextMessage.self, from: data) {
                    completion(.success(textMessage))
                } else if let multiSelectMessage = try? JSONDecoder().decode(MultiSelectMessage.self, from: data) {
                    completion(.success(multiSelectMessage))
                } else if let pickerMessage = try? JSONDecoder().decode(PickerMessage.self, from: data) {
                    completion(.success(pickerMessage))
                } else if let ratingMessage = try? JSONDecoder().decode(RatingMessage.self, from: data) {
                    completion(.success(ratingMessage))
                } else if let yesNoMessage = try? JSONDecoder().decode(YesNoMessage.self, from: data) {
                    completion(.success(yesNoMessage))
                } else {
                    completion(.failure(ChatError.decodingError))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
