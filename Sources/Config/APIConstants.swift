//
//  APIConstants.swift
//  GrowthScore
//
//  Created by Neha on 18/12/25.
//

import Foundation

enum APIConfig {
    // MARK: - Base URLs
    static let baseURL = "https://web.growthscore.io/"
    
    // MARK: - Endpoints
    enum Endpoint {
        case check(appKey: String)
        case startSurvey(appKey: String)
        case submitScore(appKey: String)
        
        var path: String {
            switch self {
            case .check(let appKey):
                return "web/v2_0/check/\(appKey)"
            case .startSurvey(let appKey):
                return "web/v1_0/survey/\(appKey)"
            case .submitScore(let appKey):
                return "web/v1_0/submit/\(appKey)"
            
            }
        }
        
        var url: URL? {
            return URL(string: APIConfig.baseURL + self.path)
        }
    }
}
