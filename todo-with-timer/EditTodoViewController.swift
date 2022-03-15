import UIKit
import RealmSwift
import GoogleMobileAds

class EditTodoViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak private var bannerView: GADBannerView!
    private let realm = try! Realm()
    var todo: TodoData!
    private let timePickerColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        if traitCollection.userInterfaceStyle == .dark {
            return .white
        } else {
            return .black
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = adUnitID(key: "banner") {
            bannerView.adUnitID = id
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
        
        textField.delegate = self
        textField.text = todo.title
        textField.backgroundColor = .white
        textField.textColor = .black
        
        timePicker.dataSource = self
        timePicker.delegate = self
        setupTimePicker()
        setupTimePickerLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let hours = timePicker.selectedRow(inComponent: 0)
        let minutes = timePicker.selectedRow(inComponent: 2)
        let seconds = timePicker.selectedRow(inComponent: 4)
        try! realm.write() {
            todo.timerValue = hours * 3600 + minutes * 60 + seconds
        }
    }
}

// MARK: - Functions
extension EditTodoViewController {
    private func adUnitID(key: String) -> String? {
        guard let adUnitIDs = Bundle.main.object(forInfoDictionaryKey: "AdUnitIDs") as? [String: String] else {
            return nil
        }
        return adUnitIDs[key]
    }
    
    private func setupTimePicker() {
        let hours = todo.timerValue / 3600
        let minutes = todo.timerValue / 60 % 60
        let seconds = todo.timerValue % 60
        timePicker.selectRow(hours, inComponent: 0, animated: true)
        timePicker.selectRow(minutes, inComponent: 2, animated: true)
        timePicker.selectRow(seconds, inComponent: 4, animated: true)
    }
    
    private func setupTimePickerLabel() {
        let hour = UILabel()
        hour.text = "時間"
        let min = UILabel()
        min.text = "分"
        let sec = UILabel()
        sec.text = "秒"
        timePicker.setPickerLabels(labels: [1: hour, 3: min, 5: sec])
        timePicker.setValue(timePickerColor, forKey: "textColor")
    }
}


// MARK: - UITextFieldDelegate
extension EditTodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            return true
        }
        
        try! realm.write() {
            todo.title = textField.text!
        }
        textField.resignFirstResponder()
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        
        return true
    }
}

// MARK: - UIPickerViewDatasource
extension EditTodoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 6
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1, 3, 5:
            return 1
        case 2, 4:
            return 60
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate
extension EditTodoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0, 2, 4:
            return row.description
        case 1, 3, 5:
            return ""
        default:
            return "error"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (UIScreen.main.bounds.size.width - 10) / 6
    }
}
