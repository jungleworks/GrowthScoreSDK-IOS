//
//  InitApi.Swift
//  GrowthScore
//
//  Created by Neha on 17/12/25.
//

import Foundation

public class InitAPI {

    // MARK: - Stored Init Response
    public static private(set) var lastInitResponse: InitResponseDataModel?

    public static func initializeSDK(user: GrowthScoreUserDetails,
                                         completion: @escaping (Result<InitResponseDataModel, Error>) -> Void) {

            // Use the new APIConfig here
            guard let url = APIConfig.Endpoint.check(appKey: GrowthConfig.shared.appKey ?? "").url else {
                completion(.failure(NSError(domain: "InitAPI", code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            // Headers
            let headers: [String: String] = [
                "Content-Type": "application/json",
                "x-gsauthtoken": GrowthConfig.shared.authToken ?? ""
            ]

        // Convert GrowthScoreUser to JSON
        let body: [String: Any] = [
            "firstname": user.firstName,
            "lastname": user.lastName,
            "storeid": user.storeId,
            "emailid": user.email,
            "phonenumber": user.phone,
            "surveynow": user.surveyNow
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion(.failure(NSError(domain: "InitAPI", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid request body"])))
            return
        }
        GrowthConfig.shared.userDetails = user
        // Perform network request
        NetworkManager.shared.performRequest(url: url,
                                             method: "POST",
                                             headers: headers,
                                             body: bodyData,
                                             completion: { (result: Result<InitResponseDataModel, Error>) in
            switch result {
            case .success(let response):
                print("Success flag:", response.success)
                print("Message:", response.message ?? "No message")
                InitAPI.lastInitResponse = response
                InitResponseDataModel.shared = response
                GrowthConfig.shared.saveInitResponse(response)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        })


    }

    // MARK: - Helper to access last init data anywhere in SDK
    public static func getLastInitResponse() -> InitResponseDataModel? {
        return lastInitResponse
    }
}
