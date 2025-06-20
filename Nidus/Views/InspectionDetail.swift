//
//  InspectionDetail.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import SwiftUI

struct InspectionDetail: View {
	var inspection: Inspection

	func createdFormatted(_ created: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDate = formatter.localizedString(for: created, relativeTo: Date.now)
		return relativeDate
	}

	var body: some View {
		Form {
			Text("Inspection of \(createdFormatted(inspection.created))")
			Text("Condition: \(inspection.condition ?? "Not provided")")
			Text("Comments: \(inspection.comments ?? "Not provided")")
		}
	}
}
#Preview {
	InspectionDetail(
		inspection: Inspection(
			comments: "it was gross",
			condition: "bad",
			created: Date.now.addingTimeInterval(-5000),
			fieldTechnician: "Some Guy",
			id: UUID()
		)
	)
}
