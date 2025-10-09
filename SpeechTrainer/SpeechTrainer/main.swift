import AppKit
import Foundation
import Speech

let data = SFCustomLanguageModelData(
	locale: Locale(identifier: "en_US"),
	identifier: "com.apple.SampleApp",
	version: "1.0"
) {
	SFCustomLanguageModelData.PhraseCount(
		phrase: "Play the Albin counter gambit",
		count: 10
	)
}

try await data.export(to: URL(filePath: "/var/tmp/SampleApp.bin"))
