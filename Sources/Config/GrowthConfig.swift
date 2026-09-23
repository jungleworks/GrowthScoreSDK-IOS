//
//  GrowthConfig.swift
//  GrowthScore
//
//  Created by Neha on 17/12/25.
//

import Foundation

public class GrowthConfig {

    // MARK: - SharedInstance
    public static let shared = GrowthConfig()
    private init() {}

    // MARK: - Public Variables
    public var appKey: String?
    public var authToken: String?
    public var uniqueId = Utils.getUDID()
    public var userDetails: GrowthScoreUserDetails?
    public private(set) var initResponse: InitResponseDataModel?
    public private(set) var surveyResponse: SurveyResponse?
    public private(set) var submitSurveyResponse: SubmitSurveyResponse?

    // MARK: - App Store In-App Review Settings

    /// Master switch for the App Store in-app review prompt.
    public var appReviewEnabled: Bool = true

    /// Lowest score that counts as a promoter. Defaults to 9, so 9 and 10 qualify.
    public var appReviewMinScore: Int = 9

    /// How long to wait after a promoter score before the prompt becomes eligible.
    /// Defaults to 48 hours. Use this for short delays, e.g. 1 during testing.
    public var appReviewDelayMinutes: Int = 48 * 60

    /// The same delay expressed in hours. Reads and writes `appReviewDelayMinutes`,
    /// so the two can never disagree. Reading it after setting a delay that is not
    /// a whole number of hours rounds down.
    public var appReviewDelayHours: Int {
        get { appReviewDelayMinutes / 60 }
        set { appReviewDelayMinutes = newValue * 60 }
    }

    // MARK: - Internal State Updates
    internal func saveInitResponse(_ response: InitResponseDataModel) {
        self.initResponse = response
    }

    internal func saveSurveyResponse(_ response: SurveyResponse) {
        self.surveyResponse = response
    }
    
    internal func saveSubmitSurveyResponse(_ response: SubmitSurveyResponse) {
        self.submitSurveyResponse = response
    }
    
    // MARK: - Score Popup
    public func showScorePopup(onScoreSelected: ((Int, String?) -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let topVC = self.topViewController() else { return }
            let popup = ScorePopupViewController()
            popup.didSelectScore = onScoreSelected
            popup.show(over: topVC)
        }
    }
    
    // MARK: - Initialize SDK API
    public  func growthInit(firstName: String?, lastName: String?, storeId: String?, email: String?, phone: String?, isSurveyNow: Bool,languagecode: String?, attributes: [String: String]? = nil, completion: @escaping (Result<InitResponseDataModel, Error>) -> Void) {
        let user = GrowthScoreUserDetails(
            firstName: firstName ?? "",
            lastName: lastName ?? "",
            storeId: storeId ?? "",
            email: email ?? "",
            phone: phone ?? "",
            surveyNow: isSurveyNow,
            languagecode: languagecode,
            attributes: attributes
        )
        FontLoader.registerFonts()
        InitAPI.initializeSDK(user: user) { result in
            switch result {
            case .success(let response):
                print("Init Success:", response)
                completion(.success(response))
            case .failure(let error):
                print("Init Failed:", error)
                completion(.failure(error))
                //self.showSuccessAlert(message: "Growthscore Init Failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Start Survey API
    
    public func startSurvey(attributes: [String: String]? = nil) {
        SurveyAPI.shared.startSurvey(attributes: attributes) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    GrowthConfig.shared.showScorePopup { score, comment in
                        print("Score: \(score), Comment: \(comment ?? "")")
                        GrowthConfig.shared.submitSurvey(
                            score: score,
                            feedback: comment
                        ) { isSuccess in
                            let msg = isSuccess
                            ? GrowthConfig.shared.initResponse?.nps?.thankyou?.first?.heading ?? ""
                            : GrowthConfig.shared.submitSurveyResponse?.message ?? ""
                            self.showSuccessAlert(message: msg)
                        }
                    }
                }

            case .failure(let error):
                self.showSuccessAlert(message: "Failed to start survey: \(error.localizedDescription)")
                print("Failed to start survey:", error.localizedDescription)
            }
        }
    }

    
    // MARK: - Submit Survey API
    
    public func submitSurvey(score: Int?, feedback: String?, completion: @escaping (Bool) -> Void) {
        SubmitAPI.shared.submitSurvey(score: score ?? 0, feedback: feedback) { result in
            switch result {
            case .success(let response):
                print("Survey submitted successfully: \(response)")
                completion(true)
            case .failure(let error):
                print("Failed to submit survey: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    // MARK: - Headless Survey Submission (no built-in popup UI)

    public func submitCustomSurvey(
        score: Int,
        feedback: String? = nil,
        attributes: [String: String]? = nil,
        completion: @escaping (Result<SubmitSurveyResponse, Error>) -> Void
    ) {
        SurveyAPI.shared.startSurvey(attributes: attributes) { result in
            switch result {
            case .success:
                SubmitAPI.shared.submitSurvey(score: score, feedback: feedback) { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - App Store In-App Review

    /// Shows the App Store review prompt over `scene` if a promoter score was
    /// submitted and `appReviewDelayMinutes` have since elapsed. Cheap to call from
    /// any screen becoming active: it is a UserDefaults read and returns immediately
    /// when the prompt is not due.
    ///
    /// Shows at most once per install. `completion` is called on the main thread and
    /// reports whether the request was made, not whether the user left a review.
    public func checkAndShowAppReview(
        in scene: UIWindowScene?,
        completion: ((Bool) -> Void)? = nil
    ) {
        AppReviewManager.checkAndShow(in: scene, completion: completion)
    }

    /// Convenience for hosts that have a view controller rather than a scene.
    public func checkAndShowAppReview(
        from viewController: UIViewController,
        completion: ((Bool) -> Void)? = nil
    ) {
        checkAndShowAppReview(in: viewController.view.window?.windowScene, completion: completion)
    }

    /// Clears the review prompt's stored state so a later promoter score can arm it again.
    public func resetAppReviewState() {
        AppReviewManager.reset()
    }

    private func showSuccessAlert(message: String) {
        DispatchQueue.main.async {
            guard let topVC = self.topViewController() else { return }
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topVC.present(alert, animated: true)
        }
    }


    // Helper: Find root view controller for iOS 12 and iOS 13+
    private func getRootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .foregroundActive })
            let window = windowScene?.windows
                .first(where: { $0.isKeyWindow }) ??
                windowScene?.windows.first(where: { $0.windowLevel == .normal && !$0.isHidden })
            return window?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }

    // Helper: Traverse to topmost presented view controller
    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC = base ?? getRootViewController()
        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = baseVC as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        } else if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseVC
    }
}

struct Utils {
    static func getUDID() -> String {
        return s4() + s4() + s4() + s4()
    }

    private static func s4() -> String {
        let randomNumber = Int.random(in: 0x10000...0x1FFFF)
        let hexString = String(randomNumber, radix: 16)
        return String(hexString.dropFirst())
    }
}
