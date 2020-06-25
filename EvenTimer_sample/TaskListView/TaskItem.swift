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

class TaskItem {
  
  var name: String
  var isActive: Bool          = false // set to true to make task idle at start
  let creationDate            = Date()
  var timerStartDate          = Date()
  var secondsElapsed: Double  = 0
  var timeOnly: Bool          = false; // If true indicates that this field only logs time, no alarm needed
  
  init(name: String) {
    self.name = name
  }
  
  // Handles "timers" for each task, though the naming is somewhat misleading as there is only one functional
  // "timer" in actuality.  But if the bit is set to on the "timer" for the task is active. Currently, the code
  // is set to have only one task timer active at a time but having multiple task timers active one need only
  // set multiple isActive bits to "on"
  
  func stopTimer() {
    if isActive == true {
      secondsElapsed += Date().timeIntervalSince(timerStartDate)
      isActive = false
    }
  }
  
  func startTimer() {
    timerStartDate = Date()
    isActive = true
  }
  
}
