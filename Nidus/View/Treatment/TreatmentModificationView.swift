import SwiftUI

struct TreatmentModificationView: View {
	// Sample data that would come from your data model
	@State private var treatmentSteps = [
		TreatmentStep(id: UUID(), name: "VectoMax FG", quantity: "40 oz"),
		TreatmentStep(id: UUID(), name: "BVA oil", quantity: "4 oz"),
		TreatmentStep(id: UUID(), name: "Mosquitofish", quantity: "Add to water source"),
	]

	let sourceInfo = [
		("Dimensions", "10' x 20' x 4'", Color.blue),
		("Surface Area", "200 sq ft", Color.green),
		("Volume", "800 cu feet (~6000 gallons)", Color.purple),
		("Condition", "Pool is currently green", Color.orange),
	]

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				// Treatment Steps Section
				VStack(alignment: .leading, spacing: 10) {
					ForEach(treatmentSteps) { step in
						HStack {
							VStack(alignment: .leading) {
								Text(step.name)
									.fontWeight(.semibold)
								Text(step.quantity)
									.foregroundColor(.secondary)
							}

							Spacer()

							Button(action: {
								// Navigate to quantity modification view
							}) {
								Text("Edit")
									.padding(.horizontal, 10)
									.padding(.vertical, 5)
									.background(
										Color.blue.opacity(
											0.2
										)
									)
									.foregroundColor(.blue)
									.cornerRadius(8)
							}

							Button(action: {
								// Remove this treatment step
								if let index =
									treatmentSteps.firstIndex(
										where: {
											$0.id
												== step
												.id
										})
								{
									treatmentSteps.remove(
										at: index
									)
								}
							}) {
								Image(systemName: "trash")
									.foregroundColor(.red)
									.padding(.leading, 8)
							}
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(Color(.systemBackground))
								.shadow(
									color: Color.black.opacity(
										0.05
									),
									radius: 2
								)
						)
					}

					Button(action: {
						// Navigate to add treatment view
					}) {
						HStack {
							Image(systemName: "plus.circle.fill")
							Text("Add Treatment")
						}
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.green.opacity(0.2))
						.foregroundColor(.green)
						.cornerRadius(10)
					}
					.padding(.top, 5)
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(Color(.systemBackground))
						.shadow(color: Color.black.opacity(0.1), radius: 5)
				)

				// Source Information Section
				VStack(alignment: .leading, spacing: 15) {
					Text("Source Information")
						.font(.headline)
						.padding(.bottom, 5)

					ForEach(sourceInfo, id: \.0) { info in
						HStack {
							Text(info.0 + ":")
								.font(.body)
								.fontWeight(.medium)
								.frame(
									width: 100,
									alignment: .leading
								)

							Text(info.1)
								.foregroundColor(info.2)
								.fontWeight(.semibold)

							Spacer()

							if info.0 == "Dimensions" {
								Button(action: {
									// Navigate to dimensions edit view
								}) {
									Image(
										systemName:
											"pencil.circle"
									)
									.foregroundColor(.blue)
								}
							}

							if info.0 == "Condition" {
								Button(action: {
									// Navigate to condition edit view
								}) {
									Image(
										systemName:
											"pencil.circle"
									)
									.foregroundColor(.blue)
								}
							}
						}
					}
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(Color(.systemBackground))
						.shadow(color: Color.black.opacity(0.1), radius: 5)
				)

				Spacer()

				// Save Button
				Button(action: {
					// Save changes and navigate back
				}) {
					HStack {
						Image(systemName: "checkmark.circle.fill")
						Text("Save Changes")
					}
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(10)
				}
				.padding(.top, 10)
			}
			.padding()
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Modify Treatment")
		.background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
	}
}

// Model for treatment steps
struct TreatmentStep: Identifiable {
	let id: UUID
	let name: String
	let quantity: String
}

// Preview
struct TreatmentModificationView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			TreatmentModificationView()
		}
	}
}
