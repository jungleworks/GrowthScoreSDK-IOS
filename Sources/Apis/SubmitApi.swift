//
//  SubmitAPI.swift
//  GrowthScore
//
//  Created by Neha on 18/12/25.
//

import Foundation


// MARK: - API
public final class SubmitAPI {

    public static let shared = SubmitAPI()
    private init() {}

    /// Submit score API
    public func submitScore(
        score: Int,
        completion: @escaping (Result<SubmitResponse, Error>) -> Void) {

        guard
            let appKey = GrowthConfig.shared.appKey,
            let authToken = GrowthConfig.shared.authToken
        else {
            completion(.failure(NSError(
                domain: "SubmitAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Submit prerequisites missing"]
            )))
            return
        }

        let payload = SubmitPayload(
            storeid: GrowthConfig.shared.userDetails?.storeId ?? "",
            emailid: GrowthConfig.shared.userDetails?.email ?? "",
            campaignid: GrowthConfig.shared.initResponse?.campaignid ?? 0,
            activityid: String(GrowthConfig.shared.surveyResponse?.activityId ?? 0),
            score: String(score),
            uniqueid:  GrowthConfig.shared.uniqueId
        )

        guard let url = APIConfig.Endpoint.submitScore(appKey: appKey).url else {
            completion(.failure(NSError(
                domain: "SubmitAPI",
                code: -2,
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
                body: bodyData,
                completion: completion
            )

        } catch {
            completion(.failure(error))
        }
    }
    
    
    
    public func submitSurvey(score: Int,
           feedback: String?,
           completion: @escaping (Result<SubmitSurveyResponse, Error>) -> Void
       ) {

           guard
               let appKey = GrowthConfig.shared.appKey,
               let authToken = GrowthConfig.shared.authToken
           else {
               completion(.failure(NSError(
                   domain: "SurveyAPI",
                   code: -1,
                   userInfo: [NSLocalizedDescriptionKey: "SDK not initialized"]
               )))
               return
           }

           let payload = SubmitSurveyPayload(
            storeid: GrowthConfig.shared.userDetails?.storeId ?? "",
            emailid: GrowthConfig.shared.userDetails?.email ?? "",
            campaignid: GrowthConfig.shared.initResponse?.campaignid ?? 0,
            uniqueid:  GrowthConfig.shared.uniqueId,
            score: String(score),
            feedback: feedback
           )

           guard let url = APIConfig.Endpoint.submitScore(appKey: appKey).url else {
               completion(.failure(NSError(
                   domain: "SurveyAPI",
                   code: -2,
                   userInfo: [NSLocalizedDescriptionKey: "Invalid submit URL"]
               )))
               return
           }

           do {
               let body = try JSONEncoder().encode(payload)
               let headers: [String: String] = [
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
                   body: body
               ) { (result: Result<SubmitSurveyResponse, Error>) in

                   switch result {
                   case .success(let response):
                       GrowthConfig.shared.saveSubmitSurveyResponse(response)
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
