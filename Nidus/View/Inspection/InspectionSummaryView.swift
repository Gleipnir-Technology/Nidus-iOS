import MapKit
import SwiftUI

// MARK: - Models

enum VisitSource {
	case trapCount(counts: [TrapCount])
	case serviceRequest(requestInfo: ServiceRequestInfo)
	case aerialImagery(image: UIImage)
}

struct TrapCount {
	let date: Date
	let count: Int
}

struct ServiceRequestInfo {
	let requestedBy: String
	let requestDate: Date
	let requestMethod: RequestMethod

	enum RequestMethod: String {
		case phone = "Phone"
		case online = "Online"
	}
}

struct Resident {
	let name: String
	let phone: String
	let email: String
	let notes: String
}

struct TimelineEvent: Identifiable {
	let id = UUID()
	let date: Date
	let title: String
	let description: String
	let type: EventType
	let additionalContent: EventContent?

	enum EventType: String {
		case notice = "Notice"
		case droneImage = "Drone Flyover"
		case treatment = "Treatment"
		case inspection = "Inspection"
		case fishPresence = "Mosquitofish"
	}

	enum EventContent {
		case image(UIImage)
		case note(String)
	}
}

// MARK: - Inspection Summary View

struct InspectionSummaryView: View {
	@State private var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
		span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
	)
	@State private var isResidentView = false

	let resident: Resident
	let visitSource: VisitSource
	let timelineEvents: [TimelineEvent]

	var body: some View {
		ZStack {
			if isResidentView {
				ResidentView(
					isResidentView: $isResidentView,
					resident: resident,
					visitSource: visitSource,
					timelineEvents: timelineEvents
				)
			}
			else {
				// Original Tech View Content
				ScrollView {
					VStack(alignment: .leading, spacing: 20) {
						// Resident Information Section
						residentInfoSection

						// Previous Interaction Notes
						previousInteractionNotes

						// Visit Source Information
						visitSourceSection

						// Map
						locationMapSection

						// Timeline
						timelineSection

						// Extra space at bottom for the floating button
						Spacer(minLength: 80)
					}
					.padding()
				}

				// Floating Toggle Button
				viewToggleButton
			}
		}
		.navigationTitle(isResidentView ? "Evidence Summary" : "Inspection Summary")
	}

	// MARK: - Resident Info Section

	private var residentInfoSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text("Resident Information")
					.font(.headline)

				Spacer()

				Button(action: {
					// Action to edit resident information
				}) {
					Image(systemName: "pencil.circle.fill")
						.font(.title2)
				}
				.accessibilityLabel("Edit resident information")
			}

			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(resident.name)
						.font(.title3)
						.fontWeight(.semibold)

					Label(resident.phone, systemImage: "phone")
						.font(.subheadline)

					Label(resident.email, systemImage: "envelope")
						.font(.subheadline)
				}

				Spacer()
			}
			.padding()
			.background(Color(.systemGray6))
			.cornerRadius(12)
		}
	}

	// MARK: - Previous Interaction Notes

	private var previousInteractionNotes: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Previous Interaction Notes")
				.font(.headline)

			Text(resident.notes)
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(Color.yellow.opacity(0.2))
						.overlay(
							RoundedRectangle(cornerRadius: 12)
								.stroke(
									Color.yellow.opacity(0.5),
									lineWidth: 1
								)
						)
				)
		}
	}

	// MARK: - Visit Source Section

	private var visitSourceSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Visit Source")
				.font(.headline)

			switch visitSource {
			case .trapCount(let counts):
				trapCountView(counts: counts)
			case .serviceRequest(let info):
				serviceRequestView(info: info)
			case .aerialImagery(let image):
				aerialImageryView(image: image)
			}
		}
		.padding()
		.background(Color(.systemGray6))
		.cornerRadius(12)
	}

	private func trapCountView(counts: [TrapCount]) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Trap Count Threshold Exceeded")
				.font(.subheadline)
				.fontWeight(.semibold)

			// Simple bar chart for trap counts
			HStack(alignment: .bottom, spacing: 8) {
				ForEach(0..<counts.count, id: \.self) { index in
					VStack {
						Text("\(counts[index].count)")
							.font(.caption)

						Rectangle()
							.fill(Color.blue)
							.frame(
								width: 30,
								height: CGFloat(
									counts[index].count * 5
								)
							)

						Text(formatDate(counts[index].date))
							.font(.caption)
							.rotationEffect(.degrees(-45))
							.offset(y: 5)
					}
				}
			}
			.frame(height: 150)
			.padding(.top)
		}
	}

	private func serviceRequestView(info: ServiceRequestInfo) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Service Request")
				.font(.subheadline)
				.fontWeight(.semibold)

			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text("Requested by:")
						.fontWeight(.medium)
					Text(info.requestedBy)
				}

				Spacer()

				VStack(alignment: .leading, spacing: 4) {
					Text("Method:")
						.fontWeight(.medium)
					Text(info.requestMethod.rawValue)
				}

				Spacer()

				VStack(alignment: .leading, spacing: 4) {
					Text("When:")
						.fontWeight(.medium)
					Text(timeAgo(from: info.requestDate))
				}
			}
		}
	}

	private func aerialImageryView(image: UIImage) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Aerial Imagery Detection")
				.font(.subheadline)
				.fontWeight(.semibold)

			HStack {
				Spacer()
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(height: 150)
					.cornerRadius(8)
				Spacer()
			}
		}
	}

	// MARK: - Location Map Section

	private var locationMapSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Location")
				.font(.headline)

			Map(
				coordinateRegion: $region,
				annotationItems: [
					IdentifiablePlace(id: 1, coordinate: region.center)
				]
			) { place in
				MapMarker(coordinate: place.coordinate, tint: .red)
			}
			.frame(height: 200)
			.cornerRadius(12)
		}
	}

	// MARK: - Timeline Section

	private var timelineSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Activity Timeline")
				.font(.headline)

			ForEach(timelineEvents) { event in
				TimelineEventRow(event: event)
			}
		}
	}

	// MARK: - View Toggle Button

	private var viewToggleButton: some View {
		VStack {
			Spacer()

			Button(action: {
				withAnimation {
					isResidentView.toggle()
				}
			}) {
				HStack {
					Image(
						systemName: isResidentView
							? "person.badge.shield.checkmark" : "person"
					)
					Text(isResidentView ? "Tech View" : "Resident View")
				}
				.padding()
				.background(Color.blue)
				.foregroundColor(.white)
				.cornerRadius(25)
				.shadow(radius: 5)
			}
			.padding(.bottom, 16)
		}
	}

	// MARK: - Helper Functions

	private func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/dd"
		return formatter.string(from: date)
	}

	private func timeAgo(from date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter.localizedString(for: date, relativeTo: Date())
	}
}

// MARK: - Supporting Views

struct TimelineEventRow: View {
	let event: TimelineEvent
	@State private var showDetail = false

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Circle()
					.fill(eventColor(for: event.type))
					.frame(width: 12, height: 12)

				Text(event.title)
					.font(.subheadline)
					.fontWeight(.semibold)

				Spacer()

				Text(formatDate(event.date))
					.font(.caption)
					.foregroundColor(.secondary)
			}

			HStack {
				Rectangle()
					.fill(Color.gray.opacity(0.3))
					.frame(width: 1)
					.padding(.leading, 5.5)

				VStack(alignment: .leading, spacing: 6) {
					Text(event.description)
						.font(.body)

					if let additionalContent = event.additionalContent {
						switch additionalContent {
						case .image(let image):
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
								.frame(height: 120)
								.cornerRadius(8)
						case .note(let note):
							if showDetail {
								Text(note)
									.font(.body)
									.padding()
									.background(
										Color(.systemGray6)
									)
									.cornerRadius(8)
							}
						}
					}

					if event.additionalContent != nil {
						Button(action: {
							withAnimation {
								showDetail.toggle()
							}
						}) {
							Text(showDetail ? "Show Less" : "Show More")
								.font(.caption)
								.foregroundColor(.blue)
						}
					}
				}
				.padding(.leading, 10)
			}
		}
		.padding(.vertical, 8)
	}

	private func eventColor(for type: TimelineEvent.EventType) -> Color {
		switch type {
		case .notice:
			return .orange
		case .droneImage:
			return .blue
		case .treatment:
			return .green
		case .inspection:
			return .purple
		case .fishPresence:
			return .teal
		}
	}

	private func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d, yyyy"
		return formatter.string(from: date)
	}
}

// MARK: - Helper Types

struct IdentifiablePlace: Identifiable {
	let id: Int
	let coordinate: CLLocationCoordinate2D
}

// MARK: - Previews

struct InspectionSummaryView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			// Trap Count Preview
			NavigationView {
				InspectionSummaryView(
					resident: sampleResident,
					visitSource: .trapCount(counts: sampleTrapCounts),
					timelineEvents: sampleTimelineEvents
				)
			}
			.previewDisplayName("Trap Count Source")

			// Service Request Preview
			NavigationView {
				InspectionSummaryView(
					resident: sampleResident,
					visitSource: .serviceRequest(
						requestInfo: sampleServiceRequest
					),
					timelineEvents: sampleTimelineEvents
				)
			}
			.previewDisplayName("Service Request Source")

			// Aerial Imagery Preview
			NavigationView {
				InspectionSummaryView(
					resident: sampleResident,
					visitSource: .aerialImagery(
						image: UIImage(systemName: "photo")!
					),
					timelineEvents: sampleTimelineEvents
				)
			}
			.previewDisplayName("Aerial Imagery Source")
		}
	}

	// Sample Data
	static let sampleResident = Resident(
		name: "John Smith",
		phone: "(555) 123-4567",
		email: "john.smith@example.com",
		notes:
			"Resident is generally cooperative but works during the day. Best to visit after 5pm. Has expressed concerns about chemicals being used near vegetable garden."
	)

	static let sampleTrapCounts: [TrapCount] = [
		TrapCount(date: Date().addingTimeInterval(-21 * 24 * 60 * 60), count: 5),
		TrapCount(date: Date().addingTimeInterval(-14 * 24 * 60 * 60), count: 12),
		TrapCount(date: Date().addingTimeInterval(-7 * 24 * 60 * 60), count: 18),
	]

	static let sampleServiceRequest = ServiceRequestInfo(
		requestedBy: "Jane Doe (Neighbor)",
		requestDate: Date().addingTimeInterval(-3 * 24 * 60 * 60),
		requestMethod: .phone
	)

	static let sampleTimelineEvents: [TimelineEvent] = [
		TimelineEvent(
			date: Date().addingTimeInterval(-30 * 24 * 60 * 60),
			title: "Notice Posted",
			description: "Notice was posted to the resident's door",
			type: .notice,
			additionalContent: .note(
				"Door hanger was left with contact information and explanation of observed standing water in backyard."
			)
		),
		TimelineEvent(
			date: Date().addingTimeInterval(-21 * 24 * 60 * 60),
			title: "Drone Flyover",
			description: "A drone flyover was performed of the site",
			type: .droneImage,
			additionalContent: .image(UIImage(systemName: "photo")!)
		),
		TimelineEvent(
			date: Date().addingTimeInterval(-14 * 24 * 60 * 60),
			title: "Site Treatment",
			description: "A tech treated the site with larvicide",
			type: .treatment,
			additionalContent: .note(
				"Applied 3oz of Altosid to standing water in unused fountain. Recommended removal of fountain or regular maintenance."
			)
		),
		TimelineEvent(
			date: Date().addingTimeInterval(-7 * 24 * 60 * 60),
			title: "Mosquitofish Confirmation",
			description: "Mosquitofish were confirmed present in pond",
			type: .fishPresence,
			additionalContent: nil
		),
	]
}
