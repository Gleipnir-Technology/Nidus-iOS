import MapKit

struct NoteMapAnnotation: Identifiable {
	let coordinate: CLLocationCoordinate2D
	let icon: String
	let id: UUID = UUID()
	let text: String
}
