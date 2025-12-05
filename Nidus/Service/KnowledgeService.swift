import NaturalLanguage
import OSLog

private let SOURCE_NOUNS: [String: SourceType] = ["gutter": .Flood]
private let LENGTH_ADJ: [String] = ["long"]
private let HEIGHT_ADJ: [String] = ["deep", "high"]
private let WIDTH_ADJ: [String] = ["wide"]
private let BREEDING_NOUNS: [String] = ["instar"]
private let GENUS_NOUNS: [String: Genus] = [
	"aedes": .Aedes,
	"aegypti": .Aegypti,
	"culex": .Culex,
	"quinks": .Quinks,
]
private let FACILITATOR_ROOT_CAUSE_VERBS: [String] = ["blocking"]
private let FACILITATOR_ACTION_VERBS: [String] = ["removed"]
private let ROOT_CAUSE_ADJ: [String] = ["root"]

private let EMPTY_LEM: LemToken = LemToken(range: EMPTY_RANGE, value: "")
private let EMPTY_RANGE: Range<String.Index> = "".startIndex..<"".endIndex
private let EMPTY_WORD: Word = Word(lem: "", lex: .other, range: EMPTY_RANGE, text: "")

struct Word {
	let lem: String
	let lex: NLTag
	let range: Range<String.Index>
	let text: String
}

struct Gram {
	let offset: Int
	let words: [Word]

	func At(_ relative: Int) -> Word {
		let index: Int = offset + relative
		if index < 0 || index >= words.count {
			return EMPTY_WORD
		}
		return words[index]
	}
}

func ExtractKnowledge(_ text: String) -> KnowledgeGraph {

	// For debugging
	/*
	 Logger.foreground.info("Lex tokens")
	 for token in lexTokens {
	 Logger.foreground.info(
	 "\(text[token.range]) | \(tagTypeToString(token.type))"
	 )
	 }
	 */

	var result = KnowledgeGraph(
		adultProduction: AdultProductionKnowledgeGraph(),
		breeding: BreedingKnowledgeGraph(),
		driver: DriverKnowledgeGraph(),
		facilitator: FacilitatorKnowledgeGraph(),
		fieldseeker: FieldseekerReportGraph(),
		rootCause: RootCauseKnowledgeGraph(),
		source: SourceKnowledgeGraph(volume: Volume()),
		transcriptTags: []
	)
	let words: [Word] = textToWords(text)
	debugLogWords(words)
	extractViaGrams(&result, words)
	extractViaPatterns(&result, words)
	return result
}

private func debugLogWord(_ word: Word, _ i: Int) {
	Logger.foreground.info(
		"\(i): \(word.text) | \(word.lem) | \(tagTypeToString(word.lex))"
	)
}
private func debugLogWords(_ words: [Word]) {
	for (i, word) in words.enumerated() {
		debugLogWord(word, i)
	}
}
private func extractCount(
	count: inout Int?,
	gram: Gram,
	transcript: inout [TranscriptTag],
) {
	addTranscriptionTag(&transcript, gram.At(0), .Measurement)
	count = fromNumber(gram.At(-1).text)
	if count != nil {
		addTranscriptionTag(&transcript, gram.At(-1), .Measurement)
	}
}

private func extractViaGrams(
	_ result: inout KnowledgeGraph,
	_ words: [Word]
) {
	for (i, _) in words.enumerated() {
		let gram = Gram(offset: i, words: words)
		debugLogWord(gram.At(-2), -2)
		debugLogWord(gram.At(-1), -1)
		debugLogWord(gram.At(0), 0)
		debugLogWord(gram.At(1), 1)
		debugLogWord(gram.At(2), 2)
		switch gram.At(0).lem {
		case "aedes", "aegypti", "culex", "quinks":
			guard let genus = Genus.fromString(gram.At(0).text) else {
				Logger.foreground.info(
					"Mismatch in recognized genus. This indicates either the Genus.fromString function is broken, or the grams switch is malformed."
				)
				continue
			}
			result.breeding.genus = genus
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
		case "breed":
			setWithMaybeNegate(
				gram: gram,
				tags: &result.transcriptTags,
				val: &result.breeding.isBreeding,
			)
		case "conditions":
			maybeFindConditions(&result, gram)
		case "dip":
			extractCount(
				count: &result.fieldseeker.dipCount,
				gram: gram,
				transcript: &result.transcriptTags,
			)
		case "dimension":
			if gram.At(1).lem != "be" {
				continue
			}
			guard let dimensions = maybeExtractVolume(&result.transcriptTags, gram, 2)
			else {
				continue
			}
			result.source.volume = dimensions
		case "egg":
			extractCount(
				count: &result.breeding.eggQuantity,
				gram: gram,
				transcript: &result.transcriptTags,
			)
		case "fish":
			setWithMaybeNegate(
				gram: gram,
				tags: &result.transcriptTags,
				val: &result.source.hasFish,
			)
		case "green":
			result.breeding.conditions = .PoolGreen
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
		case "inspection":
			result.fieldseeker.reportType = .Inspection
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
		case "instar":
			guard let o = fromOrdinal(gram.At(-1).text) else {
				continue
			}
			guard let stage = LifeStage.fromInt(o) else {
				continue
			}
			result.breeding.stage = stage
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
			addTranscriptionTag(&result.transcriptTags, gram.At(1), .Source)
		case "larva":
			extractCount(
				count: &result.breeding.larvaeQuantity,
				gram: gram,
				transcript: &result.transcriptTags,
			)
		case "pupa":
			extractCount(
				count: &result.breeding.pupaeQuantity,
				gram: gram,
				transcript: &result.transcriptTags,
			)
		case "source":
			if result.fieldseeker.reportType != nil {
				Logger.foreground.info("Ignoring later report type tag 'source'")
				continue
			}
			result.fieldseeker.reportType = FieldseekerReportType.MosquitoSource
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
		case "stage":
			guard let val = fromNumber(gram.At(1).text) else {
				continue
			}
			if let stage = LifeStage.fromInt(val) {
				result.breeding.stage = stage
				addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
				addTranscriptionTag(&result.transcriptTags, gram.At(1), .Source)
			}
		default:
			continue
		}
	}
}

func extractViaPatterns(
	_ result: inout KnowledgeGraph,
	_ words: [Word]
) {
}

private func setWithMaybeNegate(gram: Gram, tags: inout [TranscriptTag], val: inout Bool?) {
	if gram.At(-1).lem == "no" {
		val = false
		addTranscriptionTag(&tags, gram.At(-1), .Source)
	}
	else {
		val = true
	}
	addTranscriptionTag(&tags, gram.At(0), .Source)
}
/*
 private func tokensToWords(_ tokens: [LexToken], _ text: String) -> [Word] {
 return tokens.map { t in
 var range = t.range
 let lastCharIndex = t.range.upperBound
 if lastCharIndex > range.lowerBound,
 let prevIndex = text.index(
 t.range.upperBound,
 offsetBy: -1,
 limitedBy: text.startIndex
 ),
 text[prevIndex] == "."
 {
 range = range.lowerBound..<prevIndex
 }
 return String(text[range]).lowercased()
 }
 }
 */

private func textToWords(_ text: String) -> [Word] {
	let lexTokens = LexTranscript(text)
	let lemTokens = LemTranscript(text)
	return lexTokens.map { t in
		let lem = findMatchingLem(lemTokens, t.range)
		return Word(
			lem: lem.value,
			lex: t.type,
			range: t.range,
			text: String(text[t.range]),
		)
	}
}
private func isOrdinal(_ w: Word) -> Bool {
	let o = fromOrdinal(w.text)
	if o == nil {
		return false
	}
	return true
}

private func maybeFindConditions(
	_ result: inout KnowledgeGraph,
	_ gram: Gram,
) {
	for offset in -5...5 {
		for condition in BreedingConditions.all {
			if maybeMarkCondition(&result, gram, offset, condition) {
				return
			}

		}
	}
}

private func maybeMarkCondition(
	_ result: inout KnowledgeGraph,
	_ gram: Gram,
	_ offset: Int,
	_ condition: BreedingConditions
) -> Bool {
	let description = condition.description
	let words = description.components(separatedBy: .whitespaces).map { w in
		w.lowercased()
	}
	for (i, w) in words.enumerated() {
		if gram.At(offset + i).text != w {
			return false
		}

	}
	result.breeding.conditions = condition
	for (i, _) in words.enumerated() {
		addTranscriptionTag(&result.transcriptTags, gram.At(offset + i), .Source)
	}
	return true
}

private func addTranscriptionTag(
	_ transcript: inout [TranscriptTag],
	_ word: Word,
	_ type: TranscriptTagType
) {
	transcript.append(TranscriptTag(range: word.range, type: type))
}

private func extractBreedingGraph(
	_ text: String,
	_ tokens: [LexToken],
	_ transcriptTags: inout [TranscriptTag]
)
	-> BreedingKnowledgeGraph
{
	var genus: Genus?
	var stage: LifeStage?
	for (i, token) in tokens.enumerated() {
		if token.type == NLTag.noun {
			let word = text[token.range].lowercased()
			for noun in BREEDING_NOUNS {
				if noun == word {
					let adj = tokens[i - 1]
					let adjWord = text[adj.range]
					stage = parseLifeStage(String(adjWord))
					if stage != nil {
						transcriptTags.append(
							TranscriptTag(
								range: token.range,
								type: .Source
							)
						)
					}
				}
			}
			if genus == nil {
				genus = GENUS_NOUNS[word]
			}
		}
	}
	return BreedingKnowledgeGraph(
		genus: genus,
		stage: stage,
		treatment: nil
	)
}

private func extractFacilitator(
	_ text: String,
	_ tokens: [LexToken],
	_ transcriptTags: inout [TranscriptTag]
) -> FacilitatorKnowledgeGraph {
	var blocking: String?
	for token in tokens {
		if token.type == NLTag.verb {
			let word = text[token.range]
			for verb in FACILITATOR_ACTION_VERBS {
				if word == verb {
					blocking = verb
					transcriptTags.append(
						TranscriptTag(range: token.range, type: .Action)
					)
				}
			}
		}
	}
	return FacilitatorKnowledgeGraph(
		blocking: blocking,
		pathToRootCause: nil,
		pathToSource: nil
	)
}

private func extractRootCause(
	_ text: String,
	_ tokens: [LexToken],
	_ transcriptTags: inout [TranscriptTag]
) -> RootCauseKnowledgeGraph {
	var fix: String?
	for token in tokens {
		if token.type == NLTag.adjective {
			let word = text[token.range]
			for noun in ROOT_CAUSE_ADJ {
				if word == noun {
					fix = noun
					transcriptTags.append(
						TranscriptTag(range: token.range, type: .Source)
					)
				}
			}
		}
	}
	return RootCauseKnowledgeGraph(
		fix: fix,
		legalAbatement: nil
	)
}

private func findMatchingLem(_ lemTokens: [LemToken], _ range: Range<String.Index>) -> LemToken {
	for token in lemTokens {
		if token.range.lowerBound >= range.lowerBound,
			token.range.upperBound <= range.upperBound
		{
			return token
		}
	}
	return EMPTY_LEM
}

private func fromCardinal(
	_ s: String
) -> Int? {
	let result = Int(s)
	if result != nil {
		return result
	}
	switch s {
	case "no", "nil", "zero", "zilch":
		return 0
	case "one":
		return 1
	case "two":
		return 2
	case "three":
		return 3
	case "four":
		return 4
	case "five":
		return 5
	case "six":
		return 6
	case "seven":
		return 7
	case "eight":
		return 8
	case "nine":
		return 9
	case "ten":
		return 10
	case "twenty":
		return 20
	case "thirty":
		return 30
	case "forty":
		return 40
	case "fifty":
		return 50
	case "sixty":
		return 60
	case "seventy":
		return 70
	case "eighty":
		return 80
	case "ninety":
		return 90
	default:
		return nil
	}
}
func fromNumber(_ s: String) -> Int? {
	if let result = fromCardinal(s) {
		return result
	}
	if let result = fromOrdinal(s) {
		return result
	}
	return nil
}
func fromOrdinal(_ s: String) -> Int? {
	let lowercased = s.lowercased()
	let ORDINAL_TO_VALUE: [String: Int] = [
		"1st": 1,
		"first": 1,
		"2nd": 2,
		"second": 2,
		"3rd": 3,
		"third": 3,
		"4th": 4,
		"fourth": 4,
		"5th": 5,
		"fifth": 5,
		"6th": 6,
		"sixth": 6,
		"7th": 7,
		"seventh": 7,
		"8th": 8,
		"eighth": 8,
		"9th": 9,
		"ninth": 9,
		"10th": 10,
		"tenth": 10,
	]
	return ORDINAL_TO_VALUE[lowercased] ?? nil
}

private func parseLifeStage(_ adjective: String) -> LifeStage? {
	switch adjective {
	case "1st", "first":
		return .FirstInstar
	case "2nd", "second":
		return .SecondInstar
	case "3rd", "third":
		return .ThirdInstar
	default:
		return nil
	}
}

let DIP_SEARCH_SPACE: Int = 5
private func extractDipCount(
	index: Int,
	text: String,
	tokens: [LexToken],
	transcriptTags: inout [TranscriptTag]
) -> Int? {
	let start = max(0, index - DIP_SEARCH_SPACE)
	let end = min(tokens.count, index + DIP_SEARCH_SPACE)
	for i in stride(from: start, through: end, by: 1) {
		let token = tokens[i]
		if token.type == NLTag.number {
			let word = text[token.range]
			let result = Int(word)
			transcriptTags.append(
				TranscriptTag(
					range: token.range,
					type: .Measurement
				)
			)
			return result
		}
	}
	return nil
}

private func extractSourceType(
	text: String,
	tokens: [LexToken],
	transcriptTags: inout [TranscriptTag]
) -> SourceType? {
	for token in tokens {
		if token.type == NLTag.noun {
			// Check for our source indicator
			let word = text[token.range]
			for (noun, sourceType) in SOURCE_NOUNS {
				if word == noun {
					transcriptTags.append(
						TranscriptTag(range: token.range, type: .Source)
					)
					return sourceType
				}
			}
		}
	}
	return nil
}

private func maybeExtractVolume(_ transcript: inout [TranscriptTag], _ gram: Gram, _ offset: Int)
	-> Volume?
{
	if !(gram.At(offset).lex == .number && gram.At(offset + 1).lem == "by"
		&& gram.At(offset + 2).lex == .number && gram.At(offset + 3).lem == "by"
		&& gram.At(offset + 4).lex == .number)
	{
		return nil
	}
	guard let length = fromCardinal(gram.At(offset).text) else {
		return nil
	}
	guard let width = fromCardinal(gram.At(offset + 2).text) else {
		return nil
	}
	guard let depth = fromCardinal(gram.At(offset + 4).text) else {
		return nil
	}
	addTranscriptionTag(&transcript, gram.At(0), .Measurement)
	addTranscriptionTag(&transcript, gram.At(1), .Measurement)
	addTranscriptionTag(&transcript, gram.At(2), .Measurement)
	addTranscriptionTag(&transcript, gram.At(3), .Measurement)
	addTranscriptionTag(&transcript, gram.At(4), .Measurement)
	var unit = parseUnitLength(gram.At(offset + 5).text)
	if unit != nil {
		addTranscriptionTag(&transcript, gram.At(5), .Measurement)
	}
	else {
		unit = UnitLength.feet
	}
	let l: Measurement<UnitLength> = .init(value: Double(length), unit: unit!)
	let w: Measurement<UnitLength> = .init(value: Double(width), unit: unit!)
	let d: Measurement<UnitLength> = .init(value: Double(depth), unit: unit!)
	return Volume(depth: d, length: l, width: w)
}

private func parseUnitLength(_ unitString: String) -> UnitLength? {
	switch unitString {
	case "feet":
		return .feet
	case "inches":
		return .inches
	case "meters":
		return .meters
	default:
		Logger.foreground.info("Failed to parse \(unitString) as a UnitLength")
		return nil
	}
}
