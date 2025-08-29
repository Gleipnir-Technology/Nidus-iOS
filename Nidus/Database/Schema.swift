import OSLog
import SQLite
import SwiftUI

struct DBSchema {
	let audioRecording = AudioRecordingTable()
	let audioRecordingLocation = AudioRecordingLocationTable()
	let inspection = InspectionTable()
	let mosquitoSource = MosquitoSourceTable()
	let picture = PictureTable()
	let serviceRequest = ServiceRequestTable()
	let treatment = TreatmentTable()
}
var schema = DBSchema()

class AudioRecordingTable {
	let table = Table("audio_recording")

	let created = SQLite.Expression<Date>("created")
	let deleted = SQLite.Expression<Date?>("deleted")
	let duration = SQLite.Expression<TimeInterval>("duration")
	let transcription = SQLite.Expression<String?>("transcription")
	let transcriptionUserEdited = SQLite.Expression<Bool>("transcription_user_edited")
	let uploaded = SQLite.Expression<Date?>("uploaded")
	let uuid = SQLite.Expression<UUID>("uuid")
	let version = SQLite.Expression<Int>("version")
}

class AudioRecordingLocationTable {
	let table = Table("audio_recording_location")

	let audioRecordingUUID = SQLite.Expression<UUID>("audio_recording_uuid")
	let cell = SQLite.Expression<UInt64>("cell")
	let created = SQLite.Expression<Date>("created")
	let index = SQLite.Expression<Int>("index")
}

class InspectionTable {
	let table = Table("inspection")

	let comments = SQLite.Expression<String>("comments")
	let condition = SQLite.Expression<String>("condition")
	let created = SQLite.Expression<Date>("created")
	let fieldTechnician = SQLite.Expression<String>("field_technician")
	let id = SQLite.Expression<UUID>("id")
	let sourceID = SQLite.Expression<UUID>("source_id")

}

class MosquitoSourceTable {
	let table = Table("mosquito_source")

	let access = SQLite.Expression<String>("access")
	let active = SQLite.Expression<Bool?>("active")
	let comments = SQLite.Expression<String>("comments")
	let created = SQLite.Expression<Date>("created")
	let description = SQLite.Expression<String>("description")
	let habitat = SQLite.Expression<String>("habitat")
	let id = SQLite.Expression<UUID>("id")
	let lastInspectionDate = SQLite.Expression<Date>("last_inspection_date")
	let name = SQLite.Expression<String>("name")
	let nextActionDateScheduled = SQLite.Expression<Date>("next_action_date_scheduled")
	let useType = SQLite.Expression<String>("use_type")
	let waterOrigin = SQLite.Expression<String>("water_origin")
	let zone = SQLite.Expression<String>("zone")
	let latitude = SQLite.Expression<Double>("latitude")
	let longitude = SQLite.Expression<Double>("longitude")

}

class PictureTable {
	let table = Table("picture")

	let created = SQLite.Expression<Date>("created")
	let deleted = SQLite.Expression<Date?>("deleted")
	let location = SQLite.Expression<UInt64?>("location")
	let uploaded = SQLite.Expression<Date?>("uploaded")
	let uuid = SQLite.Expression<UUID>("uuid")
}

class ServiceRequestTable {
	let table = Table("service_request")

	let address = SQLite.Expression<String>("address")
	let assignedTechnician = SQLite.Expression<String>("assigned_technician")
	let city = SQLite.Expression<String>("city")
	let created = SQLite.Expression<Date>("created")
	let hasDog = SQLite.Expression<Bool?>("has_dog")
	let hasSpanishSpeaker = SQLite.Expression<Bool?>("has_spanish_speaker")
	let id = SQLite.Expression<UUID>("id")
	let priority = SQLite.Expression<String>("priority")
	let source = SQLite.Expression<String>("source")
	let status = SQLite.Expression<String>("status")
	let target = SQLite.Expression<String>("target")
	let zip = SQLite.Expression<String>("zip")
	let latitude = SQLite.Expression<Double>("latitude")
	let longitude = SQLite.Expression<Double>("longitude")

}

class TreatmentTable {
	let table = Table("treatment")

	let comments = SQLite.Expression<String>("comments")
	let created = SQLite.Expression<Date>("created")
	let fieldTechnician = SQLite.Expression<String>("field_technician")
	let habitat = SQLite.Expression<String>("habitat")
	let id = SQLite.Expression<UUID>("id")
	let product = SQLite.Expression<String>("product")
	let quantity = SQLite.Expression<Double>("quantity")
	let quantityUnit = SQLite.Expression<String>("quantity_unit")
	let siteCondition = SQLite.Expression<String>("site_condition")
	let sourceID = SQLite.Expression<UUID>("source_id")
	let treatAcres = SQLite.Expression<Double>("treat_acres")
	let treatHectares = SQLite.Expression<Double>("treat_hectares")

}
