//
//  InputTodoViewController.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/07.
//

import UIKit
import RealmSwift

class InputTodoViewController: UIViewController {
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        textField.becomeFirstResponder()

        NotificationCenter.default.addObserver(self, selector: #selector(resignTextField(notification:)), name: NSNotification.Name("resign"), object: nil)
    }
    
    @IBAction private func tapAddButton(_ sender: UIButton) {
        if textField.text == "" {
            //NotificationCenter.default.post(name: NSNotification.Name("resign"), object: nil)　なんか分からんけどこれ無くてもtextFieldも同じ速さで消えてくれる
            NotificationCenter.default.post(name: NSNotification.Name("remove"), object: nil)
            return
        }
        
        let todo = TodoData()
        todo.title = textField.text!
        todo.order = orderSize
        orderSize += 1
        
        try! realm.write {
            realm.add(todo)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        textField.text = ""
    }
    
}

// MARK: - Functions
extension InputTodoViewController {
    @objc func resignTextField(notification: NSNotification) {
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
