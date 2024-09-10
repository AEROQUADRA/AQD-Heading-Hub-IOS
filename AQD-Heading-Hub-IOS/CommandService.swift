import Foundation

class CommandService {
    let baseURL = "http://192.168.4.1/"  // The IP address of your ESP8266

    // Method to send commands to the ESP8266
    func sendCommand(_ command: String, leftSpeed: Int, rightSpeed: Int, completion: @escaping (Result<String, Error>) -> Void) {
        // Construct the command URL
        let commandURL = "\(baseURL)\(command)?leftSpeed=\(leftSpeed)&rightSpeed=\(rightSpeed)"
        
        // Ensure the URL is valid
        guard let url = URL(string: commandURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // Create a URLSession task to send the command
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            completion(.success(responseString))
        }
        
        task.resume()  // Start the request
    }
}
