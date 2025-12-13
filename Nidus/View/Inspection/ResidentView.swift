import Charts
import SwiftUI

struct ResidentView: View {
	@Binding var isResidentView: Bool
	let resident: Resident
	let visitSource: VisitSource
	let timelineEvents: [TimelineEvent]
	@State private var selectedImage: UIImage? = nil
	@State private var showFullScreenImage = false

	var body: some View {
		ZStack {
			ScrollView {
				VStack(spacing: 30) {
					// Evidence Section
					evidenceSection

					// Timeline Section
					timelineSection

					// Next Steps Section
					nextStepsSection

					// Resident Information (simplified)
					residentInfoSection

					// Extra space for the floating button
					Spacer(minLength: 80)
				}
				.padding(.horizontal)  // Ensure horizontal padding for the entire content
			}
			// Apply safe area insets
			.edgesIgnoringSafeArea(.bottom)

			// Small toggle button to return to tech view
			viewToggleButton.position(x: -70, y: 340)

			// Full screen image overlay
			if showFullScreenImage, let image = selectedImage {
				fullScreenImageView(image: image)
			}
		}
		.navigationTitle("Mosquito Breeding Evidence")
		.navigationBarTitleDisplayMode(.large)
	}

	// MARK: - Evidence Section

	private var evidenceSection: some View {
		VStack(alignment: .leading, spacing: 20) {
			Text("Evidence of Concern")
				.font(.system(size: 28, weight: .bold))
				.frame(maxWidth: .infinity, alignment: .leading)  // Ensure proper alignment
				.padding(.horizontal)  // Add explicit horizontal padding

			// Different evidence based on visit source
			Group {
				switch visitSource {
				case .aerialImagery(let image):
					aerialEvidenceView(image: image)
				case .serviceRequest:
					reportEvidenceView()
				case .trapCount(let counts):
					trapCountEvidenceView(counts: counts)
				}
			}

			// Any pool photos from timeline events
			poolPhotosView
		}
		.padding()  // Add padding around the entire section
		.background(Color(.systemGray6))
		.cornerRadius(16)
	}

	private func aerialEvidenceView(image: UIImage) -> some View {
		VStack(spacing: 15) {
			Text("Aerial Image Shows Green Water")
				.font(.system(size: 22, weight: .semibold))
				.multilineTextAlignment(.center)
				.frame(maxWidth: .infinity)  // Ensure text spans full width

			Image(uiImage: image)
				.resizable()
				.scaledToFit()
				.frame(height: 220)
				.cornerRadius(12)
				.onTapGesture {
					selectedImage = image
					showFullScreenImage = true
				}
				.overlay(
					Image(systemName: "magnifyingglass.circle.fill")
						.font(.system(size: 30))
						.foregroundColor(.white)
						.shadow(radius: 2)
						.padding(8),
					alignment: .bottomTrailing
				)
		}
		.padding(.horizontal)  // Add explicit horizontal padding
	}

	private func reportEvidenceView() -> some View {
		VStack(spacing: 15) {
			Text("Reported by Community")
				.font(.system(size: 22, weight: .semibold))
				.multilineTextAlignment(.center)
				.frame(maxWidth: .infinity)  // Ensure text spans full width

			HStack(spacing: 20) {
				Spacer()  // Add spacer to center the content

				VStack {
					Image(
						systemName:
							"person.crop.circle.badge.exclamationmark.fill"
					)
					.font(.system(size: 50))
					.foregroundColor(.orange)
					Text("Concern Reported")
						.font(.system(size: 18))
				}

				VStack {
					Image(systemName: "calendar")
						.font(.system(size: 50))
						.foregroundColor(.blue)
					Text("Recently")
						.font(.system(size: 18))
				}

				VStack {
					Image(systemName: "house.fill")
						.font(.system(size: 50))
						.foregroundColor(.green)
					Text("This Location")
						.font(.system(size: 18))
				}

				Spacer()  // Add spacer to center the content
			}
		}
		.padding(.horizontal)  // Add explicit horizontal padding
	}

	private func trapCountEvidenceView(counts: [TrapCount]) -> some View {
		VStack(spacing: 15) {
			Text("High Mosquito Activity Nearby")
				.font(.system(size: 22, weight: .semibold))
				.multilineTextAlignment(.center)
				.frame(maxWidth: .infinity)  // Ensure text spans full width

			Chart {
				ForEach(counts.indices, id: \.self) { index in
					BarMark(
						x: .value(
							"Date",
							formatShortDate(counts[index].date)
						),
						y: .value("Count", counts[index].count)
					)
					.foregroundStyle(Color.red.gradient)
					.cornerRadius(8)
					.annotation(position: .top) {
						Text("\(counts[index].count)")
							.font(.system(size: 18, weight: .bold))
					}
				}
			}
			.frame(height: 200)
			.padding(.horizontal)

			Text("Above Normal Threshold")
				.font(.system(size: 20, weight: .medium))
				.foregroundColor(.red)
				.padding(.top, 10)
				.frame(maxWidth: .infinity, alignment: .center)  // Center this text
		}
		.padding(.horizontal)  // Add explicit horizontal padding
	}

	private var poolPhotosView: some View {
		let poolPhotos =
			timelineEvents
			.compactMap { event in
				if case .image(let image) = event.additionalContent {
					return (event, image)
				}
				return nil
			}

		return Group {
			if !poolPhotos.isEmpty {
				VStack(spacing: 15) {
					Text("Site Photos")
						.font(.system(size: 22, weight: .semibold))
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.horizontal)  // Add horizontal padding

					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 15) {
							// Add initial spacing to prevent left cutoff
							Spacer().frame(width: 10)

							ForEach(poolPhotos, id: \.0.id) {
								(event, image) in
								VStack {
									Image(uiImage: image)
										.resizable()
										.scaledToFill()
										.frame(
											width: 200,
											height: 150
										)
										.cornerRadius(12)
										.clipped()
										.onTapGesture {
											selectedImage =
												image
											showFullScreenImage =
												true
										}
										.overlay(
											Image(
												systemName:
													"magnifyingglass.circle.fill"
											)
											.font(
												.system(
													size:
														24
												)
											)
											.foregroundColor(
												.white
											)
											.shadow(
												radius:
													2
											)
											.padding(8),
											alignment:
												.bottomTrailing
										)

									Text(formatDate(event.date))
										.font(
											.system(
												size:
													16
											)
										)
								}
							}

							// Add final spacing
							Spacer().frame(width: 10)
						}
					}
					.padding(.horizontal)  // Add horizontal padding
				}
			}
		}
	}

	// MARK: - Timeline Section

	private var timelineSection: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Actions Taken")
				.font(.system(size: 28, weight: .bold))
				.frame(maxWidth: .infinity, alignment: .leading)  // Ensure proper alignment
				.padding(.horizontal)  // Add explicit horizontal padding

			VStack(spacing: 0) {
				ForEach(timelineEvents.indices, id: \.self) { index in
					let event = timelineEvents[index]

					HStack(alignment: .top, spacing: 15) {
						// Timeline connector
						VStack(spacing: 0) {
							if index > 0 {
								Rectangle()
									.fill(Color.gray)
									.frame(width: 3)
									.frame(height: 30)
							}

							Circle()
								.fill(eventColor(for: event.type))
								.frame(width: 30, height: 30)
								.overlay(
									eventIcon(for: event.type)
										.font(
											.system(
												size:
													16
											)
										)
										.foregroundColor(
											.white
										)
								)

							if index < timelineEvents.count - 1 {
								Rectangle()
									.fill(Color.gray)
									.frame(width: 3)
									.frame(height: 30)
							}
						}

						// Event details
						VStack(alignment: .leading, spacing: 5) {
							Text(formatDateWithTime(event.date))
								.font(
									.system(
										size: 20,
										weight: .semibold
									)
								)

							Text(event.title)
								.font(
									.system(
										size: 24,
										weight: .bold
									)
								)
								.foregroundColor(
									eventColor(for: event.type)
								)

							Text(event.description)
								.font(.system(size: 18))
								.padding(.bottom, 8)
						}
						.padding(.bottom, 15)

						Spacer()  // Ensure content doesn't stretch too wide
					}
					.padding(.horizontal)  // Add explicit horizontal padding
				}
			}
			.padding()
			.background(Color(.systemGray6))
			.cornerRadius(16)
		}
		.padding(.horizontal)  // Add additional horizontal padding to the section
	}

	// MARK: - Next Steps Section

	private var nextStepsSection: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Next Steps")
				.font(.system(size: 28, weight: .bold))
				.frame(maxWidth: .infinity, alignment: .leading)  // Ensure proper alignment
				.padding(.horizontal)  // Add explicit horizontal padding

			// Use GeometryReader to ensure proper sizing and prevent overflow
			GeometryReader { geometry in
				HStack(spacing: 20) {
					Spacer(minLength: 0)

					// Calculate item width based on available space
					let itemWidth = min(80, (geometry.size.width - 100) / 3)

					VStack {
						ZStack {
							Circle()
								.fill(Color.blue.opacity(0.2))
								.frame(
									width: itemWidth,
									height: itemWidth
								)
							Image(systemName: "checkmark.circle.fill")
								.font(.system(size: itemWidth / 2))
								.foregroundColor(.blue)
						}
						Text("Inspection")
							.font(.system(size: 18, weight: .medium))
						Text("Today")
							.font(.system(size: 16))
					}

					Image(systemName: "arrow.right")
						.font(.system(size: 20))

					VStack {
						ZStack {
							Circle()
								.fill(Color.green.opacity(0.2))
								.frame(
									width: itemWidth,
									height: itemWidth
								)
							Image(systemName: "drop.fill")
								.font(.system(size: itemWidth / 2))
								.foregroundColor(.green)
						}
						Text("Treatment")
							.font(.system(size: 18, weight: .medium))
						Text("If needed")
							.font(.system(size: 16))
					}

					Image(systemName: "arrow.right")
						.font(.system(size: 20))

					VStack {
						ZStack {
							Circle()
								.fill(Color.purple.opacity(0.2))
								.frame(
									width: itemWidth,
									height: itemWidth
								)
							Image(systemName: "shield.fill")
								.font(.system(size: itemWidth / 2))
								.foregroundColor(.purple)
						}
						Text("Protection")
							.font(.system(size: 18, weight: .medium))
						Text("For all")
							.font(.system(size: 16))
					}

					Spacer(minLength: 0)
				}
				.frame(height: 150)
			}
			.frame(height: 150)
			.padding()
			.background(Color(.systemGray6))
			.cornerRadius(16)
		}
	}

	// MARK: - Resident Information Section

	private var residentInfoSection: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Is This Your Information?")
				.font(.system(size: 28, weight: .bold))
				.frame(maxWidth: .infinity, alignment: .leading)  // Ensure proper alignment
				.padding(.horizontal)  // Add explicit horizontal padding

			HStack {
				VStack(alignment: .leading, spacing: 8) {
					Text(resident.name)
						.font(.system(size: 24, weight: .semibold))

					Label(resident.phone, systemImage: "phone")
						.font(.system(size: 20))

					Label(resident.email, systemImage: "envelope")
						.font(.system(size: 20))
				}
				.padding(.horizontal)  // Add horizontal padding
				.padding(.vertical)  // Add vertical padding

				Spacer()
			}
			.frame(maxWidth: .infinity)
			.background(Color(.systemGray6))
			.cornerRadius(16)
		}
		.padding(.horizontal)  // Add additional horizontal padding to the section
	}

	// MARK: - View Toggle Button

	private var viewToggleButton: some View {
		VStack {
			Spacer()

			HStack {
				Spacer()

				Button(action: {
					withAnimation {
						isResidentView.toggle()
					}
				}) {
					Image(systemName: "person.badge.shield.checkmark")
						.font(.system(size: 20))
						.padding()
						.background(Color.blue.opacity(0.8))
						.foregroundColor(.white)
						.clipShape(Circle())
						.shadow(radius: 3)
				}
				.padding([.trailing, .bottom], 20)
			}
		}
	}

	// MARK: - Full Screen Image View

	private func fullScreenImageView(image: UIImage) -> some View {
		ZStack {
			Color.black.edgesIgnoringSafeArea(.all)

			Image(uiImage: image)
				.resizable()
				.scaledToFit()
				.edgesIgnoringSafeArea(.all)

			VStack {
				HStack {
					Spacer()

					Button(action: {
						showFullScreenImage = false
					}) {
						Image(systemName: "xmark.circle.fill")
							.font(.system(size: 30))
							.foregroundColor(.white)
							.padding()
					}
				}

				Spacer()
			}
		}
	}

	// MARK: - Helper Functions and Properties

	private func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d"
		return formatter.string(from: date)
	}

	private func formatShortDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "M/d"
		return formatter.string(from: date)
	}

	private func formatDateWithTime(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d, h:mm a"
		return formatter.string(from: date)
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

	private func eventIcon(for type: TimelineEvent.EventType) -> Image {
		switch type {
		case .notice:
			return Image(systemName: "doc.text.fill")
		case .droneImage:
			return Image(systemName: "airplane")
		case .treatment:
			return Image(systemName: "drop.fill")
		case .inspection:
			return Image(systemName: "eye.fill")
		case .fishPresence:
			return Image(systemName: "fish.fill")
		}
	}
}
// MARK: - Preview for Resident View

struct ResidentView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			ResidentView(
				isResidentView: .constant(true),
				resident: InspectionSummaryView_Previews.sampleResident,
				visitSource: .aerialImagery(image: UIImage(systemName: "photo")!),
				timelineEvents: InspectionSummaryView_Previews.sampleTimelineEvents
			)
		}

		NavigationView {
			ResidentView(
				isResidentView: .constant(true),
				resident: InspectionSummaryView_Previews.sampleResident,
				visitSource: .trapCount(
					counts: InspectionSummaryView_Previews.sampleTrapCounts
				),
				timelineEvents: InspectionSummaryView_Previews.sampleTimelineEvents
			)
		}

		NavigationView {
			ResidentView(
				isResidentView: .constant(true),
				resident: InspectionSummaryView_Previews.sampleResident,
				visitSource: .serviceRequest(
					requestInfo: InspectionSummaryView_Previews
						.sampleServiceRequest
				),
				timelineEvents: InspectionSummaryView_Previews.sampleTimelineEvents
			)
		}
	}
}
