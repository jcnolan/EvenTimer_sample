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

class EditTaskItemViewController: UIViewController {
  
  static let identifier = "EditTaskItemViewController"
  var delegate: PopUpDelegate?
  
  var taskItem: TaskItem? = nil
  
  //MARK: - outlets for the view controller
  
  @IBOutlet weak var dialogBoxView: UIView!
  @IBOutlet weak var okayButton: UIButton!
  @IBOutlet weak var taskName: UITextField!
  
  @IBOutlet weak var alarmIsOffSwitch: UISwitch!
  @IBOutlet weak var accumulatedTime: UIDatePicker!
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    // Adding an overlay to the view to give focus to the dialog box
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
    
    if let taskItem = taskItem {
      self.taskName.text                      = taskItem.name
      self.accumulatedTime.countDownDuration  = TimeInterval(taskItem.secondsElapsed)
      if (!taskItem.timeOnly) {self.alarmIsOffSwitch.setOn(false, animated:false)}
    }
  }
  
  // MARK:- outlet functions for the dialog view controller
  
  @IBAction func okayButtonPressed(_ sender: Any) {
    
    // Dismiss dialog and install changed values back into the parent task
    
    self.dismiss(animated: true, completion: nil)
    
    if taskItem != nil {
      
      taskItem!.name = self.taskName.text!
      taskItem!.timeOnly = self.alarmIsOffSwitch.isOn
      
      if abs(self.accumulatedTime.countDownDuration - taskItem!.secondsElapsed) > 60.0 {
        
        taskItem!.secondsElapsed = self.accumulatedTime.countDownDuration
      }
      
      self.delegate?.handleActionTaskItemEditComplete(action: true)
    }
  }
    
  @IBAction func disableAlarm(_ sender: Any) {
    
    // noop - value is processed on close of dialog - function left in place for clarity / expansion
        
    if alarmIsOffSwitch.isOn { } else { }
  }
  
  //MARK:- functions for the dialog view controller
  
  static func showPopup(parentVC: UIViewController, taskItem:TaskItem) {
    
    // Create a reference for the dialogView controller
    
    if let popupViewController = UIStoryboard(name: "EditTaskItemViewController", bundle: nil).instantiateViewController(withIdentifier: "EditTaskItemViewController") as? EditTaskItemViewController {
      
      popupViewController.modalPresentationStyle = .custom
      popupViewController.modalTransitionStyle = .crossDissolve
      
      // Set the delegate of the dialog box to the parent viewController
      popupViewController.delegate = parentVC as? PopUpDelegate
      popupViewController.taskItem = taskItem
      
      // Present the pop up viewController from the parent viewController
      parentVC.present(popupViewController, animated: true)
    }
  }
  
}
