import AppKit
import Foundation
import Speech

let data = SFCustomLanguageModelData(
	locale: Locale(identifier: "en-US"),
	identifier: "gleipnir.technology.apps.nidus",
	version: "0.1"
) {
	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aedes",
		phonemes: [
			"\"i d i z",  // British
			"e i d z",  // US short
			"\"e I d i z",  // US long
		]
	)

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "Aegypti",
		// IPA: /eɪˈdʒɪpti/
		// X-SAMPA: /ei"dZIpti/
		phonemes: [
			"i dZ I p t aI",  // British
			"e i d Z I p t i",  // US
		]
	)

	/*
    SFCustomLanguageModelData.PhraseCountsFromTemplates(classes: [
        "genus": ["Aedes", "Culex"],
        "species": ["Aegypti", "pipiens"],
        "verb": ["found", "seems", "is", "be"]
    ]) {
        SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template(
            "<verb> <genus> <species>",
            count: 10_000
        )
    }
    */

	SFCustomLanguageModelData.PhraseCount(phrase: "The species is Aedes Aegypti", count: 1000)
	SFCustomLanguageModelData.PhraseCount(phrase: "The genus is Aedes", count: 1000)
}
for phoneme in SFCustomLanguageModelData.supportedPhonemes(locale: Locale(identifier: "en-US"))
	.sorted()
{
	print(phoneme)
}
try await data.export(to: URL(filePath: "/tmp/NidusSpeechModel.bin"))
print("Wrote speech model to /tmp/NidusSpeechModel.bin\n")
