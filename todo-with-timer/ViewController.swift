//
//  ViewController.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/07.
//

import UIKit
import RealmSwift
import FloatingPanel
import SwiftUI

var orderSize = 0

class ViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    private var todoItems: Results<TodoData>!
    private var addBarButtonItem: UIBarButtonItem!
    private var editBarButtonItem: UIBarButtonItem!
    private let realm = try! Realm()
    private let fpc = FloatingPanelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        fpc.delegate = self
        fpc.layout = CustomFloatingPanelLayout()
        
        let add = CustomAddBarButton()
        let edit = CustomEditBarButton()
        add.addTarget(self, action: #selector(addButtonPressed(_:)), for: .touchUpInside)
        edit.addTarget(self, action: #selector(editButtonPressed(_:)), for: .touchUpInside)
        addBarButtonItem = UIBarButtonItem(customView: add)
        editBarButtonItem = UIBarButtonItem(customView: edit)
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.leftBarButtonItem = editBarButtonItem
        
        todoItems = realm.objects(TodoData.self).sorted(byKeyPath: "order")
        updateTodoOrder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView(notification:)), name: NSNotification.Name("reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeFloatingPanel(notification:)), name: NSNotification.Name("remove"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTimerSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            guard let destination = segue.destination as? TimerViewController else {
                return
            }
            
            destination.todo = todoItems[indexPath.row]
        }
    }
}

//publicのfuncが出てきたらprivate extensionに変える
// MARK: - Functions
extension ViewController {
    private func updateTodoOrder() {
        var num = 0;
        try! realm.write {
            for todo in todoItems {
                todo.order = num
                num += 1
            }
        }
        orderSize = num
    }
    
    private func toggleBarButtonItem() {
        addBarButtonItem.customView?.isHidden.toggle()
        editBarButtonItem.customView?.isHidden.toggle()
    }
    
    @objc private func addButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "InputTodo", bundle: nil)
        let contentVC = storyboard.instantiateViewController(withIdentifier: "InputTodo") as! InputTodoViewController
        fpc.set(contentViewController: contentVC)
        
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 9.0
        fpc.surfaceView.appearance = appearance
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.addPanel(toParent: self)
        fpc.move(to: .full, animated: true, completion: nil)
        
        toggleBarButtonItem()
    }
    
    @objc private func editButtonPressed(_ sender: UIButton) {
        let editButtonTitle = sender.titleLabel?.text
        if editButtonTitle == "編集" {
            tableView.setEditing(true, animated: true)
            sender.setTitle("完了", for: .normal)
        } else {
            tableView.setEditing(false, animated: true)
            sender.setTitle("編集", for: .normal)
        }
        
        addBarButtonItem.customView?.isHidden.toggle()
    }
    
    @objc private func reloadCollectionView(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    @objc private func removeFloatingPanel(notification: NSNotification) {
        fpc.removePanelFromParent(animated: true)
    }
}

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let todo = todoItems[indexPath.row]
                realm.delete(todo)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateTodoOrder()
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

// MARK: - FloatingPanelControllerDelegate
extension ViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        if fpc.state == .tip {
            NotificationCenter.default.post(name: NSNotification.Name("resign"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("remove"), object: nil)
        }
    }
    
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        NotificationCenter.default.post(name: NSNotification.Name("resign"), object: nil)
        toggleBarButtonItem()
    }
}
