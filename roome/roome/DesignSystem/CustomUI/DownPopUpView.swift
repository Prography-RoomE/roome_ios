//
//  DownPopUpView.swift
//  roome
//
//  Created by minsong kim on 6/26/24.
//

import UIKit
import Combine

class DownPopUpView: UIView {
    private let boxView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 30
        
        return view
    }()
    
    private let takePhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진 촬영", for: .normal)
        button.titleLabel?.font = .boldTitle3
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    private let albumButton: UIButton = {
        let button = UIButton()
        button.setTitle("앨범에서 사진 선택", for: .normal)
        button.titleLabel?.font = .boldTitle3
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        
        return button
    }()
    
    private let baseImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("기본 이미지 사용", for: .normal)
        button.titleLabel?.font = .boldTitle3
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .boldTitle3
        button.setTitleColor(.roomeMain, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        configureStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func takePhotoButtonPublisher() -> AnyPublisher<Void, Never> {
        takePhotoButton.publisher(for: .touchUpInside).eraseToAnyPublisher()
    }
    
    func albumButtonPublisher() -> AnyPublisher<Void, Never> {
        albumButton.publisher(for: .touchUpInside).eraseToAnyPublisher()
    }

    func baseImageButtonPublisher() -> AnyPublisher<Void, Never> {
        baseImageButton.publisher(for: .touchUpInside).eraseToAnyPublisher()
    }
    
    func cancelButtonPublisher() -> AnyPublisher<Void, Never> {
        cancelButton.publisher(for: .touchUpInside).eraseToAnyPublisher()
    }
    
    private func configureStackView() {
        self.addSubview(boxView)
        boxView.addSubview(takePhotoButton)
        boxView.addSubview(albumButton)
        boxView.addSubview(baseImageButton)
        boxView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            boxView.widthAnchor.constraint(equalTo: self.widthAnchor),
            boxView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.4),
            boxView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            boxView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 24),
            
            takePhotoButton.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 24),
            takePhotoButton.leadingAnchor.constraint(equalTo: boxView.leadingAnchor),
            takePhotoButton.trailingAnchor.constraint(equalTo: boxView.trailingAnchor),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 48),
            
            albumButton.topAnchor.constraint(equalTo: takePhotoButton.bottomAnchor),
            albumButton.leadingAnchor.constraint(equalTo: boxView.leadingAnchor),
            albumButton.trailingAnchor.constraint(equalTo: boxView.trailingAnchor),
            albumButton.heightAnchor.constraint(equalToConstant: 48),
            
            baseImageButton.topAnchor.constraint(equalTo: albumButton.bottomAnchor),
            baseImageButton.leadingAnchor.constraint(equalTo: boxView.leadingAnchor),
            baseImageButton.trailingAnchor.constraint(equalTo: boxView.trailingAnchor),
            baseImageButton.heightAnchor.constraint(equalToConstant: 48),
            
            cancelButton.topAnchor.constraint(equalTo: baseImageButton.bottomAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: boxView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: boxView.trailingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
}
