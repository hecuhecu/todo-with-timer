import UIKit
import RealmSwift
import AVFoundation
import AudioToolbox

class TimerViewController: UIViewController {
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var startButton: UIButton!
    @IBOutlet weak private var cancelButton: UIButton!
    private var todoTimer = Timer()
    private var vibrationTimer = Timer()
    private var elapsedTime = 0
    private var alarmPlayer = AVAudioPlayer()
    private let alarmPath = Bundle.main.bundleURL.appendingPathComponent("AlarmSound.mp3")
    private let numberOfLoops = -1
    private let realm = try! Realm()
    var todo: TodoData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audiosSession = AVAudioSession.sharedInstance()
        try! audiosSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
        
        navigationItem.backButtonTitle = "戻る"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editBarButtonTapped(_:)))
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .bold)
        invalidateButton(cancelButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayTimerView()
        elapsedTime = 0
        if todo.timerValue - elapsedTime <= 0 || todo.isDone {
            invalidateButton(startButton)
        } else {
            validateButton(startButton)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        todoTimer.invalidate()
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
        if todoTimer.isValid {
            todoTimer.invalidate()
            changeToResume()
        } else {
            startTimer()
            changeToStop()
            validateButton(cancelButton)
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @IBAction private func tapCancelButton(_ sender: Any) {
        if todoTimer.isValid {
            todoTimer.invalidate()
        }
        changeToStart()
        invalidateButton(cancelButton)
        elapsedTime = 0
        displayTimerView()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func startTimer() {
        todoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.countDownTimer()
        }
    }
    
    private func countDownTimer() {
        elapsedTime += 1
        if todo.timerValue - elapsedTime <= 0 {
            todoTimer.invalidate()
            changeToStart()
            invalidateButton(startButton)
            invalidateButton(cancelButton)
            
            makeAlarm()
            displayAlert()
            
            try! realm.write() {
                todo.isDone = true
            }
            NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        }
        displayTimerView()
    }
    
    private func makeAlarm() {
        do {
            alarmPlayer = try AVAudioPlayer(contentsOf: alarmPath, fileTypeHint: nil)
            alarmPlayer.numberOfLoops = numberOfLoops
            alarmPlayer.play()
        } catch {
            print("alarm error")
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    private func displayAlert() {
        let alert = UIAlertController(title: todo.title, message: "", preferredStyle: UIAlertController.Style.alert)
        let confirmAction = UIAlertAction(title: "完了", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) -> Void in
            self.alarmPlayer.stop()
            self.vibrationTimer.invalidate()
            let audiosSession = AVAudioSession.sharedInstance()
            try! audiosSession.setActive(false)
        })
        
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func displayTimerView() {
        navigationItem.title = todo.title
        
        let hours = (todo.timerValue - elapsedTime) / 3600
        let minutes = (todo.timerValue - elapsedTime) / 60 % 60
        let seconds = (todo.timerValue - elapsedTime) % 60
        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func invalidateButton(_ button: UIButton) {
        button.isEnabled = false
        button.setTitleColor(.tertiarySystemFill, for: .normal) //tertiaryLabel
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
