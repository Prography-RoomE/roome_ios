//
//  SignOutViewController.swift
//  roome
//
//  Created by minsong kim on 6/4/24.
//

import UIKit
import Combine

class SignOutViewController: UIViewController {
    private let signOutButton = NextButton(title: "탈퇴하기", backgroundColor: .roomeMain, tintColor: .white)
    private var viewModel: SignOutViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: SignOutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSignOutButton()
        bind()
    }
    
    func bind() {
        let signOut = signOutButton.publisher(for: .touchUpInside)
            .eraseToAnyPublisher()
        let output = viewModel.transform(SignOutViewModel.Input(tapSignOutButton: signOut))
        
        output.next
            .sink { _ in
                let next = DIContainer.shared.resolve(LoginViewController.self)
                Task { @MainActor in
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController?.dismiss(animated: false)
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                        .changeRootViewController(next, animated: true)
                }
            } receiveValue: { error in
                print("탈퇴 실패!")
                let next = DIContainer.shared.resolve(LoginViewController.self)
                Task { @MainActor in
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController?.dismiss(animated: false)
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                        .changeRootViewController(next, animated: true)
                }
            }
            .store(in: &cancellables)
        
        output.handleSignOut
            .sink {}
            .store(in: &cancellables)
    }
    
    
    private func configureSignOutButton() {
        view.addSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}