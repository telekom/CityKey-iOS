import UIKit

extension UISwitch {
    func customise(tintColor: UIColor, backgroundColor: UIColor) {
        let minSide = min(bounds.size.height, bounds.size.width)
        layer.cornerRadius = minSide / 2
        self.backgroundColor = backgroundColor
        self.onTintColor = tintColor
    }
}
