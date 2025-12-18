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

    /// Performs a network request and returns either a typed Codable object or the raw JSON dictionary
    public func performRequest<T: Codable>(url: URL,
                                           method: String = "POST",
                                           headers: [String: String] = [:],
                                           body: Data? = nil,
                                           completion: @escaping (Result<T, Error>) -> Void) {

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            print(url)
            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkManager", code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            // Print raw JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }

            do {
                // Try decoding to the expected Codable type
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                // If decoding fails, fallback to raw dictionary
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Decoding failed, returning raw JSON dictionary instead")
                        print(json)
                    }
                } catch {
                    print("Failed to parse JSON:", error)
                }
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
