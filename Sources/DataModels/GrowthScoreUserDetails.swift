//
//  GrowthScoreUser.swift
//  GrowthScore
//
//  Created by Neha on 18/12/25.
//

import Foundation

public struct GrowthScoreUserDetails: Codable {
    public let firstName: String
    public let lastName: String
    public let storeId: String
    public let email: String
    public let phone: String
    public let surveyNow: Bool

    public init(
        firstName: String,
        lastName: String,
        storeId: String,
        email: String,
        phone: String,
        surveyNow: Bool
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.storeId = storeId
        self.email = email
        self.phone = phone
        self.surveyNow = surveyNow
    }
}
