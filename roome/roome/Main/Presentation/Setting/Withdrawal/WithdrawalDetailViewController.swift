//
//  WithdrawalDetailViewController.swift
//  roome
//
//  Created by minsong kim on 7/11/24.
//

import UIKit
import Combine
import FirebaseAnalytics

class WithdrawalDetailViewController: UIViewController {
    private let placeHolderText = "내용을 작성해주세요"
    private let backButton = BackButton()
    
    private let jumpButton: UIButton = {
        let button = UIButton()
        button.setTitle("넘어가기", for: .normal)
        button.titleLabel?.font = .boldTitle3
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "더 나은 루미가 될 수 있도록\n의견을 들려주세요"
        label.numberOfLines = 2
        label.sizeToFit()
        label.textAlignment = .left
        label.font = .boldTitle2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.font = .regularBody2
        view.text = placeHolderText
        view.textColor = .gray
        view.textContainerInset = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        
        return view
    }()
    
    lazy var remainCountLabel: UILabel = {
        let label = UILabel()
        label.text = "/3000"
        label.font = .mediumCaption
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let nextButton = NextButton(title: "확인", backgroundColor: .roomeMain, tintColor: .white)
    private var nextButtonWidthConstraint: NSLayoutConstraint?
    
    private var viewModel: WithdrawalViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: WithdrawalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        textView.delegate = self
        configureUI()
        bind()
    }
    
    private func bind() {
        textView.publisher
            .receive(on: RunLoop.main)
            .assign(to: &viewModel.$textInput)
        
        backButton.publisher(for: .touchUpInside)
            .sink { [weak self] in
                self?.dismiss(animated: false)
            }
            .store(in: &cancellables)
        
        jumpButton.publisher(for: .touchUpInside)
            .sink { [weak self] in
                let next = DIContainer.shared.resolve(WithdrawalAgreeViewController.self)
                next.modalPresentationStyle = .fullScreen
                self?.present(next, animated: false)
            }
            .store(in: &cancellables)
        
        nextButton.publisher(for: .touchUpInside)
            .map {
                Analytics.logEvent(Tracking.Withdrawal.reasonNextButton, parameters: nil)
            }
            .sink { [weak self] in
                let next = DIContainer.shared.resolve(WithdrawalAgreeViewController.self)
                next.modalPresentationStyle = .fullScreen
                self?.present(next, animated: false)
            }
            .store(in: &cancellables)
    }
    
    private func configureUI() {
        configureNavigationBar()
        configureTitle()
        configureTextView()
        configureNextButton()
        registerKeyboardListener()
    }
    
    private func configureNavigationBar() {
        view.addSubview(backButton)
        view.addSubview(jumpButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            
            jumpButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            jumpButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }
    
    private func configureTitle() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func configureTextView() {
        view.addSubview(textView)
        view.addSubview(remainCountLabel)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            remainCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
            remainCountLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            remainCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }
    
    private func configureNextButton() {
        view.addSubview(nextButton)
        
        nextButtonWidthConstraint = nextButton.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9)
        nextButtonWidthConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension WithdrawalDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeHolderText
            textView.textColor = .gray
            remainCountLabel.text = "/3000"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
            let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)

            let characterCount = newString.count
            guard characterCount <= 3000 else { return false }
            remainCountLabel.text = "\(characterCount)/3000"

            return true
        }
}

extension WithdrawalDetailViewController {
    private func registerKeyboardListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        nextButton.layer.cornerRadius = 0
        
        nextButtonWidthConstraint?.isActive = false
        nextButtonWidthConstraint = nextButton.widthAnchor.constraint(equalToConstant: view.frame.width)
        nextButtonWidthConstraint?.isActive = true
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        nextButton.layer.cornerRadius = 10
        
        nextButtonWidthConstraint?.isActive = false
        nextButtonWidthConstraint = nextButton.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9)
        nextButtonWidthConstraint?.isActive = true
    }
}

//
//#Preview {
//    let vc = WithdrawalDetailViewController()
//    
//    return vc
//}
