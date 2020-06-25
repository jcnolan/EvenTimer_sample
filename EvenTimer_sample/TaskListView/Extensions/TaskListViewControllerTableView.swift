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

// MARK: - UITableViewDataSource / UITableViewDelegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
  
  // Returns rowCount in table
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskList.count
  }
  
  // Sets background color and assigns associated task to cell on invocation
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
    
    if let cell = cell as? TaskTableViewCell {
      
      cell.task = taskList[indexPath.row]
      cell.contentView.backgroundColor = cell.isSelected ? selectedRowHighlightColor : TaskColor.white.value
    }
    
    return cell
  }
  
  // Set proper background color for given row
  
  func highlightTableRow(rowIndex:Int, forceOne:Bool=false) {
    
    for cell in self.tableView.visibleCells {
      
      if let indexPath = tableView.indexPath(for: cell) {
        
        if indexPath.last! == rowIndex {          
          cell.contentView.backgroundColor = selectedRowHighlightColor
        } else if forceOne {
          cell.contentView.backgroundColor = TaskColor.white.value
        }
      }
    }
  }
  
  func clearSelectedRows() {
  
    for cell in self.tableView.visibleCells {
        cell.contentView.backgroundColor = TaskColor.white.value
    }
  }
    
  func handleTapped(cell:TaskTableViewCell?) {
    
    // Defferred handler for tap - called by timer after .4 second delay
    
    guard let cell = cell else {return}
    guard let task = cell.task else { return }
    guard let selectedTaskNum:Int = tableView.indexPath(for:cell)?.last! else { return }

    clearSelectedRows()
    cell.contentView.backgroundColor = selectedRowHighlightColor
    
    let timerState = task.isActive // Note cancelTimers will reset timerState so needs to be pulled prior to cancel
    lastTableViewTapTimersWereActive = taskList.filter({ $0.isActive }).count != 0
    
    cancelTimers()
    
    if timerState == false {
      
      // Starting timer
      
      activateCountdownForTask(selectedTaskNum: selectedTaskNum, prevTaskNum: currentActiveTaskNum)
      lastTableViewTapStartedTimer = true
      
    } else {
      
      // Stopping timer
      
      task.stopTimer()
      lastTableViewTapStartedTimer = false
      
      if selectedTaskNum == currentActiveTaskNum {
        
        if let countdownTimeStart = countdownTimeStart {
          countdownTimeElapsed += Int(floor(Date().timeIntervalSince(countdownTimeStart)))
        }
      } else { }
    }
    
    // Save new active task number, saving previous value in case we need to back it out
    
    prevActiveTaskNum = currentActiveTaskNum
    currentActiveTaskNum = selectedTaskNum
    
    // Reset all timers, stopping inactive ones and starting active ones
    
    if taskList.filter({ $0.isActive }).count == 0 {
      cancelTaskTimer()
    } else {
      startTaskTimer()
    }
    
  }

  // Handler for left-swipe delete
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
      taskList.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  // Table was tapped on
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // First, save row to later check on a double-tap in the UITapGestureRecognizer for doubleTapped for the whole VIew
    
    let now: TimeInterval = Date().timeIntervalSince1970
    
    lastTableViewTapTime = now
    lastTableViewTapIndexPath = indexPath
    
    // No double-tap... keep looking
    
    guard let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else { return }
    
    startDoubleTapTimer(cell:cell)
  }
  
}
