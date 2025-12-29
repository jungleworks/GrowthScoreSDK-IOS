//
//  StartSurveyDataModel.swift
//  Pods
//
//  Created by Neha on 18/12/25.
//

import Foundation

// MARK: - Data Models

public struct SurveyResponse: Codable {
    public let activityId: Int?
    public let success: Bool
    public let statusCode: Int?
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case activityId = "activityid"
        case success
        case statusCode = "statuscode"
        case message
    }
}

