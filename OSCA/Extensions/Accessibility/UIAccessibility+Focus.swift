import UIKit

extension UIAccessibility {
    static func delayAndSetFocusTo(_ object: Any?) {
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + addDelayInAnnouncing()) {
                UIAccessibility.post(notification: .layoutChanged, argument: object)
            }
        }
    }
    
    static func setFocusTo(_ object: Any?) {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .layoutChanged, argument: object)
        }
    }
    
    static func setFocusWhenScreenChanged(_ object: Any?) {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .screenChanged, argument: object)
        }
    }
    
    private static func addDelayInAnnouncing() -> CGFloat {
        return UIAccessibility.isVoiceOverRunning ? 1.5 : 0.8
    }
}
