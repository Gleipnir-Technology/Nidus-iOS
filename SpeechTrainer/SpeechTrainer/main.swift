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
		phonemes: ["\" i: d i: z"]  // British
	)
	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aedes",
		phonemes: ["e I d z"]  // US short
	)
	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aedes",
		phonemes: ["\" e I d i: z"]  // US full
	)

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aegypti",
		phonemes: ["i\"@ dZ @p taI"]  // US
	)

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aegypti",
		phonemes: ["i:\" dZ I p taI"]  // British
	)

	SFCustomLanguageModelData.PhraseCount(
		phrase: "The species is Aedes Aegypti",
		count: 5_000
	)
	SFCustomLanguageModelData.PhraseCount(
		phrase: "The species appears to be Aedes Aegypti",
		count: 5_000
	)
	SFCustomLanguageModelData.PhraseCount(
		phrase: "The species seems to be Aedes Aegypti",
		count: 5_000
	)
}

try await data.export(to: URL(filePath: "/tmp/NidusSpeechModel.bin"))
print("Wrote speech model to /tmp/NidusSpeechModel.bin\n")
