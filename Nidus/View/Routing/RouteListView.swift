import SwiftUI

struct RouteListView: View {
	@State private var progressPercentage: Double = 0.35  // 35% through schedule
	@State private var timeStatus: Int = 15  // 15 minutes ahead of schedule
	@State private var lastSyncTime = Date().addingTimeInterval(-900)  // 15 minutes ago

	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				// Progress Overview Card
				progressOverviewCard

				// Current Task Card
				currentTaskCard

				// Upcoming Tasks
				upcomingTasksSection
			}
			.padding(.horizontal)
		}
		.navigationTitle("Today's Route")
		.navigationBarTitleDisplayMode(.inline)
		/*
		.toolbar {
		    ToolbarItem(placement: .navigationBarTrailing) {
		        Button(action: {
		            // Refresh action
		        }) {
		            Image(systemName: "arrow.clockwise")
		        }
		    }
		}
		*/
	}

	// MARK: - Progress Overview
	private var progressOverviewCard: some View {
		VStack(spacing: 12) {
			Text("Route Progress")
				.font(.headline)
				.frame(maxWidth: .infinity, alignment: .leading)

			ProgressView(value: progressPercentage)
				.progressViewStyle(LinearProgressViewStyle(tint: .blue))

			HStack {
				Text("3 of 8 sites complete")
					.font(.subheadline)
				Spacer()
				HStack {
					Image(
						systemName: timeStatus >= 0
							? "clock.badge.checkmark"
							: "clock.badge.exclamationmark"
					)
					.foregroundColor(timeStatus >= 0 ? .green : .red)

					Text(
						timeStatus >= 0
							? "\(timeStatus) min ahead"
							: "\(abs(timeStatus)) min behind"
					)
					.foregroundColor(timeStatus >= 0 ? .green : .red)
					.font(.subheadline)
				}
			}

			Divider()

			HStack {
				Image(systemName: "arrow.triangle.2.circlepath")
				Text("Last synced: \(timeAgo(lastSyncTime))")
				Spacer()
				NavigationLink(destination: RouteAddView()) {
					HStack {
						Image(systemName: "plus")
						Text("Add stop")
					}
					.font(.subheadline)
					.foregroundColor(.blue)
				}
			}
			.font(.caption)
		}
		.padding()
		.background(Color(.systemBackground))
		.cornerRadius(12)
		.shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
	}

	// MARK: - Current Task Card
	private var currentTaskCard: some View {
		VStack(spacing: 12) {
			HStack {
				Image(systemName: "drop.fill")
					.font(.title2)
					.foregroundColor(.green)
					.padding(8)
					.background(Color.green.opacity(0.2))
					.cornerRadius(8)

				VStack(alignment: .leading) {
					Text("Green Pool Inspection")
						.font(.headline)
					Text("10:30 AM - 11:15 AM")
						.font(.subheadline)
						.foregroundColor(.gray)
				}

				Spacer()

				HStack {
					Image(systemName: "location.fill")
					Text("2.3 mi")
						.font(.subheadline)
				}
			}

			Divider()

			HStack {
				Image(systemName: "mappin.and.ellipse")
					.foregroundColor(.secondary)
				VStack(alignment: .leading) {
					Text("123 Maple Street")
						.font(.callout)
					Text("Springfield, CA 95678")
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
				Spacer()
			}

			Divider()

			HStack(spacing: 20) {
				Button(action: {}) {
					VStack {
						Image(systemName: "location.fill")
							.font(.title3)
						Text("Navigate")
							.font(.caption)
					}
					.frame(maxWidth: .infinity)
				}

				Button(action: {}) {
					VStack {
						Image(systemName: "forward.fill")
							.font(.title3)
						Text("Skip")
							.font(.caption)
					}
					.frame(maxWidth: .infinity)
				}

				Button(action: {}) {
					VStack {
						Image(systemName: "checkmark.circle.fill")
							.font(.title3)
							.foregroundColor(.green)
						Text("Complete")
							.font(.caption)
					}
					.frame(maxWidth: .infinity)
				}
			}
			.padding(.top, 4)
		}
		.padding()
		.background(Color(.systemBackground))
		.cornerRadius(12)
		.shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
	}

	// MARK: - Upcoming Tasks
	private var upcomingTasksSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Upcoming Tasks")
				.font(.headline)
				.padding(.top, 4)

			VStack(spacing: 12) {
				taskRow(
					icon: "drop.triangle.fill",
					color: .blue,
					title: "Larvicide Follow-up",
					time: "11:30 AM - 12:00 PM",
					distance: 3.5
				)

				taskRow(
					icon: "water.waves",
					color: .teal,
					title: "Ditch Inspection",
					time: "12:15 PM - 1:00 PM",
					distance: 4.2
				)

				taskRow(
					icon: "water.waves.and.arrow.down",
					color: .cyan,
					title: "Canal Inspection",
					time: "1:30 PM - 2:30 PM",
					distance: 6.8
				)

				taskRow(
					icon: "person.crop.circle.badge.exclamationmark",
					color: .red,
					title: "Service Request",
					time: "3:00 PM - 3:30 PM",
					distance: 5.1
				)
			}
		}
	}

	// MARK: - Helper Views
	private func taskRow(
		icon: String,
		color: Color,
		title: String,
		time: String,
		distance: Double
	) -> some View {
		HStack {
			Image(systemName: icon)
				.font(.title3)
				.foregroundColor(color)
				.frame(width: 40, height: 40)
				.background(color.opacity(0.2))
				.cornerRadius(8)

			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.callout)
					.fontWeight(.medium)
				Text(time)
					.font(.subheadline)
					.foregroundColor(.gray)
			}

			Spacer()

			HStack {
				Image(systemName: "location.fill")
					.foregroundColor(.secondary)
					.font(.caption)
				Text("\(String(format: "%.1f", distance)) mi")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
		.padding()
		.background(Color(.systemBackground))
		.cornerRadius(10)
		.shadow(color: Color(.systemGray4), radius: 1, x: 0, y: 1)
	}

	// MARK: - Helper Functions
	private func timeAgo(_ date: Date) -> String {
		let minutes = Int(-date.timeIntervalSinceNow / 60)

		if minutes < 1 {
			return "Just now"
		}
		else if minutes == 1 {
			return "1 minute ago"
		}
		else if minutes < 60 {
			return "\(minutes) minutes ago"
		}
		else if minutes < 120 {
			return "1 hour ago"
		}
		else {
			let hours = minutes / 60
			return "\(hours) hours ago"
		}
	}
}

struct RouteListView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			RouteListView()
		}
	}
}
