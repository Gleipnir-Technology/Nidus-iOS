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

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "larva",
		// IPA: /ˈlɑːr.və/
		// X-SAMPA: /"lA:.v@/
		phonemes: [
			"l A . v @"
		]
	)

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "larvae",
		// IPA: lärʹvē
		// X-SAMPA: l{r've:
		phonemes: [
			"l { r ' v e"
		]
	)

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "pupa",
		// IPA: /ˈpjuː.pə/
		// X-SAMPA: /"pju:p@/
		phonemes: [
			"p j u p a"
		]
	)

	SFCustomLanguageModelData.CustomPronunciation(
		grapheme: "pupae",
		// IPA: /ˈpjuː.piː/
		// X-SAMPA: /"pju:pi:/
		phonemes: [
			"p j u p i"
		]
	)

	SFCustomLanguageModelData.PhraseCountsFromTemplates(classes: [
		"thing": ["pupa", "pupae", "larva", "larvae", "dip", "dips"],
		"number": [
			"no", "zero", "one", "two", "three", "four", "five", "six", "seven",
			"eight", "nine",
			"ten",
		],
	]) {
		SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template(
			"<number> <thing>",
			count: 1_000
		)
	}

	SFCustomLanguageModelData.PhraseCountsFromTemplates(classes: [
		"thing": ["pupa", "pupae", "larva", "larvae", "dip", "dips"],
		"number": Array(10...100).map({ String($0) }),
	]) {
		SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template(
			"<number> <thing>",
			count: 1_000
		)
	}

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
