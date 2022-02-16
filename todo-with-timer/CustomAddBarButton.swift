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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchStartAnimation()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchEndAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEndAnimation()
    }
    
    private func touchStartAnimation() {
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
        },
                       completion: nil)
    }
    
    private func touchEndAnimation() {
        UIView.animate(withDuration: 0.1,
                       delay:0.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        },
                       completion: nil)
    }
    
    private func setUp() {
        //frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        setTitle("+", for: .normal)
        setTitleColor(.systemOrange, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.gray.cgColor
    }
}
