//
//  EditTodoViewController.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/22.
//

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
        timePicker.selectRow(minutes, inComponent: 1, animated: true)
        timePicker.selectRow(seconds, inComponent: 2, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let hours = timePicker.selectedRow(inComponent: 0)
        let minutes = timePicker.selectedRow(inComponent: 1)
        let seconds = timePicker.selectedRow(inComponent: 2)
        
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

extension EditTodoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row.description
    }
}
