//
//  StrengthViewController.swift
//  roome
//
//  Created by minsong kim on 5/23/24.
//

import UIKit
import Combine
import FirebaseAnalytics

class StrengthViewController: UIViewController, ToastAlertable {
    private let titleLabel = TitleLabel(text: "방탈출 할 때,\n본인의 강점이 무엇이라고\n생각하시나요?")
    private let descriptionLabel = DescriptionLabel(text: "최대 2개까지 선택할 수 있어요")
    lazy var profileCount = ProfileStateLineView(pageNumber: 4, frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.9 - 10, height: view.frame.height))
    var nextButton = NextButton()
    private let backButton = BackButton()
    private lazy var flowLayout = self.createFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
    
    var viewModel: StrengthViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: StrengthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: "cell")
        configureUI()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logEvent(Tracking.Profile.strengthView, parameters: nil)
    }
    
    func bind() {
        nextButton.publisher(for: .touchUpInside)
            .map {
                Analytics.logEvent(Tracking.Profile.strengthNextButton, parameters: nil)
            }
            .sink { [weak self] in
                self?.nextButton.loadingButton()
                self?.viewModel.input.tapNextButton.send()
            }
            .store(in: &cancellables)
        
        backButton.publisher(for: .touchUpInside)
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: false)
            }.store(in: &cancellables)
        
        viewModel.output.handleCellSelect
            .sink { [weak self] (result, item) in
                if result == false {
                    self?.collectionView.deselectItem(at: item, animated: false)
                    self?.showToast(count: 2)
                }
            }.store(in: &cancellables)
        
        viewModel.output.handleCanGoNext
            .sink { [weak self] result in
                if result {
                    self?.nextButton.isEnabled = true
                } else {
                    self?.nextButton.isEnabled = false
                }
            }.store(in: &cancellables)
        
        viewModel.output.handleNextButton
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    let nextViewController = DIContainer.shared.resolve(ImportantFactorViewController.self)
                    self?.navigationController?.pushViewController(nextViewController, animated: false)
                    self?.nextButton.stopLoading()
                case .failure(let error):
                    //TODO: - 토스트로 에러 띄우기
                    self?.nextButton.stopLoading()
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func configureUI() {
        configureStackView()
        setUpCollectionView()
        configureNextButton()
    }
    
    func setUpCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
        
    }
    
    
    func configureStackView() {
        profileCount.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileCount)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            profileCount.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileCount.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileCount.heightAnchor.constraint(equalToConstant: 15),
            profileCount.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            backButton.topAnchor.constraint(equalTo: profileCount.bottomAnchor, constant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
    private func configureNextButton() {
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9)
        ])
    }
    
    func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: (view.frame.width / 2) - 29, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 24, bottom: 50, right: 24)
        
        return layout
    }

}

extension StrengthViewController: UICollectionViewDataSource, UICollectionViewDelegate  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        UserContainer.shared.defaultProfile?.data.strengths.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ButtonCell
        else {
            return UICollectionViewCell()
        }
        guard let strength = UserContainer.shared.defaultProfile?.data.strengths[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        cell.changeTitle(strength.title)
        
        if let userSelect = UserContainer.shared.profile?.data.userStrengths.map({ $0.id }) {
            if userSelect.contains(strength.id) {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                viewModel.input.selectCell.send(indexPath)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.selectCell.send(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.input.deselectCell.send(indexPath)
    }
}
