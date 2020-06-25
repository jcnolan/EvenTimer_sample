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

import Foundation
import UIKit

extension TaskListViewController {
  
  // MARK: - Countdown Timer / Accumulated Time functions
  
  func reactivateCountdownTimerForCurrentTask() {
    // Used by popup to restart timer when countdown alarm has been activated from having been off or time has been changed
    activateCountdownForTask(selectedTaskNum: currentActiveTaskNum, keepPrevTimeElapsed: true)
  }
  
  func getMinMaxMyDuration(currentTask:Int)->(Int,Int,Int) {
    
    // Searches all rows in table and returns min, max and current time durtions
    
    guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else {
      return (-1,-1,-1)
    }
    
    var min:Double = -1
    var max:Double = -1
    var my:Double = -1
    
    for indexPath in visibleRowsIndexPaths {
      
      if let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
        
        let currentRowNum:Int = indexPath.last!
        
        if let task = cell.task {
          
          let secondsElapsed:Double = Double(task.secondsElapsed)
          
          if min == -1 {
            min = secondsElapsed
            max = secondsElapsed
          }
          
          min = Double.minimum(min, secondsElapsed)
          max = Double.maximum(max, secondsElapsed)
          if currentRowNum == currentTask {  my = secondsElapsed }
        }
      }
    }
    return (Int(min), Int(max), Int(my))
  }
  
  func activateCountdownForTask(selectedTaskNum:Int, prevTaskNum:Int? = nil, keepPrevTimeElapsed:Bool = false) {
    
    // Turns on timer for given task
    
    guard selectedTaskNum >= 0 && self.taskList.count > selectedTaskNum else { return }
    
    let task:TaskItem = self.taskList[selectedTaskNum]
    
    resetAlarmStatus()  // Assure row highlights properly for next timed task
    cancelTimers() // Save current timer value
    task.startTimer()
    
    if countdownTimerActive && !task.timeOnly {
      
      if selectedTaskNum != prevTaskNum || prevTaskNum == nil || countdownBellWasRung == true {
        
        // get min,max,max,my duration
        
        if !keepPrevTimeElapsed {
          prevCountdownTimeElapsed = countdownTimeElapsed
          countdownTimeElapsed = 0
        }

        countdownTimeRemaining = countdownTimeDuration - countdownTimeElapsed
        
        if (normalizeCountdownDown == true || normalizeCountdownUp == true) {
          let (min, max, my) = getMinMaxMyDuration(currentTask: selectedTaskNum)
          if (normalizeCountdownUp && my < max) { countdownTimeElapsed -= max - my }
          else if (normalizeCountdownDown && my == max) { countdownTimeElapsed = my - min }
        }
      }
      
      countdownTimeStart = Date()
      
    } else { self.hideCountdownTimer() }
  }
  
  func getSecondsAsString(seconds:Int)->String{
    let hours   = Int(seconds) / 3600
    let minutes = Int(seconds) / 60 % 60
    let seconds = Int(seconds) % 60
    return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
  }
  
  func updateCountdownTimerDisplay(isActive:Bool=true) {
    
    // Update Countdown display and produce associated alarms if needed
    
    if let countdownTimeStart = countdownTimeStart, isActive == true {
      
        // First, update actual Countdown display text
        
        let timeRemaining = countdownTimeDuration - (countdownTimeElapsed + Int(floor(Date().timeIntervalSince(countdownTimeStart))))
        var countDownLabelText = getSecondsAsString(seconds:abs(timeRemaining))
        
        var labelColor:UIColor = TaskColor.black.value
        
        if timeRemaining <= 0 {
          
          labelColor = TaskColor.darkred.value
          if timeRemaining < 0 { countDownLabelText = "-\(countDownLabelText)" }
          
        } else if timeRemaining <= countdownWarningTimeDuration {
          
          labelColor = TaskColor.darkorange.value
        }

        self.countdownTimerLabel.textColor = labelColor
        DispatchQueue.main.async { self.countdownTimerLabel.text = countDownLabelText }
      
      // Now, handle alarms
      
      if countdownWarningTimeDuration > 0 && countdownWarningBellWasRung == false && timeRemaining <= countdownWarningTimeDuration {
        
        // Ring warning alarm
        
        countdownWarningBellWasRung = true
        self.playSound(soundName: "ding-sound-effect_2")
        
      } else if countdownBellWasRung == false && timeRemaining <= 0  {
        
        // Ring completion alarm
        
        countdownBellWasRung = true
        self.playSound(soundName: "Singing-bowl-sound")
        
      } else if countdownPostWarningTimeDuration > 0 &&
        ( countdownPostWarningBellsToRing > 0 || timeRemaining <= 0 - (countdownPostWarningTimeDuration * (countdownPostWarningBellWasRungCount+1)))
      {
        
        // Ring overage alarm each multiple the timeout duration is crossed increasing the number of bells each time it is rung
        // This is done not all at once but by setting a counter and ringing the alarm each time the loop is called (each second)
        // until the proper number of alarms is rung
        
        if (countdownPostWarningBellsToRing == 0 ) {
          countdownPostWarningBellWasRungCount  += 1
          countdownPostWarningBellsToRing = countdownPostWarningBellWasRungCount
        }
        
        self.playSound(soundName: "Ding-ding-sound")
        countdownPostWarningBellsToRing -= 1
      }
    }
  }
  
  func hideCountdownTimer() {
    
    DispatchQueue.main.async {
      self.resetCountdownTimer()
      self.clearCountdownTimerDisplay()
    }
  }
  
  func showCountdownTimer() {
    
    if countdownTimeStart == nil {
      countdownTimeStart = Date() // will prime the pump
    }
  }
  
  func resetCountdownTimer() {
    self.countdownTimeStart = nil
    self.countdownTimeRemaining = 0
    self.countdownTimeElapsed = 0
    self.countdownTimerLabel.text = ""
  }
  
  func clearCountdownTimerDisplay() {
    self.countdownTimerLabel.textColor = TaskColor.black.value
    self.countdownTimerLabel.text = ""
  }
  
  func resetAlarmStatus() {
    self.countdownWarningBellWasRung           = false
    self.countdownBellWasRung                  = false
    self.countdownPostWarningBellWasRungCount  = 0
    self.countdownPostWarningBellsToRing       = 0
  }
  
  // MARK: - Table Doubletap Timer Functions
  
  func startDoubleTapTimer(cell:TaskTableViewCell?) {
    if tableDoubleTapTimer == nil {
      let timer = Timer(timeInterval: 0.4,
                        target: self,
                        selector: #selector(handleDoubletapTimer),
                        userInfo: cell,
                        repeats: false)
      RunLoop.current.add(timer, forMode: .common)
      timer.tolerance = 0.05
      
      self.tableDoubleTapTimer = timer
    }
  }
  
  func cancelTableDoubleTapTimer() {
    tableDoubleTapTimer?.invalidate()
    tableDoubleTapTimer = nil
  }
  
  @objc func handleDoubletapTimer(timer:Timer) {
    
    let cell = timer.userInfo as! TaskTableViewCell
    cancelTableDoubleTapTimer()
    handleTapped(cell:cell)
  }
  
  // MARK: - Task Timer Functions
  
  func startTaskTimer() {
    
    // Main time contoller is here - just a ticker activating each second
    
    if taskTimer == nil {
      let timer = Timer(timeInterval: 1.0,
                        target: self,
                        selector: #selector(updateTaskTimer),
                        userInfo: nil,
                        repeats: true)
      RunLoop.current.add(timer, forMode: .common)
      timer.tolerance = 0.1
      
      self.taskTimer = timer
    }
  }
  
  func cancelTaskTimer() {
    taskTimer?.invalidate()
    taskTimer = nil
  }
    
  @objc func updateTaskTimer() {
    
    // Update cumulative Task Duration display and call to update Countdown display (if appropriate)
    
    guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else { return }

    // First check if Task timer is active
    
    var isActive = false
    
    for indexPath in visibleRowsIndexPaths {
      let selectedTaskNum = indexPath.last!
      isActive = (isActive || taskList[selectedTaskNum].isActive)
    }
    
    updateCountdownTimerDisplay(isActive: isActive) // Note: will set countdownWarningBellWasRung / countdownBellWasRung

    // Now, update times on Task List
    
    for indexPath in visibleRowsIndexPaths {
      if let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
        cell.updateTime(countdownWarningBellWasRung: countdownWarningBellWasRung, countdownBellWasRung: countdownBellWasRung)
      }
    }

  }
  
  @objc func cancelTimers() {
    
    // Terminates Task Timers for all Tasks
    
    guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else { return }
    
    for indexPath in visibleRowsIndexPaths {
      if let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
        cell.stopTimer()
      }
    }
  }
  
}
