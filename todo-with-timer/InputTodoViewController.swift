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

        NotificationCenter.default.addObserver(self, selector: #selector(resignTextField(notification:)), name: NSNotification.Name("resign"), object: nil)
    }
    
    @IBAction private func tapAddButton(_ sender: UIButton) {
        if textField.text == "" {
            NotificationCenter.default.post(name: NSNotification.Name("remove"), object: nil)
            return
        }
        
        let hours = timePicker.selectedRow(inComponent: 0)
        let minutes = timePicker.selectedRow(inComponent: 1)
        let seconds = timePicker.selectedRow(inComponent: 2)
        
        let todo = TodoData()
        todo.title = textField.text!
        todo.timerValue = hours * 3600 + minutes * 60 + seconds
        todo.order = orderSize
        orderSize += 1
        print(todo)
        
        try! realm.write {
            realm.add(todo)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        textField.text = ""
    }
    
}

// MARK: - Functions
extension InputTodoViewController {
    @objc private func resignTextField(notification: NSNotification) {
        textField.resignFirstResponder()
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
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1, 2:
            return 60
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate
extension InputTodoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row.description
    }
}
