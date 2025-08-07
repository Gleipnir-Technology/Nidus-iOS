import MapKit

struct BreadcrumbModel {
	var overlayResolution: Int = 8
	var selectedCell: H3Cell? = nil
	var userCell: H3Cell? = nil
	var userPreviousCells: [H3Cell] = []

	struct Preview {
	}
}
