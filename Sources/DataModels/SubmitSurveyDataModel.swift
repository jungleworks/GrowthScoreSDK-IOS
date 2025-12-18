//
//  SubmitSurveyDataModel.swift
//  Pods
//
//  Created by Neha on 18/12/25.
//

import Foundation

// MARK: - Models
public struct SubmitResponse: Codable {
    public let success: Bool
    public let statusCode: Int?
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case success, message
        case statusCode = "statuscode"
    }
}

public struct SubmitSurveyResponse: Codable {
    public let success: Bool?
    public let activityId: String?
    public let statusCode: Int?
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case success, message
        case activityId = "activityid"
        case statusCode = "statuscode"
    }
}

// MARK: - Payloads
public struct SubmitPayload: Codable {
    let storeid: String
    let emailid: String
    let campaignid: Int
    let activityid: String
    let score: String
    let uniqueid: String
}

public struct SubmitSurveyPayload: Codable {
    let storeid: String
    let emailid: String
    let campaignid: Int
    let uniqueid: String
    let score: String
    let feedback: String?
}
