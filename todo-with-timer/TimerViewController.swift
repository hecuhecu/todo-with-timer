import UIKit
import RealmSwift

class TimerViewController: UIViewController {
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var startButton: UIButton!
    @IBOutlet weak private var cancelButton: UIButton!
    private let realm = try! Realm()
    private var timer = Timer()
    private var elapsedTime = 0
    var todo: TodoData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = todo.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editBarButtonTapped(_:)))        
        
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .bold)
        displayTime()
        invalidateButton(cancelButton)
        if todo.timerValue - elapsedTime <= 0 || todo.isDone {
            invalidateButton(startButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = todo.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if timer.isValid {
            timer.invalidate()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditSegue" {
            guard let destination = segue.destination as? EditTodoViewController else {
                return
            }
            
            destination.todo = todo
        }
    }
}

// MARK: - Functions
extension TimerViewController {
    @objc private func editBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showEditSegue", sender: nil)
    }
    
    @IBAction private func tapStartButton(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
            changeToResume()
        } else {
            startTimer()
            changeToStop()
            validateButton(cancelButton)
        }
    }
    
    @IBAction private func tapCancelButton(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
        }
        changeToStart()
        invalidateButton(cancelButton)
        elapsedTime = 0
        displayTime()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.countDownTimer()
        }
    }
    
    private func countDownTimer() {
        elapsedTime += 1
        if todo.timerValue - elapsedTime <= 0 {
            timer.invalidate()
            changeToStart()
            invalidateButton(startButton)
            invalidateButton(cancelButton)
            
            try! realm.write() {
                todo.isDone = true
            }
            NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        }
        displayTime()
    }
    
    private func displayTime() {
        let hours = (todo.timerValue - elapsedTime) / 3600
        let minutes = (todo.timerValue - elapsedTime) / 60 % 60
        let seconds = (todo.timerValue - elapsedTime) % 60
        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func invalidateButton(_ button: UIButton) {
        button.isEnabled = false
        button.setTitleColor(.systemGray, for: .normal)
    }
    
    private func validateButton(_ button: UIButton) {
        button.isEnabled = true
        button.setTitleColor(UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0), for: .normal)
    }
    
    private func changeToStart() {
        startButton.setTitle("開始", for: .normal)
    }
    
    private func changeToStop() {
        startButton.setTitle("一時停止", for: .normal)
    }
    
    private func changeToResume() {
        startButton.setTitle("再開", for: .normal)
    }
}
