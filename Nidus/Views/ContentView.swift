//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//
import Combine
import MapKit
import OSLog
import SwiftData
import SwiftUI

struct ContentView: View {
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State var currentValue: Float = 0.0
	@State private var path = NavigationPath()
	@State private var selection: Int = 0
	@State private var position: MapCameraPosition = .camera(
		.init(centerCoordinate: MKCoordinateRegion.visalia.center, distance: 1_000)
	)

	var db: Database

	func onNoteSelected(_ note: any Note) {
		path.append(note.id)
	}
	func onMapPositionChange(_ region: MKCoordinateRegion) {
		let minX = region.center.longitude - region.span.longitudeDelta / 2
		let minY = region.center.latitude - region.span.latitudeDelta / 2
		let maxX = region.center.longitude + region.span.longitudeDelta / 2
		let maxY = region.center.latitude + region.span.latitudeDelta / 2
		db.setPosition(minX, minY, maxX, maxY)
	}
	func setTabNotes() {
		selection = 0
	}
	func triggerBackgroundFetch() {
		Task {
			let actor = BackgroundModelActor()
			do {
				try await actor.triggerFetch(db)
			}
			catch {
				Logger.background.error(
					"Failed to trigger fetch \(error.localizedDescription)"
				)
			}
		}
	}
	var body: some View {
		NavigationStack(path: $path) {
			TabView(selection: $selection) {
				Tab("Notes", systemImage: "clock", value: 0) {
					NoteListView(
						currentLocation: nil,
						notes: db.notesToShow
					)
				}
				Tab("Map", systemImage: "map", value: 1) {
					MapOverview(
						dataSource: db.cluster,
						onNoteSelected: onNoteSelected,
						onPositionChange: onMapPositionChange,
						userLocation: locationDataManager.location
					)
				}
				Tab("Settings", systemImage: "gear", value: 3) {
					SettingView(onSettingsUpdated: triggerBackgroundFetch)
				}
			}
			.navigationDestination(for: UUID.self) { noteId in
				if let note = db.notesToShow.first(where: { $0.id == noteId }) {
					NoteEditor(
						currentLocation: locationDataManager.location,
						note: note
					)
				}
				else {
					Text("NOAAAAA")
				}
			}
		}.onAppear {
			triggerBackgroundFetch()
		}
	}
}
