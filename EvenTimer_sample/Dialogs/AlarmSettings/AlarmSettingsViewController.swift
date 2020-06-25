/// Copyright (c) 2020 JC Nolan / Lapin Publishing
///
/// EvenTimer - Sample code written in Swift 5 for IOS
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.  This software is provided
/// for evaluation purposes only and any use beyond that purpose is beyond
/// the intended scope of this agreement
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
///
/// Code Pattern for dialog taken from: https://medium.com/macoclock/how-to-create-and-use-custom-dialog-boxes-in-ios-4335be9dac34

import UIKit

class AlarmSettingsViewController: UIViewController {
  
  static let identifier = "AlarmSettingsViewController"
  static var firstShown = false
  
  var delegate: PopUpDelegate?
  var delegateView: TaskListViewController?

  let alarmBeforeOffMsg = "Before (off)"
  let alarmAfterOffMsg  = "After (off)"

  static var alarmBeforeSliderVal: Float = 0.0
  static var alarmAfterSliderVal: Float = 0.0
  
  //MARK:- outlets for the dialog view controller
  
  @IBOutlet weak var dialogBoxView: UIView!
  
  @IBOutlet weak var alarmActive: UISwitch!
  @IBOutlet weak var alarmActiveLabel: UILabel!
  @IBOutlet weak var countdownTimePicker: UIDatePicker!
  
  @IBOutlet weak var laggersLabel: UILabel!
  @IBOutlet weak var leadersLabel: UILabel!
  @IBOutlet weak var laggersSwitch: UISwitch!
  @IBOutlet weak var leadersSwitch: UISwitch!
  
  @IBOutlet weak var alarmBeforeSlider: UISlider!
  @IBOutlet weak var alarmAfterSlider: UISlider!
  @IBOutlet weak var alarmBeforeLabel: UILabel!
  @IBOutlet weak var alarmAfterLabel: UILabel!
  
  @IBOutlet weak var okayButton: UIButton!
  
  func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
  }
  
  func getHMSToPrint(seconds:Int) -> String {
    
    let (h,m,s) = secondsToHoursMinutesSeconds(seconds:seconds)
    var label = "\(s)s"
    
    if (m > 0) { label = "\(m)m \(label)"}
    if (h > 0) { label = "\(h)h \(label)"}
    
    return label
  }
  
  func getTimeForWarningInSeconds(sliderValD:Float)->Int {
    
    // Returns associated value for warning time from the discrate slider value (0-10)
    // which is then converted to a (fractional) percentage of the total alarm time
    // 0=0, 1=1/4, 2=1/5, 3=1/7, 4=1/10, 5=1/12, 6=1/20, 7=1/30, 8=1/40, 9=1/60, 10=1/80
    
    let sliderVal = floor(sliderValD)
    var warnTime = 0
    
    if sliderVal == 0 {}
    else {
      
      let pctToUse:Double = [0.0, 0.25, 0.20, 0.15, 0.10, 0.0725, 0.05, 0.033, 0.025, 0.0175, 0.0125][Int(sliderVal)] // 0, 1/4, 1/5, 1/7, 1/10, 1/12, 1/20, 1/30, 1/40, 1/60, 1/80
      warnTime = Int(floor(self.countdownTimePicker.countDownDuration*pctToUse))
    }
    return warnTime
  }
  
  @IBAction func alarmBeforeSliderChange(_ sender: UISlider) {
    
    // Handle update for warning alarm slider change
    
    var textLabel:String
    AlarmSettingsViewController.alarmBeforeSliderVal = sender.value
    let warnTime = getTimeForWarningInSeconds(sliderValD:sender.value)
    
    if warnTime == 0  { textLabel = alarmBeforeOffMsg }
    else              { textLabel = getHMSToPrint(seconds:warnTime) }
    
    alarmBeforeLabel.text = textLabel
    delegateView!.countdownWarningTimeDuration = warnTime
  }
  
  @IBAction func alarmAfterSliderChange(_ sender: UISlider) {

    // Handle update for overage alarm slider change

    var textLabel:String
    AlarmSettingsViewController.alarmAfterSliderVal = sender.value
    let warnTime = getTimeForWarningInSeconds(sliderValD:sender.value)
    
    if warnTime == 0  { textLabel = alarmAfterOffMsg }
    else              { textLabel = getHMSToPrint(seconds:warnTime) }
    
    alarmAfterLabel.text = textLabel
    delegateView!.countdownPostWarningTimeDuration = warnTime
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    // Add an overlay to the view to give focus to the dialog box
    view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
    
    // Customize the dialog box view
    dialogBoxView.layer.cornerRadius = 6.0
    dialogBoxView.layer.borderWidth = 0.0
    dialogBoxView.layer.borderColor = UIColor(named: "dialogBoxGray")?.cgColor
    
    // Customize the okay button
    okayButton.backgroundColor = UIColor(named: "primaryBackground")?.withAlphaComponent(0.85)
    okayButton.setTitleColor(UIColor.black, for: .normal)
    okayButton.layer.cornerRadius = 4.0
    okayButton.layer.borderWidth = 0.0
    okayButton.layer.borderColor = UIColor(named: "primaryBackground")?.cgColor
    
    delegateView = delegate as? TaskListViewController
    
    alarmBeforeLabel.text = alarmBeforeOffMsg
    alarmAfterLabel.text  = alarmAfterOffMsg

    if AlarmSettingsViewController.firstShown == false {
      
      // Special check, first time the dialog is shown force the alarmm active but only on the first time
      // The effect of this is to be able to turn the alarm on by just opening and closing the dialog (first time)
      
      DispatchQueue.main.async {
        self.alarmActive.setOn(true, animated: false)
        self.enableAlarm(self.countdownTimePicker)
        
        // Hack to fix issue with date picker first change message being eaten on first firing - bug in apple code
        self.countdownTimePicker.countDownDuration = self.countdownTimePicker.countDownDuration
      }
      AlarmSettingsViewController.firstShown = true
      
    } else {
      
      // Otherwise, we set the alarm to whatever the current state is and populate the dialog with current values
      
      let alarmIsActive = delegateView!.countdownTimerActive
      
      DispatchQueue.main.async {
        self.alarmActive.setOn(alarmIsActive, animated: false)
        self.activateAlarmControls(isActive: alarmIsActive)
        self.countdownTimePicker.countDownDuration = TimeInterval(self.delegateView!.countdownTimeDuration)
        
        self.alarmBeforeSlider.value = AlarmSettingsViewController.alarmBeforeSliderVal
        self.alarmAfterSlider.value  = AlarmSettingsViewController.alarmAfterSliderVal
        
        self.alarmBeforeSliderChange(self.alarmBeforeSlider)  // Updates the slider label
        self.alarmAfterSliderChange(self.alarmAfterSlider)    // Updates the slider label
        
        self.leadersSwitch.setOn(self.delegateView!.normalizeCountdownDown, animated: false)
        self.laggersSwitch.setOn(self.delegateView!.normalizeCountdownUp, animated: false)
      }
    }
    
  }
  
  // MARK: - outlet functions for the dialog view controller
  
  @IBAction func okayButtonPressed(_ sender: Any) {
    
    self.dismiss(animated: true, completion: nil)
    
    self.delegate?.handleActionAlarmSettingsEditComplete(action: true)
  }
  
  func activateAlarmControls(isActive:Bool = true) {
    
    alarmActiveLabel.text = isActive ? "Countdown Alarm (on)" : "Countdown Alarm (off)"
    
    alarmBeforeLabel.isEnabled = isActive
    alarmAfterLabel.isEnabled = isActive
    alarmBeforeSlider.isEnabled = isActive
    alarmAfterSlider.isEnabled = isActive
    
    leadersLabel.isEnabled = isActive
    laggersLabel.isEnabled = isActive
    leadersSwitch.isEnabled = isActive
    laggersSwitch.isEnabled = isActive
  }
  
  @IBAction func countdownTimeChanged(_ sender: Any) {
    
    // Handle updating display when the countdown spinner is manipulated
    
    if !alarmActive.isOn {
      alarmActive.setOn(true, animated: true)
      activateAlarmControls(isActive: true)
      delegateView!.countdownTimerActive = true
    }
    
    delegateView!.countdownTimeDuration = Int(self.countdownTimePicker.countDownDuration)
    // delegateView!.countdownTimeDuration = 20 // Hack for convenient timer testing -- uncomment this and comment line above
    
    DispatchQueue.main.async {
      self.alarmBeforeSliderChange(self.alarmBeforeSlider)
      self.alarmAfterSliderChange(self.alarmAfterSlider)
    }
  }
  
  @IBAction func enableAlarm(_ sender: Any) {
    
    // Toggle warning alarm state
    
    delegateView!.countdownTimerActive = alarmActive.isOn
    activateAlarmControls(isActive: alarmActive.isOn)
    
    if (alarmActive.isOn) {
      delegateView!.reactivateCountdownTimerForCurrentTask()
      delegateView!.countdownTimeDuration = Int(self.countdownTimePicker.countDownDuration)
    } else {
      delegateView!.resetCountdownTimer()
    }
  }
  
  @IBAction func promoteLaggers(_ sender: Any) {
    
    // Laggers switch is used to add extra time to Countdown Alarm if they are behind (to allow them to catch up)
    
    delegateView!.normalizeCountdownUp    = laggersSwitch.isOn
    if laggersSwitch.isOn { } else { }
  }
  
  @IBAction func demoteLeaders(_ sender: Any) {

    // Leaders switch is used to subtract time to Countdown Alarm if they are ahead (to allow others to catch up)

    delegateView!.normalizeCountdownDown = leadersSwitch.isOn
    if leadersSwitch.isOn { } else { }
  }
  
  // MARK: - functions for the dialog view controller
  
  static func showPopup(parentVC: UIViewController){
    
    // Create a reference for the dialogView controller
    
    if let popupViewController = UIStoryboard(name: "AlarmSettingsViewController", bundle: nil).instantiateViewController(withIdentifier: "AlarmSettingsViewController") as? AlarmSettingsViewController {
      
      popupViewController.modalPresentationStyle = .custom
      popupViewController.modalTransitionStyle = .crossDissolve
      
      // Set the delegate of the dialog box to the parent viewController
      popupViewController.delegate = parentVC as? PopUpDelegate
      
      // Present the pop up viewController from the parent viewController
      parentVC.present(popupViewController, animated: true)
    }
  }
  
}
