//
//  Extension.swift
//  Pods
//
//  Created by Neha on 18/12/25.
//

extension UIFont {
    static func growthRegular(size: CGFloat) -> UIFont {
        UIFont(name: "Inter-Regular", size: size) ?? .systemFont(ofSize: size)
    }

    static func growthBold(size: CGFloat) -> UIFont {
        UIFont(name: "Inter-SemiBold", size: size) ?? .boldSystemFont(ofSize: size)
    }
}
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
extension String {
    var urlDecoded: String {
        return self
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding ?? self
    }
}
