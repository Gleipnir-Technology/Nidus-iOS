import SwiftUI
// from https://stackoverflow.com/questions/36341358/how-to-convert-uicolor-to-string-and-string-to-uicolor-using-swift#answer-62192394
import UIKit

extension Color {

	init?(hexString: String) {

		let rgbaData = getrgbaData(hexString: hexString)

		if rgbaData != nil {

			self.init(
				.sRGB,
				red: Double(rgbaData!.r),
				green: Double(rgbaData!.g),
				blue: Double(rgbaData!.b),
				opacity: Double(rgbaData!.a)
			)
			return
		}
		return nil
	}
}

extension UIColor {

	public convenience init?(hexString: String) {

		let rgbaData = getrgbaData(hexString: hexString)

		if rgbaData != nil {
			self.init(
				red: rgbaData!.r,
				green: rgbaData!.g,
				blue: rgbaData!.b,
				alpha: rgbaData!.a
			)
			return
		}
		return nil
	}
}

private func getrgbaData(hexString: String) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {

	var rgbaData: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? = nil

	if hexString.hasPrefix("#") {

		let start = hexString.index(hexString.startIndex, offsetBy: 1)
		let hexColor = String(hexString[start...])  // Swift 4

		let scanner = Scanner(string: hexColor)
		var hexNumber: UInt64 = 0

		if scanner.scanHexInt64(&hexNumber) {

			rgbaData = {  // start of a closure expression that returns a Vehicle
				switch hexColor.count {
				case 8:

					return (
						r: CGFloat((hexNumber & 0xff00_0000) >> 24) / 255,
						g: CGFloat((hexNumber & 0x00ff_0000) >> 16) / 255,
						b: CGFloat((hexNumber & 0x0000_ff00) >> 8) / 255,
						a: CGFloat(hexNumber & 0x0000_00ff) / 255
					)
				case 6:

					return (
						r: CGFloat((hexNumber & 0xff0000) >> 16) / 255,
						g: CGFloat((hexNumber & 0x00ff00) >> 8) / 255,
						b: CGFloat((hexNumber & 0x0000ff)) / 255,
						a: 1.0
					)
				default:
					return nil
				}
			}()

		}
	}

	return rgbaData
}
