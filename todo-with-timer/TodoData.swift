//
//  TodoData.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/12.
//

import RealmSwift

class TodoData: Object {
    @objc dynamic var title = ""
    @objc dynamic var isDone = false
    @objc dynamic var timerValue = 0
    @objc dynamic var order = 0
}
