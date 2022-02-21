import RealmSwift

class TodoData: Object {
    @objc dynamic var title = ""
    @objc dynamic var isDone = false
    @objc dynamic var timerValue = 0
    @objc dynamic var order = 0
}
