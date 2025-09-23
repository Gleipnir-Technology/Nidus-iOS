/// Functions for aggregating data
///
import Foundation
import OSLog
import SQLite

func BoundaryForNoteType(_ connection: SQLite.Connection, _ noteType: NoteType) throws -> Boundary {
	switch noteType {
	case .audio:
		// TODO:eliribble don't punt here
		return Boundary(minLat: -90, minLng: -180, maxLat: 90, maxLng: 180)
	case .mosquitoSource:
		let minLat: Double =
			try connection.scalar(
				schema.mosquitoSource.table.select(
					schema.mosquitoSource.latitude.min
				)
			) ?? -90.0
		let maxLat: Double =
			try connection.scalar(
				schema.mosquitoSource.table.select(
					schema.mosquitoSource.latitude.max
				)
			) ?? 90.0
		let minLng: Double =
			try connection.scalar(
				schema.mosquitoSource.table.select(
					schema.mosquitoSource.longitude.min
				)
			) ?? -180.0
		let maxLng: Double =
			try connection.scalar(
				schema.mosquitoSource.table.select(
					schema.mosquitoSource.longitude.max
				)
			) ?? 180.0
		return Boundary(minLat: minLat, minLng: minLng, maxLat: maxLat, maxLng: maxLng)

	case .picture:
		// TODO:eliribble don't punt here
		return Boundary(minLat: -90, minLng: -180, maxLat: 90, maxLng: 180)
	case .serviceRequest:
		let minLat: Double =
			try connection.scalar(
				schema.serviceRequest.table.select(
					schema.serviceRequest.latitude.min
				)
			) ?? -90.0
		let maxLat: Double =
			try connection.scalar(
				schema.serviceRequest.table.select(
					schema.serviceRequest.latitude.max
				)
			) ?? 90.0
		let minLng: Double =
			try connection.scalar(
				schema.serviceRequest.table.select(
					schema.serviceRequest.longitude.min
				)
			) ?? -180.0
		let maxLng: Double =
			try connection.scalar(
				schema.serviceRequest.table.select(
					schema.serviceRequest.longitude.max
				)
			) ?? 180.0
		return Boundary(minLat: minLat, minLng: minLng, maxLat: maxLat, maxLng: maxLng)

	}
}
