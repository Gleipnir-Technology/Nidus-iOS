import SwiftUI

struct PoolDimensionsEditView: View {
	@Environment(\.presentationMode) var presentationMode

	// Unit selection
	@State private var selectedUnit: DimensionUnit = .feet

	// Current dimensions (editable)
	@State private var length: Double = 20.0
	@State private var width: Double = 10.0
	@State private var depth: Double = 4.0

	// Original dimensions (for reference)
	let originalLength: Double = 20.0
	let originalWidth: Double = 10.0
	let originalDepth: Double = 4.0
	let originalUnit: DimensionUnit = .feet

	// Computed properties
	var surfaceArea: Double {
		return length * width
	}

	var volume: Double {
		return length * width * depth
	}

	var volumeGallons: Double {
		let cubicFeet = volume
		let gallonsPerCubicFoot = 7.48052

		switch selectedUnit {
		case .inches:
			return (cubicFeet / 1728.0) * gallonsPerCubicFoot  // 1728 cubic inches in a cubic foot
		case .feet:
			return cubicFeet * gallonsPerCubicFoot
		case .meters:
			return (cubicFeet * 35.3147) * gallonsPerCubicFoot  // 1 cubic meter = 35.3147 cubic feet
		}
	}

	// Formatter for numeric input
	private let formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		return formatter
	}()

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				// Header
				Text("Edit Pool Dimensions")
					.font(.largeTitle)
					.fontWeight(.bold)

				// Unit selection
				unitSelectionSection

				// Dimension inputs
				dimensionInputsSection

				// Calculated values
				calculatedValuesSection

				// Original values reference
				originalValuesSection

				Spacer()

				// Action buttons
				actionButtonsSection
			}
			.padding()
		}
		.navigationTitle("Pool Dimensions")
		.background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
	}

	// MARK: - Sections

	private var unitSelectionSection: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Unit of Measure")
				.font(.headline)

			Picker("Unit", selection: $selectedUnit) {
				ForEach(DimensionUnit.allCases, id: \.self) { unit in
					Text(unit.rawValue).tag(unit)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: Color.black.opacity(0.1), radius: 5)
		)
	}

	private var dimensionInputsSection: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Dimensions")
				.font(.headline)
				.padding(.bottom, 5)

			// Length input
			HStack {
				Text("Length:")
					.frame(width: 80, alignment: .leading)

				TextField("Length", value: $length, formatter: formatter)
					.keyboardType(.decimalPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())

				Text(selectedUnit.rawValue)
					.foregroundColor(.secondary)
					.frame(width: 60)
			}

			// Width input
			HStack {
				Text("Width:")
					.frame(width: 80, alignment: .leading)

				TextField("Width", value: $width, formatter: formatter)
					.keyboardType(.decimalPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())

				Text(selectedUnit.rawValue)
					.foregroundColor(.secondary)
					.frame(width: 60)
			}

			// Depth input
			HStack {
				Text("Depth:")
					.frame(width: 80, alignment: .leading)

				TextField("Depth", value: $depth, formatter: formatter)
					.keyboardType(.decimalPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())

				Text(selectedUnit.rawValue)
					.foregroundColor(.secondary)
					.frame(width: 60)
			}
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: Color.black.opacity(0.1), radius: 5)
		)
	}

	private var calculatedValuesSection: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Calculated Values")
				.font(.headline)
				.padding(.bottom, 5)

			HStack {
				Text("Surface Area:")
					.frame(width: 120, alignment: .leading)

				Text(
					"\(formatter.string(from: NSNumber(value: surfaceArea)) ?? "0") \(areaUnit)"
				)
				.foregroundColor(.green)
				.fontWeight(.semibold)
			}

			HStack {
				Text("Volume:")
					.frame(width: 120, alignment: .leading)

				Text(
					"\(formatter.string(from: NSNumber(value: volume)) ?? "0") \(volumeUnit)"
				)
				.foregroundColor(.blue)
				.fontWeight(.semibold)
			}

			HStack {
				Text("Gallons:")
					.frame(width: 120, alignment: .leading)

				Text(
					"\(formatter.string(from: NSNumber(value: volumeGallons)) ?? "0") gal"
				)
				.foregroundColor(.purple)
				.fontWeight(.semibold)
			}
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: Color.black.opacity(0.1), radius: 5)
		)
	}

	private var originalValuesSection: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Original Dimensions")
				.font(.headline)
				.padding(.bottom, 5)

			HStack {
				Text("Length:")
					.frame(width: 80, alignment: .leading)
					.foregroundColor(.secondary)

				Text(
					"\(formatter.string(from: NSNumber(value: originalLength)) ?? "0") \(originalUnit.rawValue)"
				)
				.fontWeight(.medium)
			}

			HStack {
				Text("Width:")
					.frame(width: 80, alignment: .leading)
					.foregroundColor(.secondary)

				Text(
					"\(formatter.string(from: NSNumber(value: originalWidth)) ?? "0") \(originalUnit.rawValue)"
				)
				.fontWeight(.medium)
			}

			HStack {
				Text("Depth:")
					.frame(width: 80, alignment: .leading)
					.foregroundColor(.secondary)

				Text(
					"\(formatter.string(from: NSNumber(value: originalDepth)) ?? "0") \(originalUnit.rawValue)"
				)
				.fontWeight(.medium)
			}

			Divider()

			// Original calculated values
			let origSurfaceArea = originalLength * originalWidth
			let origVolume = originalLength * originalWidth * originalDepth

			HStack {
				Text("Surface Area:")
					.frame(width: 120, alignment: .leading)
					.foregroundColor(.secondary)

				Text(
					"\(formatter.string(from: NSNumber(value: origSurfaceArea)) ?? "0") sq \(originalUnit.rawValue)"
				)
				.foregroundColor(.green.opacity(0.7))
			}

			HStack {
				Text("Volume:")
					.frame(width: 120, alignment: .leading)
					.foregroundColor(.secondary)

				Text(
					"\(formatter.string(from: NSNumber(value: origVolume)) ?? "0") cu \(originalUnit.rawValue)"
				)
				.foregroundColor(.blue.opacity(0.7))
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

	// Helper computed properties for units
	private var areaUnit: String {
		switch selectedUnit {
		case .inches: return "sq in"
		case .feet: return "sq ft"
		case .meters: return "sq m"
		}
	}

	private var volumeUnit: String {
		switch selectedUnit {
		case .inches: return "cu in"
		case .feet: return "cu ft"
		case .meters: return "cu m"
		}
	}
}

// MARK: - Supporting Types

enum DimensionUnit: String, CaseIterable {
	case inches = "in"
	case feet = "ft"
	case meters = "m"
}

// MARK: - Preview

struct PoolDimensionsEditView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			PoolDimensionsEditView()
		}
	}
}
