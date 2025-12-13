import SwiftUI

struct TreatmentEditView: View {
	@Environment(\.presentationMode) var presentationMode

	// Treatment information
	let treatmentName = "VectoMax FG"
	@State var quantity: Double = 40.0
	let unit = "oz"

	// Pool information
	let poolDimensions = "10' x 20' x 4'"
	let surfaceArea = "200 sq ft"
	let poolVolume = "800 cu ft (~6000 gallons)"

	// Recommended application rates
	let applicationRates = [
		("Small pools", "5-10 oz", "Up to 100 sq ft"),
		("Medium pools", "10-30 oz", "100-300 sq ft"),
		("Large pools", "30-60 oz", "300-600 sq ft"),
	]

	// Validation thresholds for this pool size (200 sq ft)
	let minRecommended: Double = 20.0
	let maxRecommended: Double = 50.0

	// Warning status
	var warningStatus: WarningStatus {
		if quantity < minRecommended {
			return .tooLow
		}
		else if quantity > maxRecommended {
			return .tooHigh
		}
		else {
			return .normal
		}
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				// Treatment name and type
				VStack(alignment: .leading) {
					Text(treatmentName)
						.font(.title2)
						.fontWeight(.semibold)
					Text("Biological Larvicide")
						.foregroundColor(.secondary)
				}

				// Instructions
				instructionsSection

				// Application rates table
				applicationRatesSection

				// Quantity adjustment
				quantityAdjustmentSection

				// Warning message
				warningMessageSection

				// Pool information
				poolInformationSection

				Spacer()

				// Action buttons
				actionButtonsSection
			}
			.padding()
		}
		.navigationTitle("Edit Treatment")
		.navigationBarTitle("", displayMode: .inline)
		.background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
	}

	// MARK: - Sections

	private var instructionsSection: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Application Instructions")
				.font(.headline)
				.padding(.bottom, 2)

			Text(
				"Apply VectoMax FG directly to the water surface. Uniform coverage is necessary for optimal control. Use higher rates in areas with dense vegetation or when late instar larvae predominate."
			)
			.font(.body)
			.foregroundColor(.secondary)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: Color.black.opacity(0.1), radius: 5)
		)
	}

	private var applicationRatesSection: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Recommended Application Rates")
				.font(.headline)
				.padding(.bottom, 2)

			VStack(spacing: 0) {
				// Table header
				HStack {
					Text("Pool Type")
						.font(.subheadline)
						.fontWeight(.medium)
						.frame(maxWidth: .infinity, alignment: .leading)

					Text("Rate")
						.font(.subheadline)
						.fontWeight(.medium)
						.frame(width: 100, alignment: .leading)

					Text("Area")
						.font(.subheadline)
						.fontWeight(.medium)
						.frame(width: 100, alignment: .leading)
				}
				.padding(.vertical, 8)
				.padding(.horizontal, 12)
				.background(Color(.systemGray5))
				.cornerRadius(8, corners: [.topLeft, .topRight])

				// Table rows
				ForEach(applicationRates, id: \.0) { rate in
					HStack {
						Text(rate.0)
							.frame(
								maxWidth: .infinity,
								alignment: .leading
							)

						Text(rate.1)
							.foregroundColor(.blue)
							.frame(width: 100, alignment: .leading)

						Text(rate.2)
							.foregroundColor(.secondary)
							.frame(width: 100, alignment: .leading)
					}
					.padding(.vertical, 8)
					.padding(.horizontal, 12)
					.background(Color(.systemBackground))

					Divider()
						.padding(.horizontal, 12)
				}
			}
			.cornerRadius(8)
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(Color(.systemGray4), lineWidth: 1)
			)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: Color.black.opacity(0.1), radius: 5)
		)
	}

	private var quantityAdjustmentSection: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Adjust Treatment Quantity")
				.font(.headline)
				.padding(.bottom, 2)

			HStack(alignment: .center, spacing: 15) {
				// Stepper
				Stepper("", value: $quantity, in: 1...100, step: 5)
					.labelsHidden()

				// Text field for direct input
				TextField(
					"Quantity",
					value: $quantity,
					formatter: NumberFormatter()
				)
				.keyboardType(.decimalPad)
				.font(.system(size: 24, weight: .bold))
				.multilineTextAlignment(.center)
				.frame(width: 100)
				.padding(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color(.systemGray4), lineWidth: 1)
				)

				// Unit
				Text(unit)
					.font(.headline)
					.foregroundColor(.secondary)

				Spacer()
			}

			// Slider for more intuitive adjustment
			Slider(value: $quantity, in: 1...100, step: 1)
				.accentColor(warningStatus.color)
				.padding(.top, 5)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: Color.black.opacity(0.1), radius: 5)
		)
	}

	private var warningMessageSection: some View {
		Group {
			if warningStatus != .normal {
				VStack(alignment: .leading, spacing: 10) {
					HStack {
						Image(systemName: warningStatus.iconName)
							.foregroundColor(warningStatus.color)

						Text(warningStatus.title)
							.font(.headline)
							.foregroundColor(warningStatus.color)
					}

					Text(warningStatus.message)
						.font(.body)
						.foregroundColor(.secondary)
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(warningStatus.color.opacity(0.1))
						.overlay(
							RoundedRectangle(cornerRadius: 12)
								.stroke(
									warningStatus.color.opacity(
										0.3
									),
									lineWidth: 1
								)
						)
				)
			}
		}
	}

	private var poolInformationSection: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Pool Information")
				.font(.headline)
				.padding(.bottom, 2)

			HStack {
				Text("Dimensions:")
					.fontWeight(.medium)
				Text(poolDimensions)
					.foregroundColor(.blue)
			}

			HStack {
				Text("Surface Area:")
					.fontWeight(.medium)
				Text(surfaceArea)
					.foregroundColor(.green)
			}

			HStack {
				Text("Volume:")
					.fontWeight(.medium)
				Text(poolVolume)
					.foregroundColor(.purple)
			}
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: Color.black.opacity(0.1), radius: 5)
		)
	}

	private var actionButtonsSection: some View {
		HStack(spacing: 15) {
			Button(action: {
				// Cancel and go back
				presentationMode.wrappedValue.dismiss()
			}) {
				Text("Cancel")
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color(.systemGray5))
					.foregroundColor(.primary)
					.cornerRadius(10)
			}

			Button(action: {
				// Save changes and go back
				presentationMode.wrappedValue.dismiss()
			}) {
				Text("Save Changes")
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(10)
			}
		}
	}
}

// MARK: - Supporting Types

enum WarningStatus {
	case normal
	case tooLow
	case tooHigh

	var iconName: String {
		switch self {
		case .normal:
			return "checkmark.circle.fill"
		case .tooLow, .tooHigh:
			return "exclamationmark.triangle.fill"
		}
	}

	var title: String {
		switch self {
		case .normal:
			return "Recommended Amount"
		case .tooLow:
			return "Amount Too Low"
		case .tooHigh:
			return "Amount Too High"
		}
	}

	var message: String {
		switch self {
		case .normal:
			return "This amount is within the recommended range for this pool size."
		case .tooLow:
			return
				"This amount is below the recommended minimum for effective mosquito control. Consider increasing the treatment quantity."
		case .tooHigh:
			return
				"This amount exceeds the recommended maximum for this pool size. Excessive treatment may have environmental impacts and wastes product."
		}
	}

	var color: Color {
		switch self {
		case .normal:
			return .green
		case .tooLow:
			return .orange
		case .tooHigh:
			return .red
		}
	}
}

// Helper for rounded corners on specific sides
extension View {
	func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		clipShape(RoundedCorner(radius: radius, corners: corners))
	}
}

struct RoundedCorner: Shape {
	var radius: CGFloat = .infinity
	var corners: UIRectCorner = .allCorners

	func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: corners,
			cornerRadii: CGSize(width: radius, height: radius)
		)
		return Path(path.cgPath)
	}
}

// MARK: - Preview

struct TreatmentEditView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			// Normal amount preview
			NavigationView {
				TreatmentEditView(quantity: 40.0)
			}
			.previewDisplayName("Normal Amount")

			// Too high amount preview
			NavigationView {
				TreatmentEditView(quantity: 80.0)
			}
			.previewDisplayName("Too High Amount")

			// Too low amount preview
			NavigationView {
				TreatmentEditView(quantity: 10.0)
			}
			.previewDisplayName("Too Low Amount")
		}
	}
}
