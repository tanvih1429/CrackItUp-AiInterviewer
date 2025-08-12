import UIKit

extension UIButton {
    func applyCrackItStyle(title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = UIColor(red: 60/255, green: 36/255, blue: 12/255, alpha: 1.0) // #3C240C
        config.baseForegroundColor = UIColor(red: 241/255, green: 216/255, blue: 204/255, alpha: 1.0) // #F1D8CC
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        self.configuration = config

        // Shadow still needs to be applied directly
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.layer.shadowRadius = 6
    }
}
