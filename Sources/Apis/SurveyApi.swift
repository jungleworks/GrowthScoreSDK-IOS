//
//  SurveyAPI.swift
//  GrowthScore
//

import Foundation


// MARK: - API
public final class SurveyAPI {

    public static let shared = SurveyAPI()
    private init() {}

    public func startSurvey(completion: @escaping (Result<SurveyResponse, Error>) -> Void
    ) {

        guard
            let appKey = GrowthConfig.shared.appKey,
            let authToken = GrowthConfig.shared.authToken
        else {
            completion(.failure(NSError(
                domain: "SurveyAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "SDK not initialized properly"]
            )))
            return
        }

        let payload = SurveyPayload(
            storeId: GrowthConfig.shared.userDetails?.storeId ?? "",
            emailId: GrowthConfig.shared.userDetails?.email ?? "",
            campaignId: GrowthConfig.shared.initResponse?.campaignid ?? 0,
            uniqueId:  GrowthConfig.shared.uniqueId
        )

        guard let url = APIConfig.Endpoint.startSurvey(appKey: GrowthConfig.shared.appKey ?? "").url else {
            completion(.failure(NSError(
                domain: "SurveyAPI",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )))
            return
        }
        do {
            let bodyData = try JSONEncoder().encode(payload)

            let headers = [
                "Content-Type": "application/json",
                "x-gsauthtoken": authToken,
                "Origin": "https://app.growthscore.io",
                "Referer": "https://app.growthscore.io/",
                "Accept": "*/*"
            ]

            NetworkManager.shared.performRequest(
                url: url,
                method: "POST",
                headers: headers,
                body: bodyData
            ) { (result: Result<SurveyResponse, Error>) in

                switch result {
                case .success(let response):
                    GrowthConfig.shared.saveSurveyResponse(response)
                    
                    print("✅ Survey saved. Activity ID:", response.activityId ?? -1)
                    completion(.success(response))

                case .failure(let error):
                    completion(.failure(error))
                }
            }

        } catch {
            completion(.failure(error))
        }
    }
}
