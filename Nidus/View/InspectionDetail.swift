//
//  InspectionDetail.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import SwiftUI

struct InspectionDetail: View {
	var inspection: Inspection
	let addFilter: (any Filter, String) -> Void
	@State private var showFilterToast = false

	func createdFormatted(_ created: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDate = formatter.localizedString(for: created, relativeTo: Date.now)
		return relativeDate
	}

	var body: some View {
		Form {
			Text("Inspection of \(createdFormatted(inspection.created))")
			FilterableField(
				filter: filters.actionTaken,
				label: "Action Taken",
				value: inspection.actionTaken ?? "Unknown",
				addFilter: addFilter
			)
			Text("Condition: \(inspection.condition ?? "Not provided")")
			Text("Comments: \(inspection.comments ?? "Not provided")")
			FilterableField(
				filter: filters.fieldTechnician,
				label: "Field Technician",
				value: inspection.fieldTechnician,
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.locationName,
				label: "Location",
				value: inspection.locationName ?? "Unknown",
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.siteCondition,
				label: "Site Condition",
				value: inspection.siteCondition ?? "Unknown",
				addFilter: addFilter
			)
		}.toast(message: "Filter saved", isShowing: $showFilterToast, duration: Toast.short)
	}
}

struct InspectionDetail_Previews: PreviewProvider {
	static var addFilter: (any Filter, String) -> Void = { _, _ in }
	static var previews: some View {
		InspectionDetail(
			inspection: Inspection(
				comments: "it was gross",
				condition: "bad",
				created: Date.now.addingTimeInterval(-5000),
				fieldTechnician: "Some Guy",
				id: UUID(),
				locationName: "somewhere"
			),
			addFilter: addFilter
		)
	}
}
