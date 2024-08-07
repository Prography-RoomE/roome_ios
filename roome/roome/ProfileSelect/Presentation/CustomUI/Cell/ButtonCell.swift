//
//  ButtonCell.swift
//  roome
//
//  Created by minsong kim on 5/23/24.
//

import UIKit

class ButtonCell: UICollectionViewCell {
    var isChecked: Bool {
        didSet {
            if isChecked {
                changeLabelColor(title: .disable, description: .disable)
            } else {
                changeLabelColor(title: .label, description: .gray)
            }
        }
    }
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = 4
        
        return stack
    }()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        self.isChecked = false
        super.init(frame: frame)
        
        contentView.layer.borderColor = UIColor.disableTint.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        self.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.isHighlighted = false
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.layer.borderColor = UIColor.roomeMain.cgColor
                contentView.layer.borderWidth = 2
            } else {
                contentView.layer.borderColor = UIColor.disableTint.cgColor
                contentView.layer.borderWidth = 1
            }
        }
    }
    
    func changeTitle(_ text: String?) {
        titleLabel.text = text
        titleLabel.font = .boldTitle3
    }
    
    func addDescription(_ text: String?) {
        descriptionLabel.text = text
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .regularBody2
    }
    
    func changeLabelColor(title: UIColor, description: UIColor) {
        titleLabel.textColor = title
        descriptionLabel.textColor = description
    }
}
