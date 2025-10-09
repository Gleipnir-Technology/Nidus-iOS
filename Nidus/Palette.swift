import SwiftUI

struct Palette {
	let A: Color
	let B: Color
	let C: Color
	let D: Color
	let E: Color
}

// Palette from https://coolors.co/c4a69d-98a886-465c69-363457-735290
let COLOR_ROSY_RED: Color = Color(hexString: "#C4A69D")!
let COLOR_CAMBRIDGE_BLUE: Color = Color(hexString: "#98A886")!
let COLOR_PAYNES_GRAY: Color = Color(hexString: "#465C69")!
let COLOR_SPACE_CADET: Color = Color(hexString: "#363457")!
let COLOR_ULTRA_VIOLET: Color = Color(hexString: "#735290")!
let PALETTE_LIGHT: Palette = .init(
	A: COLOR_ROSY_RED,
	B: COLOR_CAMBRIDGE_BLUE,
	C: COLOR_PAYNES_GRAY,
	D: COLOR_SPACE_CADET,
	E: COLOR_ULTRA_VIOLET
)
