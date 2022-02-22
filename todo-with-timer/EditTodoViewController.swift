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
    private let realm = try! Realm()
    var todo: TodoData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        textField.text = todo.title
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
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        
        return true
    }
}
