import MapKit
import SwiftUI

struct RouteAddView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var searchText = ""
	@State private var selectedTask: NearbyTask?

	// Sample data
	private let currentTask = CurrentTask(
		title: "Green Pool Inspection",
		address: "123 Maple Street, Springfield, CA 95678",
		timeBlock: "10:30 AM - 11:15 AM",
		distance: 0.0  // Current location
	)

	private let nearbyTasks = [
		NearbyTask(
			id: 1,
			type: .larvicideFollowup,
			address: "456 Oak Avenue, Springfield, CA 95678",
			distance: 1.2,
			estimatedDuration: 30
		),
		NearbyTask(
			id: 2,
			type: .serviceRequest,
			address: "789 Pine Road, Springfield, CA 95679",
			distance: 1.8,
			estimatedDuration: 45
		),
		NearbyTask(
			id: 3,
			type: .ditchInspection,
			address: "234 Elm Street, Springfield, CA 95678",
			distance: 2.3,
			estimatedDuration: 40
		),
		NearbyTask(
			id: 4,
			type: .canalInspection,
			address: "567 Cedar Lane, Springfield, CA 95680",
			distance: 3.5,
			estimatedDuration: 60
		),
		NearbyTask(
			id: 5,
			type: .greenPoolInspection,
			address: "890 Birch Court, Springfield, CA 95681",
			distance: 4.2,
			estimatedDuration: 45
		),
		NearbyTask(
			id: 6,
			type: .serviceRequest,
			address: "123 Willow Drive, Springfield, CA 95682",
			distance: 5.1,
			estimatedDuration: 30
		),
	]

	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				// Map Placeholder
				mapPlaceholder

				ScrollView {
					VStack(spacing: 16) {
						// Current Task Card
						currentTaskCard

						// Nearby Tasks Section
						nearbyTasksSection
					}
					.padding(.horizontal)
					.padding(.bottom)
				}
			}
			.navigationTitle("Add Stop")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Cancel") {
						dismiss()
					}
				}
			}
			.sheet(item: $selectedTask) { task in
				TaskDetailsSheet(task: task) {
					// Add to schedule action
					selectedTask = nil
				}
			}
		}
	}

	// MARK: - Map Placeholder
	private var mapPlaceholder: some View {
		ZStack(alignment: .bottomTrailing) {
			Color(.systemGray6)
				.frame(height: 200)
				.overlay(
					VStack {
						Image(systemName: "map")
							.font(.system(size: 40))
							.foregroundColor(.gray)
						Text("Map View")
							.foregroundColor(.gray)
					}
				)
		}
	}

	// MARK: - Current Task Card
	private var currentTaskCard: some View {
		VStack(spacing: 12) {
			HStack {
				Text("Current Task")
					.font(.headline)
				Spacer()
			}

			HStack {
				Image(systemName: "drop.fill")
					.font(.title3)
					.foregroundColor(.green)
					.padding(8)
					.background(Color.green.opacity(0.2))
					.cornerRadius(8)

				VStack(alignment: .leading, spacing: 4) {
					Text(currentTask.title)
						.font(.subheadline)
						.fontWeight(.medium)

					Text(currentTask.address)
						.font(.caption)
						.foregroundColor(.secondary)

					Text(currentTask.timeBlock)
						.font(.caption)
						.foregroundColor(.blue)
				}

				Spacer()
			}
		}
		.padding()
		.background(Color(.systemBackground))
		.cornerRadius(12)
		.shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
	}

	// MARK: - Nearby Tasks Section
	private var nearbyTasksSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Nearby Tasks")
					.font(.headline)

				Spacer()

				// Filter selector (could be expanded)
				Menu {
					Button("All Tasks", action: {})
					Button("Service Requests", action: {})
					Button("Inspections", action: {})
				} label: {
					Label(
						"Filter",
						systemImage: "line.3.horizontal.decrease.circle"
					)
					.font(.subheadline)
				}
			}

			// Search bar
			HStack {
				Image(systemName: "magnifyingglass")
					.foregroundColor(.secondary)

				TextField("Search by address", text: $searchText)

				if !searchText.isEmpty {
					Button(action: {
						searchText = ""
					}) {
						Image(systemName: "xmark.circle.fill")
							.foregroundColor(.secondary)
					}
				}
			}
			.padding(8)
			.background(Color(.systemGray6))
			.cornerRadius(10)

			// Task list
			ForEach(nearbyTasks.sorted { $0.distance < $1.distance }) { task in
				nearbyTaskRow(task)
					.onTapGesture {
						selectedTask = task
					}
			}
		}
	}

	// MARK: - Nearby Task Row
	private func nearbyTaskRow(_ task: NearbyTask) -> some View {
		HStack {
			// Task icon
			Image(systemName: task.type.iconName)
				.font(.title3)
				.foregroundColor(task.type.color)
				.frame(width: 40, height: 40)
				.background(task.type.color.opacity(0.2))
				.cornerRadius(8)

			// Task details
			VStack(alignment: .leading, spacing: 2) {
				Text(task.type.title)
					.font(.callout)
					.fontWeight(.medium)

				Text(task.address)
					.font(.caption)
					.foregroundColor(.secondary)
					.lineLimit(1)

				HStack {
					// Distance indicator
					HStack(spacing: 2) {
						Image(systemName: "location.fill")
							.font(.caption2)
						Text("\(String(format: "%.1f", task.distance)) mi")
							.font(.caption)
					}
					.foregroundColor(.secondary)

					Spacer()
						.frame(width: 10)

					// Duration indicator
					HStack(spacing: 2) {
						Image(systemName: "clock.fill")
							.font(.caption2)
						Text("\(task.estimatedDuration) min")
							.font(.caption)
					}
					.foregroundColor(.secondary)
				}
			}

			Spacer()

			// Add button
			Button(action: {
				selectedTask = task
			}) {
				Image(systemName: "plus.circle.fill")
					.font(.title3)
					.foregroundColor(.blue)
			}
		}
		.padding()
		.background(Color(.systemBackground))
		.cornerRadius(10)
		.shadow(color: Color(.systemGray4), radius: 1, x: 0, y: 1)
	}
}

// MARK: - Supporting Models and Views
struct CurrentTask {
	let title: String
	let address: String
	let timeBlock: String
	let distance: Double
}

struct NearbyTask: Identifiable {
	let id: Int
	let type: TaskType
	let address: String
	let distance: Double
	let estimatedDuration: Int  // in minutes
}

enum TaskType {
	case greenPoolInspection
	case larvicideFollowup
	case ditchInspection
	case canalInspection
	case serviceRequest

	var title: String {
		switch self {
		case .greenPoolInspection: return "Green Pool Inspection"
		case .larvicideFollowup: return "Larvicide Follow-up"
		case .ditchInspection: return "Ditch Inspection"
		case .canalInspection: return "Canal Inspection"
		case .serviceRequest: return "Service Request"
		}
	}

	var iconName: String {
		switch self {
		case .greenPoolInspection: return "drop.fill"
		case .larvicideFollowup: return "drop.triangle.fill"
		case .ditchInspection: return "water.waves"
		case .canalInspection: return "water.waves.and.arrow.down"
		case .serviceRequest: return "person.crop.circle.badge.exclamationmark"
		}
	}

	var color: Color {
		switch self {
		case .greenPoolInspection: return .green
		case .larvicideFollowup: return .blue
		case .ditchInspection: return .teal
		case .canalInspection: return .cyan
		case .serviceRequest: return .red
		}
	}
}

// MARK: - Task Details Sheet
struct TaskDetailsSheet: View {
	let task: NearbyTask
	let onAddToSchedule: () -> Void

	var body: some View {
		NavigationView {
			VStack(spacing: 20) {
				// Task icon and title
				HStack {
					Image(systemName: task.type.iconName)
						.font(.largeTitle)
						.foregroundColor(task.type.color)
						.padding()
						.background(task.type.color.opacity(0.2))
						.clipShape(Circle())

					Text(task.type.title)
						.font(.title2)
						.fontWeight(.semibold)
				}
				.padding(.top)

				// Task details
				VStack(alignment: .leading, spacing: 15) {
					detailRow(
						icon: "mappin.and.ellipse",
						title: "Address",
						value: task.address
					)

					detailRow(
						icon: "location.fill",
						title: "Distance",
						value:
							"\(String(format: "%.1f", task.distance)) miles away"
					)

					detailRow(
						icon: "clock.fill",
						title: "Estimated Duration",
						value: "\(task.estimatedDuration) minutes"
					)

					detailRow(
						icon: "calendar",
						title: "Suggested Time",
						value: "Add to next available slot"
					)
				}
				.padding()
				.background(Color(.systemGray6))
				.cornerRadius(12)
				.padding(.horizontal)

				Spacer()

				// Action buttons
				VStack(spacing: 12) {
					Button(action: onAddToSchedule) {
						Text("Add to Schedule")
							.fontWeight(.semibold)
							.frame(maxWidth: .infinity)
							.padding()
							.background(Color.blue)
							.foregroundColor(.white)
							.cornerRadius(12)
					}

					Button(action: {}) {
						Text("Navigate to Location")
							.fontWeight(.semibold)
							.frame(maxWidth: .infinity)
							.padding()
							.background(Color.secondary.opacity(0.1))
							.foregroundColor(.blue)
							.cornerRadius(12)
					}
				}
				.padding(.horizontal)
				.padding(.bottom)
			}
			.navigationTitle("Task Details")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Close") {
						onAddToSchedule()
					}
				}
			}
		}
	}

	private func detailRow(icon: String, title: String, value: String) -> some View {
		HStack(alignment: .top) {
			Image(systemName: icon)
				.frame(width: 30)
				.foregroundColor(.secondary)

			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.subheadline)
					.foregroundColor(.secondary)

				Text(value)
					.font(.body)
			}

			Spacer()
		}
	}
}

struct RouteAddView_Previews: PreviewProvider {
	static var previews: some View {
		RouteAddView()
	}
}
