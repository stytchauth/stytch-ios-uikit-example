import UIKit

extension UIColor {
    static let brand: UIColor = .init(red: 0.10, green: 0.19, blue: 0.24, alpha: 1.00)
    static let placeholder: UIColor = .init(red: 0.68, green: 0.74, blue: 0.77, alpha: 1.00)
    static let error: UIColor = .init(red: 0.55, green: 0.07, blue: 0.08, alpha: 1.00)
    static let disabled: UIColor = .init(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.00)
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
