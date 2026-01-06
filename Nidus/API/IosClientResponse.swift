import Foundation

final class IosClientResponse: Codable {
	enum CodingKeys: CodingKey {
		case fieldseeker
		case since
	}

	let fieldseeker: FieldseekerResponse
	let since: Date

	init(fieldseeker: FieldseekerResponse, since: Date) {
		self.fieldseeker = fieldseeker
		self.since = since
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.fieldseeker = try container.decode(
			FieldseekerResponse.self,
			forKey: .fieldseeker
		)
		self.since = try container.decode(Date.self, forKey: .since)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(fieldseeker, forKey: .fieldseeker)
		try container.encode(since, forKey: .since)
	}
}
