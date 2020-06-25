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

import UIKit
import AVFoundation

class TaskListViewController: UIViewController, PopUpDelegate {

  // Outlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var toolbar: UIToolbar!
  @IBOutlet weak var addTaskButton: UIBarButtonItem!
  @IBOutlet weak var countdownTimerLabel: UITextField!
  
  // MARK: - functions for the view controller
  
  var taskList: [TaskItem] = []
  var taskTimer: Timer? = nil
  var displayLink: CADisplayLink?
  var startTime: CFTimeInterval?, endTime: CFTimeInterval?
  
  var countdownTimerActive: Bool = false                // If true then countdown timer can be active (depending on task settings)
  var countdownTimeDuration: Int = 0                    // Timer value - 0 indicates no timer
  var countdownTimeRemaining: Int = 0                   // Time remaining before countown = 0
  var countdownTimeElapsed: Int = 0                     // Used only when the time is stopped and restarted on a task w/out switching
  var countdownTimeStart: Date? = nil                   // Literal time the countdown timer was started
  
  var countdownWarningTimeDuration: Int = 0             // warning alarm value - 0 indicates no timer
  var countdownPostWarningTimeDuration: Int = 0         // overtime alarm value - 0 indicates no timer
  
  var countdownWarningBellWasRung:Bool          = false // Indicates that the warning bell for timing out has been rung
  var countdownBellWasRung:Bool                 = false // Indicates that the bell for timing out has been rung
  var countdownPostWarningBellsToRing:Int       = 0     // Decreasing counter of number of times to ring overage bell
  var countdownPostWarningBellWasRungCount:Int  = 0     // Indicates number times the warning bell for pose timing out has been rung
  
  var normalizeCountdownDown = false                    // If true, will subtract from inititally allocated time if user has most time used
  var normalizeCountdownUp   = false                    // If true, will add to inititally allocated time if user does not have most time used
  
  var currentActiveTaskNum = -1                         // Used by countdown timer to track if a new task is started or same one is restarted
  var prevActiveTaskNum = -1                            // Used by doubletap handler to allow for restarting counters on double-tap
  var prevCountdownTimeElapsed = -1                     // Used by doubletap handler to restart a timer when tapping on non-active row
  
  // variables used to track double tap
  
  var lastTableViewTapTime: TimeInterval = Date().timeIntervalSince1970
  var lastTableViewTapIndexPath: IndexPath? = nil
  var lastTableViewTapStartedTimer: Bool = false
  var lastTableViewTapTimersWereActive: Bool = false
  
  var selectedRowHighlightColor: UIColor = TaskColor.white.value // Placeholder, mostly.  Changing will cause selected row to highlight. White means no highlighting
  
  override func viewDidLoad() {
    
    super.viewDidLoad()

    // Install gesture recognizer to handle double-tap action
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
    view.addGestureRecognizer(tap)
    
    // Other configuration
    
    selectedRowHighlightColor = TaskColor.grey08.value // Changing will cause selected row to highlight. Could possibly be made into app setting
    countdownTimerLabel.text = ""
  }
  
  @objc func doubleTapped() {
    
    // Handler for doubleTap.  Allows access to edit task (if tap is on a task) or add new task (if not on a task)
    // However, doubleTaps are challenging as you still get a single-tap event on the table view, which must be sorted if need be
    
    func restoreTimerStatePriorToDoubleTap(currentActiveTaskNum:Int, prevActiveTaskNum:Int, lastTableViewTapStartedTimer:Bool) {
      
      // The single tap accompanying the double tap either stopped or started something out of turn
      // Restore the running state prior to the single tap
      
      if (lastTableViewTapStartedTimer) {
        
        // Something was started out of turn - cancel current timers
        
        cancelTimers()
        
        if lastTableViewTapTimersWereActive {
          
          // Restart timer for prevActiveTaskNum
          
          countdownTimeElapsed = prevCountdownTimeElapsed
          self.currentActiveTaskNum = prevActiveTaskNum
          reactivateCountdownTimerForCurrentTask()
          startTaskTimer()
        }
        
      } else {
        
        // Something was stopped out of turn - restart it
        
        self.currentActiveTaskNum = prevActiveTaskNum
        reactivateCountdownTimerForCurrentTask()
        startTaskTimer()
      }
      
      // Address possible errors in row highlighting by reloading and rehighlighing table
      
      tableView.reloadData()
      highlightTableRow(rowIndex:self.currentActiveTaskNum, forceOne:true)
    }
    
    // Ok, running state is now corrected - handle the actual double-tap event
    
    // Determine if the double tap was on a table row or off the table
    
    let now: TimeInterval = Date().timeIntervalSince1970
    let tableWasDoubleTapped = (now - lastTableViewTapTime < 0.3) && lastTableViewTapIndexPath != nil
    
    if tableWasDoubleTapped {
      
      // Table was doubleTapped, present edit dialog for the doubleTapped Task item
      
      restoreTimerStatePriorToDoubleTap(currentActiveTaskNum: currentActiveTaskNum,
                                        prevActiveTaskNum: prevActiveTaskNum,
                                        lastTableViewTapStartedTimer: lastTableViewTapStartedTimer)
      presentEditTaskItem(lastTableViewTapIndexPath!.row)
      
    } else {
      
      // DoubleTap was off the table, present Add Item dialog to create new Task
      
      presentAddTaskItem()
    }
  }

// MARK: - Dialog Actions and Handlers
  
  @IBAction func presentAlarmSettings(_ sender: UIBarButtonItem) {
    AlarmSettingsViewController.showPopup(parentVC: self)
  }
  
  func presentEditTaskItem(_ itemNum: Int) {
    EditTaskItemViewController.showPopup(parentVC: self, taskItem: taskList[itemNum])
  }
  
  func presentAddTaskItem() {
    AddTaskItemViewController.showPopup(parentVC: self)
  }
  
  @IBAction func presentAddItem(_ sender: UIBarButtonItem) {
    // Just a hook for the "+" button on the Toolbar
    presentAddTaskItem()
  }
  
  func handleActionTaskItemEditComplete(action: Bool) {
    
    // Handler for completed Task Edit dialog
    
    if (action) {
      
      tableView.reloadData()
      highlightTableRow(rowIndex:self.currentActiveTaskNum)
      
      if let taskNum = lastTableViewTapIndexPath?.row {
        
        if taskNum == self.currentActiveTaskNum && countdownTimeDuration > 0 {
          
          if self.taskList[taskNum].timeOnly {
            
            self.hideCountdownTimer()
            
          } else if self.taskList[taskNum].isActive && !self.taskList[taskNum].timeOnly && countdownTimeRemaining <= 0 {
            
            // Countdown timer was set to "on" while it was running, show it
            
            self.showCountdownTimer()
            activateCountdownForTask(selectedTaskNum: taskNum)
          }
        }
      }
      lastTableViewTapIndexPath = nil
    }
  }
  
  func handleActionAlarmSettingsEditComplete(action: Bool) {
    
    // Handler for completed Alarm Settings dialog
    
    if !self.countdownTimerActive {
      
      self.hideCountdownTimer()
      
    } else {
      
      if let taskNum = lastTableViewTapIndexPath?.row,
        self.taskList[taskNum].isActive && !self.taskList[taskNum].timeOnly && countdownTimeRemaining <= 0 {
        
        // Countdown timer was set to "on" while it was running, show it
        
        self.showCountdownTimer()
        activateCountdownForTask(selectedTaskNum: taskNum)
      }
    }
  }
  
  func handleActionTaskItemAddComplete(action: Bool, task:TaskItem) {
    
    // Handler for completed Add Task dialog
    
    if (action) {
      
      DispatchQueue.main.async {
        
        self.taskList.append(task)
        
        let indexPath = IndexPath(row: self.taskList.count - 1, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .top)
        self.tableView.endUpdates()
      }
    }
  }
  
}
