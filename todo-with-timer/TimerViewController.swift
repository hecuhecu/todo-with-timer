//
//  TimerViewController.swift
//  todo-with-timer
//
//  Created by 河村宇記 on 2022/02/12.
//

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
        
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .bold)
        displayTime()
        invalidateButton(cancelButton)
        if todo.timerValue - elapsedTime <= 0 {
            invalidateButton(startButton)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if timer.isValid {
            timer.invalidate()
        }
    }
}

// MARK: - Functions
extension TimerViewController {
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
