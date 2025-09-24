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

func ExtractKnowledge(_ text: String) -> KnowledgeGraph {
	let tokens = LexTranscript(text)

	// For debugging
	for token in tokens {
		Logger.foreground.info(
			"\(text[token.range]) | \(tagTypeToString(token.type))"
		)
	}

	var result = KnowledgeGraph(
		adultProduction: AdultProductionKnowledgeGraph(),
		breeding: BreedingKnowledgeGraph(),
		driver: DriverKnowledgeGraph(),
		facilitator: FacilitatorKnowledgeGraph(),
		rootCause: RootCauseKnowledgeGraph(),
		source: SourceKnowledgeGraph(),
		transcriptTags: []
	)
	// Hacky, just for a demo
	for (i, token) in tokens.enumerated() {
		if i < 5 { continue }
		let tokens: [LexToken] = Array(tokens[i - 2..<i + 1])
		let words: [String] = tokens.map { t in
			String(text[t.range]).lowercased()
		}
		if words[1] == "flooded" && words[2] == "gutter" {
			result.source.type = .Flood
			addTranscriptionTag(&result, tokens[1], .Source)
			addTranscriptionTag(&result, tokens[2], .Source)
		}
		else if words[2] == "wide" {
			result.source.volume =
				result.source.volume
				?? Volume(
					depth: nil,
					length: nil,
					width: nil
				)
			result.source.volume!.width = getMeasurement(words[0], words[1])
			addTranscriptionTag(&result, tokens[0], .Measurement)
			addTranscriptionTag(&result, tokens[1], .Measurement)
		}
		else if words[2] == "long" {
			result.source.volume =
				result.source.volume
				?? Volume(
					depth: nil,
					length: nil,
					width: nil
				)
			result.source.volume!.length = getMeasurement(words[0], words[1])
			addTranscriptionTag(&result, tokens[0], .Measurement)
			addTranscriptionTag(&result, tokens[1], .Measurement)
		}
		else if words[2] == "deep" {
			result.source.volume =
				result.source.volume
				?? Volume(
					depth: nil,
					length: nil,
					width: nil
				)
			result.source.volume!.depth = getMeasurement(words[0], words[1])
			addTranscriptionTag(&result, tokens[0], .Measurement)
			addTranscriptionTag(&result, tokens[1], .Measurement)
		}
		else if words[2] == "larvae" {
			result.breeding.stage = .ThirdInstar
			addTranscriptionTag(&result, tokens[0], .Source)
			addTranscriptionTag(&result, tokens[1], .Source)
			addTranscriptionTag(&result, tokens[2], .Source)
		}
		else if words[2] == "dip" {
			result.breeding.quantity = Int(words[0])
			addTranscriptionTag(&result, tokens[2], .Source)
		}
		else if words[2] == "culex" {
			result.breeding.genus = .Culex
			addTranscriptionTag(&result, tokens[2], .Source)
		}
		else if words[2] == "blocking" {
			result.facilitator.blocking = words[2]
			addTranscriptionTag(&result, tokens[2], .Source)
		}
		else if words[2] == "drain" {
			result.facilitator.pathToRootCause = words[2]
			addTranscriptionTag(&result, tokens[2], .Source)
		}
		else if words[2] == "removed" {
			result.facilitator.pathToSource = words[2]
			addTranscriptionTag(&result, tokens[2], .Action)
		}
		else if words[2] == "treated" {
			result.breeding.treatment = .SumilarvWSP
			addTranscriptionTag(&result, tokens[2], .Action)
		}
		else if words[2] == "wsp" {
			addTranscriptionTag(&result, tokens[1], .Action)
			addTranscriptionTag(&result, tokens[2], .Action)
		}
		else if words[2] == "cause" {
			result.rootCause.legalAbatement = words[2]
			addTranscriptionTag(&result, tokens[2], .Source)
		}
	}

	return result
}

private func addTranscriptionTag(
	_ result: inout KnowledgeGraph,
	_ token: LexToken,
	_ type: TranscriptTagType
) {
	result.transcriptTags.append(TranscriptTag(range: token.range, type: type))
}

private func getMeasurement(_ valueString: String, _ unitString: String) -> Measurement<UnitLength>?
{
	guard let value = parseMeasurementValue(valueString) else {
		Logger.foreground.info("Couldn't parse \(valueString) as a Double")
		return nil
	}
	guard let unitLength = parseUnitLength(unitString) else {
		Logger.foreground.info("Couldn't parse \(unitString) as a UnitLength")
		return nil
	}
	return Measurement(value: value, unit: unitLength)
}

private func extractBreedingGraph(
	_ text: String,
	_ tokens: [LexToken],
	_ transcriptTags: inout [TranscriptTag]
)
	-> BreedingKnowledgeGraph
{
	var genus: Genus?
	var quantity: Int?
	var stage: LifeStage?
	var treatment: TreatmentType?
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
			if word == "dip" {
				quantity = extractDipCount(
					index: i,
					text: text,
					tokens: tokens,
					transcriptTags: &transcriptTags
				)
				transcriptTags.append(
					TranscriptTag(range: token.range, type: .Source)
				)
			}
			if genus == nil {
				genus = GENUS_NOUNS[word]
			}
		}
	}
	return BreedingKnowledgeGraph(
		genus: genus,
		quantity: quantity,
		stage: stage,
		treatment: treatment
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
		conditions: nil,
		fix: fix,
		legalAbatement: nil
	)
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

private func extractSourceGraph(
	_ text: String,
	_ tokens: [LexToken],
	_ transcriptTags: inout [TranscriptTag]
)
	-> SourceKnowledgeGraph
{
	// get the source
	let sourceType: SourceType? = extractSourceType(
		text: text,
		tokens: tokens,
		transcriptTags: &transcriptTags
	)
	// Check for measurements
	let length = extractMeasurement(
		text: text,
		tokens: tokens,
		transcriptTags: &transcriptTags,
		adjectives: LENGTH_ADJ
	)
	let depth = extractMeasurement(
		text: text,
		tokens: tokens,
		transcriptTags: &transcriptTags,
		adjectives: HEIGHT_ADJ
	)
	let width = extractMeasurement(
		text: text,
		tokens: tokens,
		transcriptTags: &transcriptTags,
		adjectives: WIDTH_ADJ
	)

	var volume: Volume?
	if length != nil && depth != nil && width != nil {
		volume = Volume(depth: depth!, length: length!, width: width!)
	}
	return SourceKnowledgeGraph(
		preemptiveTreatment: nil,
		productionCapacity: nil,
		sourceElimination: nil,
		type: sourceType,
		volume: volume
	)
}

private func extractMeasurement(
	text: String,
	tokens: [LexToken],
	transcriptTags: inout [TranscriptTag],
	adjectives: [String]
) -> Measurement<UnitLength>? {
	for (i, token) in tokens.enumerated() {
		if token.type == NLTag.adjective || token.type == NLTag.adverb {
			let word = text[token.range]
			for adj in adjectives {
				if word == adj {
					Logger.foreground.info(
						"Looking back measurement for \(word)"
					)
					return lookbackMeasurement(
						i: i,
						tokens: tokens,
						text: text,
						transcriptTags: &transcriptTags
					)
				}
			}
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

private func lookbackMeasurement(
	i: Int,
	tokens: [LexToken],
	text: String,
	transcriptTags: inout [TranscriptTag]
) -> Measurement<UnitLength>? {
	Logger.foreground.info("Getting lookback measurement")
	guard i - 2 > 0 else {
		Logger.foreground.info("bailing, too few tokens")
		return nil
	}
	let valueToken = tokens[i - 2]
	guard valueToken.type == NLTag.number else {
		Logger.foreground.info("bailing, value token is not a number")
		return nil
	}
	let unitToken = tokens[i - 1]
	guard unitToken.type == NLTag.noun else {
		Logger.foreground.info("bailing, unit token is not a noun")
		return nil
	}
	let valueString = text[valueToken.range]
	let unitString = text[unitToken.range]
	guard let value = parseMeasurementValue(String(valueString)) else {
		Logger.background.info("Couldn't parse \(valueString) as a Double")
		return nil
	}
	guard let unitLength = parseUnitLength(String(unitString)) else {
		Logger.background.info("Couldn't parse \(unitString) as a UnitLength")
		return nil
	}
	let dimensionToken = tokens[i]
	//var fullRange = valueToken.range.first!...dimensionToken.range.last!
	transcriptTags.append(
		TranscriptTag(range: valueToken.range, type: .Measurement)
	)
	transcriptTags.append(
		TranscriptTag(range: unitToken.range, type: .Measurement)
	)
	transcriptTags.append(
		TranscriptTag(range: dimensionToken.range, type: .Measurement)
	)
	Logger.foreground.info("Extracted measurement: \(value) \(unitString)")
	return Measurement(value: value, unit: unitLength)
}

private func parseMeasurementValue(_ valueString: String) -> Double? {
	guard let value = Double(valueString) else {
		switch valueString {
		case "zero":
			return 0.0
		case "one":
			return 1.0
		case "two":
			return 2.0
		case "three":
			return 3.0
		case "four":
			return 4.0
		case "five":
			return 5.0
		case "six":
			return 6.0
		case "seven":
			return 7.0
		case "eight":
			return 8.0
		case "nine":
			return 9.0
		case "ten":
			return 10.0
		default:
			Logger.foreground.info("Failed to parse \(valueString) as a Double")
			return nil
		}
	}
	return value
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
