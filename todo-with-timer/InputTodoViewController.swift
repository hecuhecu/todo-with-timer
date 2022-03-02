import UIKit
import RealmSwift

class InputTodoViewController: UIViewController {
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var addButton: UIButton!
    @IBOutlet weak private var timePicker: UIPickerView!
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
        textField.delegate = self
        timePicker.delegate = self
        timePicker.dataSource = self
        
        setupTimePickerLabel()
        addButton.layer.cornerRadius = 6.0

        NotificationCenter.default.addObserver(self, selector: #selector(resignTextField(notification:)), name: NSNotification.Name("resign"), object: nil)
    }
    
    @IBAction func isEditingTextField(_ sender: Any) {
        if textField.text == "" {
            addButton.setTitle("閉じる", for: .normal)
        } else {
            addButton.setTitle("追加", for: .normal)
        }
    }
    
    @IBAction private func tapAddButton(_ sender: UIButton) {
        if textField.text == "" {
            NotificationCenter.default.post(name: NSNotification.Name("remove"), object: nil)
            return
        }
        
        let hours = timePicker.selectedRow(inComponent: 0)
        let minutes = timePicker.selectedRow(inComponent: 2)
        let seconds = timePicker.selectedRow(inComponent: 4)
        
        let todo = TodoData()
        todo.title = textField.text!
        todo.timerValue = hours * 3600 + minutes * 60 + seconds
        todo.order = orderSize
        orderSize += 1
        
        try! realm.write {
            realm.add(todo)
        }
        
        textField.text = ""
        addButton.setTitle("閉じる", for: .normal)
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
}

// MARK: - Functions
extension InputTodoViewController {
    @objc private func resignTextField(notification: NSNotification) {
        textField.resignFirstResponder()
    }
    
    private func setupTimePickerLabel() {
        let hour = UILabel()
        hour.text = "時間"
        let min = UILabel()
        min.text = "分"
        let sec = UILabel()
        sec.text = "秒"
        timePicker.setPickerLabels(labels: [1: hour, 3: min, 5: sec])
        timePicker.setValue(UIColor.systemGray5, forKey: "textColor")
    }
}

// MARK: - UITextFiedlDelegate
extension InputTodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tapAddButton(addButton)
        return true
    }
}

// MARK: - UIPickerViewDataSource
extension InputTodoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 6
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1, 3, 5:
            return 1
        case 2, 4:
            return 60
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate
extension InputTodoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {        
        switch component {
        case 0, 2, 4:
            return row.description
        case 1, 3, 5:
            return ""
        default:
            return "error"
        }
    }
}

// MARK: - UIPickerView
extension UIPickerView {
    func setPickerLabels(labels: [Int:UILabel]) {
        let fontSize: CGFloat = 20
        let labelWidth: CGFloat = frame.size.width / CGFloat(numberOfComponents)
        let y: CGFloat = (frame.size.height / 2) - (fontSize / 2)
        
        for i in 0..<numberOfComponents {
            guard let label = labels[i] else { continue }
            label.autoresizingMask = [
                .flexibleTopMargin,
                .flexibleLeftMargin,
                .flexibleRightMargin,
                .flexibleBottomMargin,
                .flexibleWidth,
                .flexibleHeight
            ]
            label.frame = CGRect(x: labelWidth * CGFloat(i), y: y, width: labelWidth, height: fontSize)
            label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
            label.textColor = UIColor.systemGray5
            label.backgroundColor = .clear
            label.textAlignment = NSTextAlignment.center
            self.addSubview(label)
        }
    }
}
