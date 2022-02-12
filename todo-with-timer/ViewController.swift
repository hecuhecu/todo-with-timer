//
//  ViewController.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/07.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var todoItems: Results<TodoData>!
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        todoItems = realm.objects(TodoData.self).sorted(byKeyPath: "order")
        let todo = TodoData()
        todo.title = "Swift"
        todo.isDone = false
        todo.timerValue = 0
        todo.order = 0
        try! realm.write {
            realm.add(todo)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let todo = todoItems[indexPath.row]
        if #available(iOS 14.0, *) {
            // iOS14以降の推奨
            var content = cell.defaultContentConfiguration()
            content.text = todo.title
            cell.contentConfiguration = content
        } else {
            // iOS13以前
            cell.textLabel?.text = todo.title
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let todo = todoItems[indexPath.row]
                realm.delete(todo)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            for index in todoItems {
                print("\(index)だよ")
            }
        }
    }
}
