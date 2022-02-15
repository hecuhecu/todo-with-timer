//
//  CustomButton.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/15.
//

import UIKit

class CustomAddBarButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        setTitle("+", for: .normal)
        setTitleColor(.systemOrange, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.gray.cgColor
    }
}
