import NaturalLanguage
import OSLog

struct LemToken {
	let range: Range<String.Index>
	let value: String
}

struct LexToken {
	let range: Range<String.Index>
	let type: NLTag
}

func LemTranscript(_ text: String, _ sentences: [Range<String.Index>]) -> [[LemToken]] {
	let tagger = NLTagger(tagSchemes: [.lemma])
	let options: NLTagger.Options = [.omitWhitespace]
	var results = [[LemToken]]()
	for sentence in sentences {
		tagger.string = text
		var current: [LemToken] = []
		tagger.enumerateTags(
			in: sentence,
			unit: .word,
			scheme: .lemma,
			options: options
		) {
			tag,
			tokenRange in
			guard let tag = tag else { return true }
			current.append(LemToken(range: tokenRange, value: tag.rawValue))
			return true

		}
		results.append(current)
	}
	return results
}
func LexTranscript(_ text: String, _ sentences: [Range<String.Index>]) -> [[LexToken]] {
	var results: [[LexToken]] = []
	let dictionary: [String: [String]] = [
		"Noun": ["300"]
	]
	let tagger = NLTagger(tagSchemes: [.lexicalClass])
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
	tagger.string = text
	for sentence in sentences {
		var current: [LexToken] = []
		tagger.enumerateTags(
			in: sentence,
			unit: .word,
			scheme: .lexicalClass,
			options: options
		) {
			tag,
			tokenRange in
			guard let tag = tag else { return true }
			current.append(LexToken(range: tokenRange, type: tag))
			return true
		}
		results.append(current)
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
	case NLTag.closeParenthesis:
		typeName = "Close Parenthesis"
	case NLTag.closeQuote:
		typeName = "Close Quote"
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
	case NLTag.openParenthesis:
		typeName = "Open Parenthesis"
	case NLTag.openQuote:
		typeName = "Open Quote"
	case NLTag.organizationName:
		typeName = "Organization Name"
	case NLTag.other:
		typeName = "Other"
	case NLTag.otherWord:
		typeName = "Other Word"
	case NLTag.otherPunctuation:
		typeName = "Other Punctuation"
	case NLTag.otherWhitespace:
		typeName = "Other Whitespace"
	case NLTag.paragraphBreak:
		typeName = "Paragraph Break"
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
	case NLTag.punctuation:
		typeName = "Punctuation"
	case NLTag.noun:
		typeName = "Noun"
	case NLTag.number:
		typeName = "Number"
	case NLTag.sentenceTerminator:
		typeName = "Sentence Terminator"
	case NLTag.verb:
		typeName = "Verb"
	case NLTag.whitespace:
		typeName = "Whitespace"
	case NLTag.word:
		typeName = "Word"
	case NLTag.wordJoiner:
		typeName = "Word Joiner"
	default:
		typeName = "?"
	}
	return typeName
}
