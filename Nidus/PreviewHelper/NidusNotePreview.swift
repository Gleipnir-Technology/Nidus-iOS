//
//  NidusNotePreview.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/4/25.
//

extension NidusNote {
	static var previewListShort: [NidusNote] = [
		NidusNote(
			audioRecordings: [],
			images: [],
			location: Location(
				latitude: Location.visalia.latitude + 0.001,
				longitude: Location.visalia.longitude + 0.002
			),
			text: "some note 1"
		),
		NidusNote(
			audioRecordings: [],
			images: [],
			location: Location(
				latitude: Location.visalia.latitude - 0.003,
				longitude: Location.visalia.longitude + 0.001
			),
			text: "some note 2"
		),
	]
}
