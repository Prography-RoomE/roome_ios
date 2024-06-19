//
//  MyProfileViewController.swift
//  roome
//
//  Created by minsong kim on 6/18/24.
//

import UIKit
import Combine

class MyProfileViewController: UIViewController {
    private let titleLabel = TitleLabel(text: "프로필")
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTitleLabel()
        setUpCollectionView()
    }
    
    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: "UserCell")
        collectionView.register(MyProfileCell.self, forCellWithReuseIdentifier: "MyProfileCell")
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension MyProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 1 : MyProfileDTO.category.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as? UserCell, 
                let myProfileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyProfileCell", for: indexPath) as? MyProfileCell,
                let profile = UserContainer.shared.profile else {
            return UICollectionViewCell()
        }
        
        if indexPath.section == 0 {
            userCell.cardButtonPublisher()
                .sink { [weak self] _ in
                    print("card Button Tapped")
                    let popUpView = DIContainer.shared.resolve(ProfileViewController.self)
                    popUpView.updateUI()
                    popUpView.modalPresentationStyle = .fullScreen
                    
                    self?.present(popUpView, animated: true)
                }
                .store(in: &cancellables)
            
            userCell.shareButtonPublisher()
                .sink { _ in
                    //카카오 공유하기 뷰모델로 input 연결
                }
                .store(in: &cancellables)
            
            return userCell
        } else {
            myProfileCell.updateOption(text: MyProfileDTO.category[indexPath.row])
            
            if indexPath.row == 0 || indexPath.row == 1 {
                myProfileCell.updateSelects(profile.bundle[indexPath.row], isBig: true)
            } else {
                myProfileCell.updateSelects(profile.bundle[indexPath.row], isBig: false)
            }
            
            return myProfileCell
        }
    }
}

extension MyProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        } else {
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = view.frame.width * 0.25
        var width = view.frame.width * 0.43
        
        if indexPath.section == 0 {
            height = view.frame.width * 0.4
            width = view.frame.width * 0.9
        } else if indexPath.row == 0 || indexPath.row == 1 {
            height = view.frame.width * 0.2
        }
        
        return CGSize(width: width, height: height)
    }
}
