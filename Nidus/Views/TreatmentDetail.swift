//
//  TreatmentDetail.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import SwiftUI

struct TreatmentDetail: View {
	var treatment: Treatment

	func createdFormatted(_ created: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDate = formatter.localizedString(for: created, relativeTo: Date.now)
		return relativeDate
	}

	var body: some View {
		Form {
			Text("Treatment of \(createdFormatted(treatment.created))")
			Text("Comments: \(treatment.comments)")
			Text("Habitat: \(treatment.habitat)")
			Text("Product: \(treatment.product)")
			Text("Quantity: \(treatment.quantity)")
			Text("Quantity Units: \(treatment.quantityUnit)")
			Text("Site Condition: \(treatment.siteCondition)")
			Text("Treat Acres: \(treatment.treatAcres)")
			Text("Treat Hectares: \(treatment.treatHectares)")
		}
	}
}
#Preview {
	TreatmentDetail(
		treatment: Treatment(
			comments: "No comment",
			created: Date.now.addingTimeInterval(-45000),
			fieldTechnician: "Captain Jane",
			habitat: "somewhere here",
			id: UUID(uuidString: "0aaf268c-5497-4bdf-86ce-044c53fa4db7")!,
			product: "cyanide",
			quantity: 100,
			quantityUnit: "metric tons",
			siteCondition: "wrecked",
			treatAcres: 0,
			treatHectares: 0
		)
	)
}
