//
//  InspectionList.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import SwiftUI

struct InspectionList: View {
	var inspections: [Inspection]
	let addFilter: (any Filter, String) -> Void

	func createdFormatted(_ created: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDate = formatter.localizedString(for: created, relativeTo: Date.now)
		return relativeDate
	}
	var body: some View {
		if inspections.isEmpty {
			Text("No Inspections Found")
		}
		else {
			List(inspections) { inspection in
				NavigationLink {
					InspectionDetail(
						inspection: inspection,
						addFilter: addFilter
					)
				} label: {
					Text("\(createdFormatted(inspection.created))")
				}
			}
		}
	}
}

struct InspectionList_Previews: PreviewProvider {
	static var addFilter: (any Filter, String) -> Void = { _, _ in }
	static var previews: some View {
		NavigationStack {
			InspectionList(
				inspections: [
					Inspection(
						comments: "it was gross",
						condition: "bad",
						created: Date.now.addingTimeInterval(-5000),
						fieldTechnician: "John Doe",
						id: UUID(),
						locationName: "somewhere"
					),
					Inspection(
						comments: "it was not too bad",
						condition: "acceptable",
						created: Date.now.addingTimeInterval(-3000),
						fieldTechnician: "Adam Smith",
						id: UUID(),
						locationName: "somewhere else"
					),
				],
				addFilter: addFilter
			)
		}
	}
}
