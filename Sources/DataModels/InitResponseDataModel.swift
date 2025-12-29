//
//  InitResponse.swift
//  GrowthScore
//
//  Created by Neha on 17/12/25.
//

import Foundation

public struct InitResponseDataModel: Codable {
    public let success: Bool?
    public let statuscode: Int?
    public let message: String?
    public let accountid: Int?
    public let brandname: String?
    public let contactid: Int?
    public let referralcode: String?
    public let referrallink: String?
    public let firstname: String?
    public let lastname: String?
    public let campaignid: Int?
    public let iseligible: Bool?
    public let isexistinguser: Bool?
    public let hasreferrer: Bool?
    public let nps: NPS?
    public let referral: Referral?

    // MARK: - Shared Instance
    public static var shared: InitResponseDataModel?

    public struct NPS: Codable {
        public let displayquestion: String?
        public let feedbackquestion: String?
        public let feedbackplaceholder: String?
        public let scaletags: ScaleTags?
        public let submitbutton: String?
        public let cancelbutton: String?
        public let buttoncolor: String?
        public let buttonstyle: String?
        public let buttonshape: String?
        public let brandname: String?
        public let thankyou: [ThankYou]?
        
        public struct ScaleTags: Codable {
            public let likely: String?
            public let notlikely: String?
        }

        public struct ThankYou: Codable {
            public let category: String?
            public let heading: String?
            public let message: String?
            public let buttontext: String?
            public let buttonlink: String?
        }
    }

    public struct Referral: Codable {
        // Define fields if the referral object is ever returned
    }
}
