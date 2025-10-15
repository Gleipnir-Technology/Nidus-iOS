import MapKit

struct SettingsStore {
	var lastSync: Date? = nil
	var password: String = ""
	var region: MKCoordinateRegion = Initial.region
	var URL: String = ""
	var username: String = ""
}
