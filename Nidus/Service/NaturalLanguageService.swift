import NaturalLanguage
import OSLog

struct LexToken {
	let range: Range<String.Index>
	let type: NLTag
}

func LexTranscript(_ text: String) -> [LexToken] {
	let dictionary: [String: [String]] = [
		"Noun": ["300"]
	]
	let tagger = NLTagger(tagSchemes: [.lexicalClass])
	tagger.string = text
	let options: NLTagger.Options = [.omitWhitespace]
	do {
		let gazetteer = try NLGazetteer(
			dictionary: dictionary,
			language: .english
		)
		tagger.setGazetteers([gazetteer], for: .lexicalClass)
	}
	catch {
		Logger.foreground.error("Failed to create gazetteer: \(error)")
	}
	var results = [LexToken]()
	tagger.enumerateTags(
		in: text.startIndex..<text.endIndex,
		unit: .word,
		scheme: .lexicalClass,
		options: options
	) {
		tag,
		tokenRange in
		guard let tag = tag else { return true }
		results.append(LexToken(range: tokenRange, type: tag))
		return true
	}

	return results
}
func tagTypeToString(_ tagType: NLTag) -> String {
	var typeName: String
	switch tagType {
	case NLTag.adjective:
		typeName = "Adjective"
	case NLTag.adverb:
		typeName = "Adverb"
	case NLTag.classifier:
		typeName = "Classifier"
	case NLTag.conjunction:
		typeName = "Conjunction"
	case NLTag.dash:
		typeName = "Dash"
	case NLTag.determiner:
		typeName = "Determiner"
	case NLTag.idiom:
		typeName = "Idiom"
	case NLTag.interjection:
		typeName = "Interjection"
	case NLTag.organizationName:
		typeName = "Organization Name"
	case NLTag.otherWord:
		typeName = "Other Word"
	case NLTag.otherPunctuation:
		typeName = "Other Punctuation"
	case NLTag.particle:
		typeName = "Particle"
	case NLTag.personalName:
		typeName = "Personal Name"
	case NLTag.placeName:
		typeName = "Place Name"
	case NLTag.preposition:
		typeName = "Preposition"
	case NLTag.pronoun:
		typeName = "Pronoun"
	case NLTag.noun:
		typeName = "Noun"
	case NLTag.number:
		typeName = "Number"
	case NLTag.sentenceTerminator:
		typeName = "Sentence Terminator"
	case NLTag.verb:
		typeName = "Verb"
	case NLTag.wordJoiner:
		typeName = "Word Joiner"
	default:
		typeName = "?"
	}
	return typeName
}
