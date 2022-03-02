import UIKit

class CustomAddButton: UIButton {
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
        let screen = UIScreen.main.bounds.size
        frame = CGRect(x: screen.width - 70, y: screen.height - 70, width: 50, height: 50)
        setTitle("＋", for: .normal)
        setTitleColor(UIColor(displayP3Red: 0.91, green: 0.84, blue: 0.45, alpha: 1), for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 34, weight: .semibold)
        backgroundColor = .gray
        layer.cornerRadius = 25.0
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.gray.cgColor
    }
}
