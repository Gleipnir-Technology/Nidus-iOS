import SwiftUI

struct TreatmentRecommendationView: View {
	// Sample data - in a real app, this would be passed in or fetched
	let recommendedSteps = [
		"Apply 2 oz of VectoMax FG",
		"Apply 1 oz of BVA oil",
		"Add 12 Mosquitofish to the water source",
	]

	let sourceInfo = [
		("Dimensions", "10' x 20' x 4'", Color.blue),
		("Surface Area", "200 sq ft", Color.green),
		("Volume", "800 cu feet (~6000 gallons)", Color.purple),
		("Condition", "Pool is currently green", Color.orange),
	]

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				// Header
				Text("Treatment Recommendation")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding(.bottom, 5)

				// Recommendation Section
				VStack(alignment: .leading, spacing: 15) {
					Text("Recommended Treatment")
						.font(.headline)
						.padding(.bottom, 5)

					ForEach(recommendedSteps, id: \.self) { step in
						HStack(alignment: .top) {
							Text("•")
								.font(.title2)
								.foregroundColor(.accentColor)
							Text(step)
								.font(.body)
						}
					}
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

				// Action Buttons
				VStack(spacing: 15) {
					Button(action: {
						// Handle applied recommendations
					}) {
						HStack {
							Image(systemName: "checkmark.circle.fill")
							Text("Applied Recommendations")
						}
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.green)
						.foregroundColor(.white)
						.cornerRadius(10)
					}

					NavigationLink(destination: TreatmentEditView()) {
						HStack {
							Image(systemName: "slider.horizontal.3")
							Text("Alter Treatment")
						}
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.blue)
						.foregroundColor(.white)
						.cornerRadius(10)
					}
				}
			}
			.padding()
		}
		.navigationBarTitle("", displayMode: .inline)
		.background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
	}
}

// Preview
struct TreatmentRecommendationView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			TreatmentRecommendationView()
		}
	}
}
