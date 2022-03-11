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
    var timerIsBackground = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
                  return
              }
        sceneDelegate.delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        
        let audiosSession = AVAudioSession.sharedInstance()
        try! audiosSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
        
        navigationItem.backButtonTitle = "戻る"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editBarButtonTapped(_:)))
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 54, weight: .bold)
        setupButton(startButton)
        setupButton(cancelButton)
        invalidateButton(cancelButton)
        
        alertHowToUse()
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
            timerIsBackground = false
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
        timerIsBackground = false
        changeToStart()
        invalidateButton(cancelButton)
        elapsedTime = 0
        displayTimerView()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 18.0
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 3
        button.layer.shadowColor = UIColor.gray.cgColor
    }
    
    private func startTimer() {
        todoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.countDownTimer()
        }
    }
    
    private func countDownTimer() {
        elapsedTime += 1
        if todo.timerValue - elapsedTime <= 0 {
            finishTimer()
            makeAlarm()
            displayAlert()
        }
        displayTimerView()
    }
    
    private func finishTimer() {
        todoTimer.invalidate()
        changeToStart()
        invalidateButton(startButton)
        invalidateButton(cancelButton)
        try! realm.write() {
            todo.isDone = true
        }
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    private func alertHowToUse() {
        UserDefaults.standard.set(false, forKey: "visit")
        let visit = UserDefaults.standard.bool(forKey: "visit")

        if !visit {
            UserDefaults.standard.set(true, forKey: "visit")
            let alert = UIAlertController(title: "ご注意", message: "バックグラウンドでアラームを鳴らすには通知をオンにし、マナーモードを解除(本体左側にあるスイッチをディスプレイ側に切り替え)していただく必要があります。", preferredStyle: UIAlertController.Style.alert)
            let confirmAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        }
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
        button.alpha = 0.2
    }
    
    private func validateButton(_ button: UIButton) {
        button.isEnabled = true
        button.alpha = 1.0
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

//MARK: - backgroundTimerDelegate
extension TimerViewController: backgroundTimerDelegate {
    func setLocalNotifications() {
        if todoTimer.isValid {
            let content = UNMutableNotificationContent()
            content.body = todo.title
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "AlarmSound.mp3"))
            let timeInterval = Double(todo.timerValue - elapsedTime)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: "Time Interval", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func setElapsedBackgroundTime(_ elapsedTime: Int) {
        self.elapsedTime += elapsedTime
        if todo.timerValue - self.elapsedTime <= 0 {
            self.elapsedTime = todo.timerValue
            displayTimerView()
            finishTimer()
        } else {
            displayTimerView()
            startTimer()
        }
    }
    
    func deleteTimer() {
        if todoTimer.isValid {
            todoTimer.invalidate()
        }
    }
    
    func checkIsBackground() {
        if todoTimer.isValid {
            timerIsBackground = true
        }
    }
}
