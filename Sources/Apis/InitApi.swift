//
//  InitApi.Swift
//  GrowthScore
//
//  Created by Neha on 17/12/25.
//

import Foundation

public class InitAPI {
    
    // MARK: - Stored Init Response
   
    public static func initializeSDK(user: GrowthScoreUserDetails,
                                     completion: @escaping (Result<InitResponseDataModel, Error>) -> Void) {
        
        guard let url = APIConfig.Endpoint.check(appKey: GrowthConfig.shared.appKey ?? "").url else {
            completion(.failure(NSError(domain: "InitAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let headers: [String: String] = ["Content-Type": "application/json"]
        
        let body: [String: Any] = [
            "firstname": user.firstName,
            "lastname": user.lastName,
            "storeid": user.storeId,
            "emailid": user.email.lowercased(),
            "phonenumber": user.phone,
            "surveynow": user.surveyNow
        ]
      
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion(.failure(NSError(domain: "InitAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request body"])))
            return
        }
        
        GrowthConfig.shared.userDetails = user
        print(body)
        NetworkManager.shared.performRequest(url: url, method: "POST", headers: headers, body: bodyData) { (result: Result<InitResponseDataModel, Error>, response: HTTPURLResponse?) in

            switch result {
            case .success(let responseModel):
                if let fields = response?.allHeaderFields as? [AnyHashable: Any] {
                    if let tokenEntry = fields.first(where: { "\($0.key)".lowercased() == "x-gsauthtoken" }),
                       let token = tokenEntry.value as? String {
                        GrowthConfig.shared.authToken = token
                        print("Auth Token saved: \(token)")
                    } else {
                        print("❌ x-gsauthtoken header not found in response headers: \(fields)")
                    }
                }
                InitResponseDataModel.shared = responseModel
                GrowthConfig.shared.saveInitResponse(responseModel)
                completion(.success(responseModel))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
