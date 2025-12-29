//
//  SurveyAPI.swift
//  GrowthScore
//

import Foundation


// MARK: - API
public final class SurveyAPI {
    
    public static let shared = SurveyAPI()
    private init() {}
    
    public func startSurvey(completion: @escaping (Result<SurveyResponse, Error>) -> Void) {
        guard
            let appKey = GrowthConfig.shared.appKey,
            let authToken = GrowthConfig.shared.authToken,
            let userDetails = GrowthConfig.shared.userDetails,
            let initData = GrowthConfig.shared.initResponse
        else {
            completion(.failure(NSError(domain: "SurveyAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"])))
            return
        }

        guard let url = APIConfig.Endpoint.startSurvey(appKey: appKey).url else { return }

        let body: [String: Any] = [
            "storeid": userDetails.storeId,
            "emailid": userDetails.email,
            "campaignid": initData.campaignid ?? 0,
            "uniqueid": GrowthConfig.shared.uniqueId
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return }

        let headers: [String: String] = [
            "x-gsauthtoken": authToken,
            "Content-Type": "application/json",
            "Accept": "*/*",
            "Origin": "https://app.growthscore.io",
            "Referer": "https://app.growthscore.io/",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15"
        ]

        print("🔄 Starting Survey (v1_0)...headers \(headers) Payload: \(body)")

        NetworkManager.shared.performRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: bodyData
        ) { (result: Result<SurveyResponse, Error>, response: HTTPURLResponse?) in
            
            if let status = response?.statusCode, status == 401 {
                print("❌ 401 Unauthorized")
            }
            
            switch result {
            case .success(let model):
                GrowthConfig.shared.saveSurveyResponse(model)
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

