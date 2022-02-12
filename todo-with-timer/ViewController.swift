//
//  ViewController.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/07.
//

import UIKit
import RealmSwift

var orderSize = 0

class ViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    private var todoItems: Results<TodoData>!
    private var realm = try! Realm()
    private var addBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_ :)))
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        todoItems = realm.objects(TodoData.self).sorted(byKeyPath: "order")
        updateOrder()
        let todo = TodoData()
        todo.title = "Swift"
        todo.isDone = false
        todo.timerValue = 0
        todo.order = orderSize
        try! realm.write {
            realm.add(todo)
        }
    }
    
    private func updateOrder() {
        var num = 0;
        try! realm.write {
            for todo in todoItems {
                todo.order = num
                num += 1
            }
        }
        orderSize = num
        print("orderSize: \(orderSize)")
    }
    
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        tableView.isEditing = editing
        addBarButtonItem.isEnabled.toggle()
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
            updateOrder()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let sourceObject = todoItems[sourceIndexPath.row]
            let destinationObject = todoItems[destinationIndexPath.row]

            let destinationObjectOrder = destinationObject.order

            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = todoItems[index]
                    object.order -= 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let object = todoItems[index]
                    object.order += 1
                }
            }
            sourceObject.order = destinationObjectOrder
        }
    }
}
