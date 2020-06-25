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

// All coloring is pulled out into seperate class to make uniform, system wide changes of color easy

enum TaskColor : String {
    
    case darkred    = "darkred"
    case darkorange = "darkorange"

    case grey05    = "grey05"
    case grey08    = "grey08"
    case grey10    = "grey10"
    case grey15    = "grey15"
    case grey20    = "grey20"
  
    case black     = "black"
    case white     = "white"
    case none      = "none"
    
    init(colorByName: String) {
      
        switch colorByName {
            
        case "darkred"    : self = .darkred
        case "darkorange" : self = .darkorange
          
        case "grey05"     : self = .grey05
        case "grey08"     : self = .grey08
        case "grey10"     : self = .grey10
        case "grey15"     : self = .grey15
        case "grey20"     : self = .grey20

        case "black"      : self = .black
        case "white"      : self = .white
        case "none"       : fallthrough
        default           : self = .black
        }
    }
    
    var value : UIColor {
        
        var retVal : UIColor!
        
            switch self {
                
            case .darkred    : retVal = UIColor(red: 0.66, green: 0.0, blue: 0.125, alpha: 1.0)
            case .darkorange : retVal = UIColor(red: 0.66, green: 0.25, blue: 0.0, alpha: 1.0)
              
            case .grey05  : retVal = UIColor.init(white: 0.95, alpha: 1.0)
            case .grey08  : retVal = UIColor.init(white: 0.92, alpha: 1.0)
            case .grey10  : retVal = UIColor.init(white: 0.9, alpha: 1.0)
            case .grey15  : retVal = UIColor.init(white: 0.85, alpha: 1.0)
            case .grey20  : retVal = UIColor.init(white: 0.8, alpha: 1.0)
                
            case .white  : retVal =  UIColor.init(white: 1.0, alpha: 1.0)
            case .none   : retVal =  UIColor.init(white: 0.0, alpha: 1.0)
            case .black  : fallthrough
              
            default      : retVal = UIColor(red: 0,    green: 0,    blue: 0,    alpha: 1.0)
            }
        
        return retVal
    }
}
