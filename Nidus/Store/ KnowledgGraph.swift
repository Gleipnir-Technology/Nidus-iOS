import Foundation

struct AdultProductionKnowledgeGraph {
	var adulticideTreatment: String?
	var landingCounts: String?
}

enum LifeStage {
	case FirstInstar
	case SecondInstar
	case ThirdInstar
}

enum Genus {
	case Aedes
	case Aegypti
	case Culex
	case Quinks
}

enum TreatmentType {
	case SumilarvWSP
}

struct BreedingKnowledgeGraph {
	var genus: Genus?
	var quantity: Int?
	var stage: LifeStage?
	var treatment: TreatmentType?
}

struct DriverKnowledgeGraph {
	var behaviorModification: String?
	var contact: String?
}
struct FacilitatorKnowledgeGraph {
	var blocking: String?
	var pathToRootCause: String?
	var pathToSource: String?
}
struct RootCauseKnowledgeGraph {
	var conditions: String?
	var fix: String?
	var legalAbatement: String?
}
enum SourceType {
	case Flood
}
/// A structure representing what we know about a mosquito source
struct SourceKnowledgeGraph {
	var preemptiveTreatment: String?
	var productionCapacity: String?
	var sourceElimination: String?
	// The type of mosquito source, or nil if we have no knowledge yet
	var type: SourceType?
	var volume: Volume?
}

struct KnowledgeGraph {
	var adultProduction: AdultProductionKnowledgeGraph
	var breeding: BreedingKnowledgeGraph
	var driver: DriverKnowledgeGraph
	var facilitator: FacilitatorKnowledgeGraph
	var rootCause: RootCauseKnowledgeGraph
	var source: SourceKnowledgeGraph
	var transcriptTags: [TranscriptTag]

	var hasAdultProduction: Bool {
		return adultProduction.adulticideTreatment != nil
			|| adultProduction.landingCounts != nil
	}
	var hasBreeding: Bool {
		return breeding.genus != nil || breeding.quantity != nil || breeding.stage != nil
			|| breeding.treatment != nil
	}
	var hasDriver: Bool {
		return driver.behaviorModification != nil || driver.contact != nil
	}
	var hasFacilitator: Bool {
		return facilitator.blocking != nil || facilitator.pathToRootCause != nil
			|| facilitator.pathToSource != nil
	}
	var hasRootCause: Bool {
		return rootCause.conditions != nil || rootCause.fix != nil
			|| rootCause.legalAbatement != nil
	}
	var hasSource: Bool {
		return source.type != nil || source.volume != nil
	}
	var impliesAdultProduction: Bool {
		return hasAdultProduction || hasBreeding
	}
	var impliesBreeding: Bool {
		return hasBreeding || hasSource || hasAdultProduction
	}
	var impliesDriver: Bool {
		return hasDriver || hasRootCause
	}
	var impliesFacilitator: Bool {
		return hasFacilitator || hasRootCause || hasSource
	}
	var impliesRootCause: Bool {
		return hasRootCause || hasDriver || hasFacilitator
	}
	var impliesSource: Bool {
		return hasSource || hasFacilitator || hasBreeding
	}
}

enum TranscriptTagType {
	case Action
	case Source
	case Measurement
}

enum VolumeUnits {
	case feet
	case inches
	case meters
}

struct Volume: Equatable {
	var depth: Measurement<UnitLength>?
	var length: Measurement<UnitLength>?
	var width: Measurement<UnitLength>?

	static func == (lhs: Volume, rhs: Volume) -> Bool {
		return lhs.depth == rhs.depth && lhs.length == rhs.length
			&& lhs.width == rhs.width
	}
}

struct TranscriptTag {
	let range: Range<String.Index>
	let type: TranscriptTagType
}

func knowledgeForPreview(source: SourceKnowledgeGraph? = nil) -> KnowledgeGraph {
	return KnowledgeGraph(
		adultProduction: AdultProductionKnowledgeGraph(),
		breeding: BreedingKnowledgeGraph(
			genus: nil,
			quantity: nil,
			stage: nil,
			treatment: nil
		),
		driver: DriverKnowledgeGraph(
			behaviorModification: nil,
			contact: nil
		),
		facilitator: FacilitatorKnowledgeGraph(
			blocking: nil,
			pathToRootCause: nil,
			pathToSource: nil
		),
		rootCause: RootCauseKnowledgeGraph(
			conditions: nil,
			fix: nil,
			legalAbatement: nil
		),
		source: source
			?? SourceKnowledgeGraph(
				preemptiveTreatment: nil,
				productionCapacity: nil,
				sourceElimination: nil,
				type: nil,
				volume: nil
			),
		transcriptTags: []
	)
}
