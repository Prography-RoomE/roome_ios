//
//  PaddingLabel.swift
//  roome
//
//  Created by minsong kim on 5/19/24.
//

import UIKit

class PaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 12.0)

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }
}
