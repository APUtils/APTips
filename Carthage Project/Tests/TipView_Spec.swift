// https://github.com/Quick/Quick

import APExtensions
import Nimble
import Nimble_Snapshots
import Quick
@testable import APTips

class TipView_Spec: QuickSpec {
    override func spec() {
        let tip = Tip(message: "An example unit layout test message for a tip")
        var hostView: UIView!
        var button: UIButton!
        
        beforeEach {
            hostView = UIView(frame: u.defaultWindowRect)
            hostView.backgroundColor = .white
            
            button = UIButton(type: .system)
            button.setTitle("Button")
            button.borderOnePixelWidth = true
            button.borderColor = #colorLiteral(red: 0, green: 0.478, blue: 1, alpha: 1)
            button.sizeToFit()
            button.center = hostView.bounds.center
            hostView.addSubview(button)
            Utils.showInWindow(resizeableView: hostView)
        }
        
        it("should have proper layout for center display mode and bottom position") {
            button.center.y += 10
            showTipView(pointingMode: .center)
            expect(hostView).to(haveValidSnapshot())
        }
        
        it("should have proper layout for center display mode and top position") {
            button.center.y -= 10
            showTipView(pointingMode: .center)
            expect(hostView).to(haveValidSnapshot())
        }
        
        it("should have proper layout for side display mode and bottom position") {
            button.center.y += 10
            showTipView(pointingMode: .side)
            expect(hostView).to(haveValidSnapshot())
        }
        
        it("should have proper layout for side display mode and top position") {
            button.center.y -= 10
            showTipView(pointingMode: .side)
            expect(hostView).to(haveValidSnapshot())
        }
        
        func showTipView(pointingMode: TipView.PointingMode) {
            let tipView = TipView.create(tip: tip, for: button, pointingMode: pointingMode, completion: { _ in })
            hostView.addSubview(tipView)
            hostView.layoutIfNeeded()
        }
    }
}
