// https://github.com/Quick/Quick

import APExtensions
import Nimble
import Nimble_Snapshots
import Quick
@testable import APTips

@available(iOS 13.0, *)
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
            button.borderColor = .link
            button.sizeToFit()
            button.center = hostView.bounds.center
            hostView.addSubview(button)
            Utils.showInWindow(resizeableView: hostView)
        }
        
        it("should have proper layout for center display mode and bottom position") {
            button.center.y += 10
            showTipView(displayMode: .center)
            expect(hostView).to(haveValidSnapshot())
        }
        
        it("should have proper layout for center display mode and top position") {
            button.center.y -= 10
            showTipView(displayMode: .center)
            expect(hostView).to(haveValidSnapshot())
        }
        
        it("should have proper layout for side display mode and bottom position") {
            button.center.y += 10
            showTipView(displayMode: .side)
            expect(hostView).to(haveValidSnapshot())
        }
        
        it("should have proper layout for side display mode and top position") {
            button.center.y -= 10
            showTipView(displayMode: .side)
            expect(hostView).to(haveValidSnapshot())
        }
        
        func showTipView(displayMode: TipView.DisplayMode) {
            let tipView = TipView.create(tip: tip, for: button, displayMode: displayMode, completion: { _ in })
            hostView.addSubview(tipView)
            hostView.layoutIfNeeded()
        }
    }
}
