//
//  ScorePopupViewController.swift
//  GrowthScore
//
//  Created by Neha on 17/12/25.
//

import UIKit

public class ScorePopupViewController: UIViewController {
    
    public var didSelectScore: ((Int, String?) -> Void)?
    private var selectedScore: Int?
    private let themeColor = UIColor(hex: GrowthConfig.shared.initResponse?.nps?.buttoncolor ?? "#3baad9")
    
    // MARK: - UI Elements
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
        button.setTitleColor(.lightGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        let rawText = GrowthConfig.shared.initResponse?.nps?.displayquestion?.urlDecoded ?? "How likely are you to recommend us?"
        label.text = rawText
        label.font = .growthBold(size: 16)
        label.textColor = UIColor(white: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // --- Score UI Group ---
    private let scoresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var legendStackView: UIStackView = {
        let left = UILabel(); left.text = GrowthConfig.shared.initResponse?.nps?.scaletags?.notlikely ?? "Not Likely"
        left.font = .growthRegular(size: 13); left.textColor = .lightGray
        let right = UILabel(); right.text = GrowthConfig.shared.initResponse?.nps?.scaletags?.likely ?? "Very Likely"
        right.font = .growthRegular(size: 13); right.textColor = .lightGray
        let stack = UIStackView(arrangedSubviews: [left, right])
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // --- Feedback UI Group (Hidden initially) ---
    private let feedbackTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 4
        tv.font = .growthRegular(size: 14)
        tv.isHidden = true
        tv.alpha = 0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let feedbackPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell us more.."
        label.textColor = .systemGray3
        label.font = .growthRegular(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private func setupFeedbackTextViewPlaceholder() {
        feedbackTextView.addSubview(feedbackPlaceholderLabel)

        NSLayoutConstraint.activate([
            feedbackPlaceholderLabel.topAnchor.constraint(
                equalTo: feedbackTextView.topAnchor,
                constant: 8
            ),
            feedbackPlaceholderLabel.leadingAnchor.constraint(
                equalTo: feedbackTextView.leadingAnchor,
                constant: 5
            )
        ])
    }

    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(GrowthConfig.shared.initResponse?.nps?.submitbutton ?? "Submit Feedback", for: .normal)
        btn.backgroundColor = themeColor
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .growthBold(size: 15)
        btn.layer.cornerRadius = 4
        btn.isHidden = true
        btn.alpha = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        let attrText = NSMutableAttributedString(string: "Powered by ", attributes: [.foregroundColor: UIColor.lightGray])
        attrText.append(NSAttributedString(string: "GrowthScore", attributes: [.foregroundColor: UIColor.gray]))
        label.attributedText = attrText
        label.font = .growthRegular(size: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var keyboardToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )

        toolbar.items = [flexSpace, doneButton]
        return toolbar
    }()
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupScores()
        setupKeyboardObservers()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        [closeButton, titleLabel, scoresStackView, legendStackView, feedbackTextView, submitButton, footerLabel].forEach {
            containerView.addSubview($0)
        }
        feedbackTextView.delegate = self
        feedbackTextView.inputAccessoryView = keyboardToolbar
        setupFeedbackTextViewPlaceholder()
        closeButton.addTarget(self, action: #selector(dismissWithAnimation), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.94),
            containerView.bottomAnchor.constraint(equalTo: footerLabel.bottomAnchor, constant: 15),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Score Constraints
            scoresStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            scoresStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            scoresStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            scoresStackView.heightAnchor.constraint(equalToConstant: 30),
            
            legendStackView.topAnchor.constraint(equalTo: scoresStackView.bottomAnchor, constant: 8),
            legendStackView.leadingAnchor.constraint(equalTo: scoresStackView.leadingAnchor),
            legendStackView.trailingAnchor.constraint(equalTo: scoresStackView.trailingAnchor),
            
            // Feedback Constraints (Overlap area)
            feedbackTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            feedbackTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            feedbackTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            feedbackTextView.heightAnchor.constraint(equalToConstant: 80),
            
            submitButton.topAnchor.constraint(equalTo: feedbackTextView.bottomAnchor, constant: 15),
            submitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            submitButton.widthAnchor.constraint(equalToConstant: 140),
            submitButton.heightAnchor.constraint(equalToConstant: 38),
            
            footerLabel.topAnchor.constraint(greaterThanOrEqualTo: legendStackView.bottomAnchor, constant: 20),
            footerLabel.topAnchor.constraint(greaterThanOrEqualTo: submitButton.bottomAnchor, constant: 20),
            footerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
    
    private func setupScores() {
        let style = GrowthConfig.shared.initResponse?.nps?.buttonshape?.lowercased() ?? "circle"
        for i in 1...10 {
            let btn = UIButton(type: .custom)
            btn.setTitle("\(i)", for: .normal)
            btn.titleLabel?.font = .growthRegular(size: 14)
            btn.backgroundColor = .white
            btn.setTitleColor(themeColor, for: .normal)
            btn.layer.borderWidth = 1
            btn.layer.borderColor = themeColor.cgColor
            
            switch style {
            case "square":
                btn.layer.cornerRadius = 0
            case "rounded":
                btn.layer.cornerRadius = 6
            case "circle":
                btn.layer.cornerRadius = 15
            default:
                btn.layer.cornerRadius = 15
            }
            
            btn.tag = i
            btn.addTarget(self, action: #selector(scoreTapped(_:)), for: .touchUpInside)
            scoresStackView.addArrangedSubview(btn)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 30),
                btn.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    }
    
    @objc private func scoreTapped(_ sender: UIButton) {
        self.selectedScore = sender.tag
        
        // Fill range logic
        scoresStackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
            button.backgroundColor = (button.tag <= sender.tag) ? themeColor : .white
            button.setTitleColor((button.tag <= sender.tag) ? .white : themeColor, for: .normal)
            button.layer.borderWidth = (button.tag <= sender.tag) ? 0 : 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SubmitAPI.shared.submitScore(score: self.selectedScore ?? 0, completion: { (result) in
                switch result {
                case .success(let response):
                    print("Score submitted:", response.success)
                    DispatchQueue.main.async {
                        self.showFeedbackUI()
                    }
                    
                case .failure(let error):
                    print("Submit failed:", error.localizedDescription)
                }
            })
        }
    }
    
    @objc private func doneButtonTapped() {
        feedbackTextView.resignFirstResponder()
    }

    
    private func showFeedbackUI() {
        UIView.animate(withDuration: 0.3) {
            // Hide Score UI
            self.scoresStackView.alpha = 0
            self.legendStackView.alpha = 0
            
            // Show Feedback UI
            self.feedbackTextView.isHidden = false
            self.submitButton.isHidden = false
            self.feedbackTextView.alpha = 1
            self.submitButton.alpha = 1
            
            // Update Title
            self.titleLabel.text = GrowthConfig.shared.initResponse?.nps?.feedbackquestion
            self.titleLabel.font = .growthBold(size: 16)
            self.titleLabel.textAlignment = .left
        } completion: { _ in
            self.scoresStackView.isHidden = true
            self.legendStackView.isHidden = true
            self.feedbackTextView.becomeFirstResponder()
            self.setupFeedbackTextViewPlaceholder()
        }
    }
    
    @objc private func submitTapped() {
        didSelectScore?(selectedScore ?? 0, feedbackTextView.text)
        dismissWithAnimation()
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height / 3)
            }
        }
    }
    
    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
        }
    }
    
    @objc private func dismissWithAnimation() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.backgroundView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    public func show(over parent: UIViewController) {
        self.modalPresentationStyle = .overFullScreen
        self.backgroundView.alpha = 0
        self.containerView.transform = CGAffineTransform(translationX: 0, y: 500)
        parent.present(self, animated: false) {
            UIView.animate(withDuration: 0.4) {
                self.backgroundView.alpha = 1.0
                self.containerView.transform = .identity
            }
        }
    }
}

extension ScorePopupViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        feedbackPlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        feedbackPlaceholderLabel.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        feedbackPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
    
    

}
