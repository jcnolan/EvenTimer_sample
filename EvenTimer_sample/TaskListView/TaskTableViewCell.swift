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

class TaskTableViewCell: UITableViewCell {
  
  @IBOutlet weak var taskLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  var task: TaskItem? {
    didSet {
      taskLabel.text = task?.name
      updateTime()
    }
  }
  
  func stopTimer() {
    guard let task = task else { return }
    task.stopTimer()
  }
  
  func updateTime(countdownWarningBellWasRung:Bool=false, countdownBellWasRung:Bool=false) {
    
    // Handler for updating the time label on the task item
    
    guard let task = task else { return }
    
    var secondsElapsed:Double = task.secondsElapsed
    
    var labelColor:UIColor = TaskColor.black.value
    
    if task.isActive {
      
      secondsElapsed += Date().timeIntervalSince(task.timerStartDate)
  
      if countdownBellWasRung             { labelColor = TaskColor.darkred.value }
      else if countdownWarningBellWasRung { labelColor = TaskColor.darkorange.value }
    }
    
    let hours   = Int(secondsElapsed) / 3600
    let minutes = Int(secondsElapsed) / 60 % 60
    let seconds = Int(secondsElapsed) % 60
    
    var times: [String] = []
    if hours > 0    { times.append("\(hours)h") }
    if minutes > 0  { times.append("\(minutes)m") }
    times.append("\(seconds)s")
    
    DispatchQueue.main.async {
      self.timeLabel.textColor = labelColor
      self.taskLabel.textColor = labelColor
      self.timeLabel.text = times.joined(separator: " ")
    }
  }
}
