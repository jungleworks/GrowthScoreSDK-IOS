//
//  NetworkManager.Swift
//  GrowthScore
//
//  Created by Neha on 17/12/25.
//

import Foundation

public class NetworkManager {

    public static let shared = NetworkManager()
    private init() {}

    /// Performs a network request and returns a typed Codable object along with HTTPURLResponse
    public func performRequest<T: Codable>(url: URL,
                                           method: String = "POST",
                                           headers: [String: String] = [:],
                                           body: Data? = nil,
                                           // Change: Added HTTPURLResponse? to the completion tuple
                                           completion: @escaping (Result<T, Error>, HTTPURLResponse?) -> Void) {

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Cast the response to HTTPURLResponse to access headers
            let httpResponse = response as? HTTPURLResponse
            
            if let error = error {
                completion(.failure(error), httpResponse)
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkManager", code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "No data"])), httpResponse)
                return
            }

            // Print raw JSON and Headers for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("--- Network Debug ---")
                print("URL: \(url)")
                print("FINAL HEADERS:", request.allHTTPHeaderFields ?? [:])
                print("Status Code: \(httpResponse?.statusCode ?? 0)")
                print("Server Response: \(jsonString)")
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                // Success: return decoded data and response metadata
                completion(.success(decoded), httpResponse)
            } catch {
                // Fallback debugging
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Decoding failed. Raw JSON: \(json)")
                }
                completion(.failure(error), httpResponse)
            }
        }

        task.resume()
    }
}
