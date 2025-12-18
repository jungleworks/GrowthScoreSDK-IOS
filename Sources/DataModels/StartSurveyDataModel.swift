//
//  StartSurveyDataModel.swift
//  Pods
//
//  Created by Neha on 18/12/25.
//

import Foundation

// MARK: - Data Models
public struct SurveyPayload: Codable {
    public let storeId: String
    public let emailId: String
    public let campaignId: Int
    public let uniqueId: String

    enum CodingKeys: String, CodingKey {
        case storeId = "storeid"
        case emailId = "emailid"
        case campaignId = "campaignid"
        case uniqueId = "uniqueid"
    }
}

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

// MARK: - Error Handling
public enum SurveyError: LocalizedError {
    case uninitialized
    case invalidURL
    case encodingError
    
    public var errorDescription: String? {
        switch self {
        case .uninitialized: return "GrowthScore SDK is not properly initialized."
        case .invalidURL:    return "The generated survey URL is invalid."
        case .encodingError: return "Failed to encode survey payload."
        }
    }
}
