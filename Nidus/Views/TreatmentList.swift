//
//  TreatmentList.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import SwiftUI

struct TreatmentList: View {
	var treatments: [Treatment]
	let addFilter: (any Filter, String) -> Void

	func createdFormatted(_ created: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDate = formatter.localizedString(for: created, relativeTo: Date.now)
		return relativeDate
	}

	var body: some View {
		if treatments.isEmpty {
			Text("No Treatments Found")
		}
		else {
			List(treatments) { treatment in
				NavigationLink {
					TreatmentDetail(treatment: treatment, addFilter: addFilter)
				} label: {
					Text("\(createdFormatted(treatment.created))")
				}
			}
		}
	}
}
