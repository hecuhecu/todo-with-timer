import UIKit
import RealmSwift

class CustomTableViewCell: UITableViewCell {
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    private var todoItems: Results<TodoData>!
    private let realm = try! Realm()
    var index: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        todoItems = realm.objects(TodoData.self).sorted(byKeyPath: "order")
    }

    func setup(title: String, isDone: Bool, indexPath: IndexPath) {
        let attributeString = NSMutableAttributedString(string: title)
        let lineWeight = isDone ? 2 : 0
        let lineRange = NSMakeRange(0, attributeString.length)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: lineWeight, range: lineRange)
        titleLabel.attributedText = attributeString
        titleLabel.text = title
        titleLabel.textColor = isDone ? .gray : UIColor(displayP3Red: 0.30, green: 0.33, blue: 0.35, alpha: 1)
        checkButton.setImage(UIImage(systemName: isDone ? "checkmark.circle.fill" : "circle"), for: .normal)
        index = indexPath.row
    }
    
    @IBAction private func tapCheckButton(_ sender: Any) {
        let todo = todoItems[index]
        try! realm.write() {
            todo.isDone.toggle()
        }
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
}
