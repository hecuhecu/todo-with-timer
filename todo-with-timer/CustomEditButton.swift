import UIKit

class CustomEditButton: UIButton {
    private let titleColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        } else {
            return UIColor(displayP3Red: 0.30, green: 0.33, blue: 0.35, alpha: 1)
        }
    }
    
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
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            
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
        setTitle("編集", for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.gray.cgColor
    }
}
