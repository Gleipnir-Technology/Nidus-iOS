import NaturalLanguage
import OSLog

private let SOURCE_NOUNS: [String: SourceType] = ["gutter": .Flood]
private let LENGTH_ADJ: [String] = ["long"]
private let HEIGHT_ADJ: [String] = ["deep", "high"]
private let WIDTH_ADJ: [String] = ["wide"]
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

	var LemOrText: String {
		if lem.isEmpty {
			return text
		}
		else {
			return lem
		}
	}
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
	let sentences: [[Word]] = textToSentences(text)
	debugLogWords(sentences)
	for sentence in sentences {
		extractViaGrams(&result, sentence)
		extractViaPatterns(&result, sentence)
	}
	return result
}

private func addTranscriptionTag(
	_ transcript: inout [TranscriptTag],
	_ word: Word,
	_ type: TranscriptTagType
) {
	transcript.append(TranscriptTag(range: word.range, type: type))
}

private func debugLogWord(_ word: Word, _ i: Int) {
	if word.text.isEmpty {
		return
	}
	Logger.foreground.info(
		"\(i): \(word.text) | \(word.lem) | \(tagTypeToString(word.lex))"
	)
}
private func debugLogWords(_ sentences: [[Word]]) {
	var i = 0
	for sentence in sentences {
		for word in sentence {
			debugLogWord(word, i)
			i += 1
		}
		Logger.foreground.info("-sentence break-")
	}
}
private func extractCount(
	count: inout Int?,
	gram: Gram,
	transcript: inout [TranscriptTag],
) {
	addTranscriptionTag(&transcript, gram.At(0), .Measurement)
	for i in 1...3 {
		count = fromNumber(gram.At(-1 * i).text)
		if count != nil {
			addTranscriptionTag(&transcript, gram.At(-1 * i), .Measurement)
			return
		}
	}
}

private func extractViaGrams(
	_ result: inout KnowledgeGraph,
	_ words: [Word]
) {
	for (i, _) in words.enumerated() {
		let gram = Gram(offset: i, words: words)
		var word = gram.At(0).LemOrText
		switch word {
		case "aedes", "culex", "quinks":
			guard let genus = Genus.fromString(gram.At(0).text) else {
				Logger.foreground.info(
					"Mismatch in recognized genus. This indicates either the Genus.fromString function is broken, or the grams switch is malformed."
				)
				continue
			}
			result.breeding.genus = genus
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
		case "aegypti":
			guard let species = Species.fromString(gram.At(0).text) else {
				Logger.foreground.info(
					"Mismatch in recognized species. This indicates either the Species.fromString function is broken, or the grams switch is malformed."
				)
				continue
			}
			result.breeding.species = species
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
		case "blue", "maintain":
			result.breeding.conditions = .PoolMaintained
			addTranscriptionTag(&result.transcriptTags, gram.At(0), .Source)
		case "breed", "breeding":
			setWithMaybeNegate(
				gram: gram,
				tags: &result.transcriptTags,
				val: &result.breeding.isBreedingExplicit,
			)
		case "condition":
			maybeFindConditions(&result, gram)
		case "dip", "dips":
			extractCount(
				count: &result.fieldseeker.dipCount,
				gram: gram,
				transcript: &result.transcriptTags,
			)
		case "dimension":
			maybeMarkDimensions(&result, gram)
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
		case "pool":
			maybeMarkDimensions(&result, gram)
			// Check any conditions mentioned near "pool"
			for i in -2...3 {
				if let condition = BreedingConditions.fromString(
					gram.At(i).lem
				) {
					result.breeding.conditions = condition
					break
				}
			}
		case "pupa", "pupae", "tumbler":
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
			var number: Int? = nil
			number = fromNumber(gram.At(1).text)
			if number != nil && gram.At(2).lem == "and" {
				number = fromNumber(gram.At(3).text) ?? number
			}
			// Take 'all stages' to mean 'the highest stage'
			if gram.At(-1).lem == "all" {
				number = 4
			}
			guard let n = number else {
				continue
			}
			if let stage = LifeStage.fromInt(n) {
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

private func textToSentences(_ text: String) -> [[Word]] {
	let sentences: [Range<String.Index>] = text.split(separator: ".").map({
		$0.startIndex..<$0.endIndex
	})
	let lexTokens = LexTranscript(text, sentences)
	let lemTokens = LemTranscript(text, sentences)
	var utterances: [[Word]] = []
	for (i, _) in sentences.enumerated() {
		let current = lexTokens[i].map { t in
			let lem = findMatchingLem(lemTokens[i], t.range)
			// Sometime for certain utterances the NLP module can't tell a period is a sentence terminator
			// This often happens when the next "sentence" is a fragment.
			let w = String(text[t.range].lowercased()).replacing(".", with: "")
			return Word(
				lem: lem.value,
				lex: t.type,
				range: t.range,
				text: w,
			)
		}
		utterances.append(current)
	}
	return utterances
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

private func maybeFind(
	_ gram: Gram,
	_ lem: String,
	_ offset: Int,
) -> Int {
	for i in 0...5 {
		if gram.At(offset + i).lem == lem {
			return i + 1
		}
	}
	return -1
}

private func maybeFindAny(
	_ gram: Gram,
	_ lems: [String],
	_ offset: Int,
) -> Int {
	for i in 0...5 {
		let t = gram.At(offset + i).LemOrText
		if !lems.contains(t) {
			if i == 0 {
				return -1
			}
			return i
		}
	}
	return 5
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

private func maybeMarkDimensions(
	_ result: inout KnowledgeGraph,
	_ gram: Gram,
) {
	// Maybe skip over "pool is <...>" or "pool size is <...>"
	let used = maybeFindAny(gram, ["at", "be", "dimension", "pool", "size"], 0)
	if used == -1 {
		return
	}
	if let dimensions = maybeExtractVolume(
		&result.transcriptTags,
		gram,
		used
	) {
		result.source.volume = dimensions
	}
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

/// Extract a pattern that defines volume from the transcript by gram. There are several patterns supported:
/// *  L by W by D units
/// *  L unit dimension by W unit dimension by D unit dimension
private func maybeExtractVolume(_ transcript: inout [TranscriptTag], _ gram: Gram, _ offset: Int)
	-> Volume?
{
	for i in 0..<10 {
		debugLogWord(gram.At(i + offset), i + offset)
	}
	guard let dim1 = maybeExtractVolumeMeasurement(&transcript, gram, offset) else {
		return nil
	}
	let sep1 = maybeFindAny(gram, [",", "and", "by"], offset + dim1.used)
	if sep1 == -1 {
		return nil
	}
	guard let dim2 = maybeExtractVolumeMeasurement(&transcript, gram, offset + dim1.used + sep1)
	else {
		return nil
	}
	let sep2 = maybeFindAny(gram, [",", "and", "by"], offset + dim1.used + sep1 + dim2.used)
	if sep2 == -1 {
		return nil
	}
	guard
		let dim3 = maybeExtractVolumeMeasurement(
			&transcript,
			gram,
			offset + dim1.used + sep1 + dim2.used + sep2
		)
	else {
		return nil
	}
	for i in 0..<(dim1.used + dim2.used + dim3.used + 3) {
		addTranscriptionTag(&transcript, gram.At(offset + i), .Measurement)
	}
	do {
		return try volumeFromMeasurements([dim1, dim2, dim3])
	}
	catch {
		Logger.foreground.info("Ignoring malformed volume: \(error))")
		return nil
	}
	/*
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
     */
}

enum MeasurementError: Error {
	case notEnoughDimensions
	case unableToSort
}

private func volumeFromMeasurements(_ measurements: [ExtractedMeasurement]) throws -> Volume {
	if measurements.count < 3 {
		throw MeasurementError.notEnoughDimensions
	}
	var depthMeasurement: ExtractedMeasurement? = measurements.first(where: {
		$0.dimension == .Depth
	})
	var lengthMeasurement: ExtractedMeasurement? = measurements.first(where: {
		$0.dimension == .Length
	})
	var widthMeasurement: ExtractedMeasurement? = measurements.first(where: {
		$0.dimension == .Width
	})

	var unclaimedMeasurements: [ExtractedMeasurement] = measurements.filter {
		$0.dimension == nil
	}
	depthMeasurement = depthMeasurement ?? unclaimedMeasurements.popLast()
	widthMeasurement = widthMeasurement ?? unclaimedMeasurements.popLast()
	lengthMeasurement = lengthMeasurement ?? unclaimedMeasurements.popLast()

	if (depthMeasurement == nil || widthMeasurement == nil || lengthMeasurement == nil)
		|| !unclaimedMeasurements.isEmpty
	{
		throw MeasurementError.unableToSort
	}

	// If we don't have units on anything, assume feet (yay, America.)
	let unit: UnitLength =
		measurements[0].unit ?? measurements[1].unit ?? measurements[2].unit ?? .feet

	var depth: Measurement<UnitLength> = depthMeasurement!.toMeasurementLength(fallback: unit)
	var length: Measurement<UnitLength> = lengthMeasurement!.toMeasurementLength(fallback: unit)
	var width: Measurement<UnitLength> = widthMeasurement!.toMeasurementLength(fallback: unit)

	return Volume(depth: depth, length: length, width: width)
}
enum DimensionVolume {
	case Depth
	case Length
	case Width

	static func fromString(_ s: String) -> DimensionVolume? {
		switch s {
		case "depth", "deep":
			return .Depth
		case "length", "long":
			return .Length
		case "width", "wide":
			return .Width
		default:
			return nil
		}
	}
}
struct ExtractedMeasurement {
	var dimension: DimensionVolume?
	var unit: UnitLength?
	var used: Int
	var value: Double

	func toMeasurementLength(fallback: UnitLength) -> Measurement<UnitLength> {
		let unit = (self.unit ?? fallback)
		return Measurement(value: self.value, unit: unit)
	}
}
private func maybeExtractVolumeMeasurement(
	_ transcript: inout [TranscriptTag],
	_ gram: Gram,
	_ offset: Int
) -> ExtractedMeasurement? {
	guard let value = fromCardinal(gram.At(offset).text) else {
		return nil
	}
	var used = 1
	let unit = parseUnitLength(gram.At(offset + 1).text)
	if unit != nil {
		used = 2
	}
	let dimension = DimensionVolume.fromString(gram.At(offset + used).text)
	if dimension != nil {
		used = 3
	}
	return ExtractedMeasurement(
		dimension: dimension,
		unit: unit,
		used: used,
		value: Double(value),
	)
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
