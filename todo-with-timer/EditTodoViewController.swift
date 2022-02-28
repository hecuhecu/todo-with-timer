import UIKit
import RealmSwift

class EditTodoViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var timePicker: UIPickerView!
    private let realm = try! Realm()
    var todo: TodoData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        textField.text = todo.title
        
        timePicker.dataSource = self
        timePicker.delegate = self
        let hours = todo.timerValue / 3600
        let minutes = todo.timerValue / 60 % 60
        let seconds = todo.timerValue % 60
        timePicker.selectRow(hours, inComponent: 0, animated: true)
        timePicker.selectRow(minutes, inComponent: 2, animated: true)
        timePicker.selectRow(seconds, inComponent: 4, animated: true)
        
        let hour = UILabel()
        hour.text = "時間"
        let min = UILabel()
        min.text = "分"
        let sec = UILabel()
        sec.text = "秒"
        timePicker.setPickerLabels(labels: [1: hour, 3: min, 5: sec])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let hours = timePicker.selectedRow(inComponent: 0)
        let minutes = timePicker.selectedRow(inComponent: 2)
        let seconds = timePicker.selectedRow(inComponent: 4)
        
        try! realm.write() {
            todo.timerValue = hours * 3600 + minutes * 60 + seconds
        }
    }
}

extension EditTodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            return true
        }
        
        try! realm.write() {
            todo.title = textField.text!
        }
        textField.resignFirstResponder()
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        
        return true
    }
}

extension EditTodoViewController: UIPickerViewDataSource {
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

extension EditTodoViewController: UIPickerViewDelegate {
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
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (UIScreen.main.bounds.size.width - 10) / 6
    }
}
