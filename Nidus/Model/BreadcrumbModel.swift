import MapKit

struct BreadcrumbModel {
	var overlayResolution: Int = 8
	var selectedCell: UInt64? = nil
	var userCell: UInt64? = nil
	var userPreviousCells: [UInt64] = []

	struct Preview {
	}
}
