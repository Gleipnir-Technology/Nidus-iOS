//
//  TreatmentDetail.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import SwiftUI

struct TreatmentDetail: View {
	var treatment: Treatment
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
			Text("Treatment of \(createdFormatted(treatment.created))")
			Text("Comments: \(treatment.comments)")
			FilterableField(
				filter: filters.fieldTechnician,
				label: "Field Technician",
				value: treatment.fieldTechnician,
				addFilter: addFilter
			)
			Text("Habitat: \(treatment.habitat)")
			FilterableField(
				filter: filters.product,
				label: "Product",
				value: treatment.product,
				addFilter: addFilter
			)
			Text("Quantity: \(treatment.quantity)")
			Text("Quantity Units: \(treatment.quantityUnit)")
			Text("Site Condition: \(treatment.siteCondition)")
			Text("Treat Acres: \(treatment.treatAcres)")
			Text("Treat Hectares: \(treatment.treatHectares)")
		}.toast(message: "Filter added", isShowing: $showFilterToast, duration: Toast.short)
	}
}
struct TreatmentDetail_Previews: PreviewProvider {
	static var addFilter: (any Filter, String) -> Void = { _, _ in }
	static var previews: some View {

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
			),
			addFilter: addFilter
		)
	}
}
