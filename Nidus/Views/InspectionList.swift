//
//  InspectionList.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import SwiftUI

struct InspectionList: View {
	var inspections: [Inspection]

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
					InspectionDetail(inspection: inspection)
				} label: {
					Text("\(createdFormatted(inspection.created))")
				}
			}
		}
	}
}
