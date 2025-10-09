import AppKit
import Foundation
import Speech

let data = SFCustomLanguageModelData(
	locale: Locale(identifier: "en_US"),
	identifier: "gleipnir.technology.Nidus",
	version: "0.1"
) {
	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aedes",
		// IPA phonemes: ["/ˈiːdiːz/","/eɪdz/"]
		phonemes: ["/ejdz/", "/\"i:diz/", "/\"eIdi:z/"]
	)

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aegypti",
		phonemes: ["/ei\"dZIp.ti/"]
	)
	SFCustomLanguageModelData.PhraseCount(
		phrase: "The species is Aedes Aegypti",
		count: 10
	)
	SFCustomLanguageModelData.PhraseCount(
		phrase: "The species appears to be Aedes Aegypti",
		count: 10
	)
	SFCustomLanguageModelData.PhraseCount(
		phrase: "The species appears seems to be Aedes Aegypti",
		count: 10
	)
}

try await data.export(to: URL(filePath: "/tmp/NidusSpeechModel.bin"))
print("Wrote speech model to /tmp/NidusSpeechModel.bin\n")
