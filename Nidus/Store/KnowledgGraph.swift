import Foundation

struct AdultProductionKnowledgeGraph {
	var adulticideTreatment: String?
	var landingCounts: String?
}

enum BreedingConditions: CustomStringConvertible {
	case AppearsVacant
	case Dry
	case DryingOut
	case EntryDenied
	case Flowing
	case HighOrganic
	case NeedsMonitoring
	case PoolFalse
	case PoolGreen
	case PoolMaintained
	case PoolRemoved
	case PoolUnmaintained
	case Stagnant
	case Unknown

	static var all: [BreedingConditions] {
		return [
			.AppearsVacant, .Dry, .DryingOut, .EntryDenied, .Flowing, .HighOrganic,
			.NeedsMonitoring, .PoolFalse, .PoolMaintained, .PoolRemoved,
			.PoolUnmaintained, .Stagnant, .Unknown,
		]
	}
	var description: String {
		switch self {
		case .AppearsVacant: "Appears vacant"
		case .Dry: "Dry"
		case .DryingOut: "Drying out"
		case .EntryDenied: "Entry denied"
		case .Flowing: "Flowing"
		case .HighOrganic: "High organic"
		case .NeedsMonitoring: "Needs monitoring"
		case .PoolFalse: "Pool false"
		case .PoolGreen: "Pool green"
		case .PoolMaintained: "Pool maintained"
		case .PoolRemoved: "Pool removed"
		case .PoolUnmaintained: "Pool unmaintained"
		case .Stagnant: "Stagnant"
		case .Unknown: "Unknown"
		}
	}
	static func fromString(_ s: String) -> BreedingConditions? {
		switch s {
		case "green", "murky":
			return .PoolGreen
		case "blue", "clear":
			return .PoolMaintained
		case "dry":
			return .Dry
		default:
			return nil
		}
	}
	static var prompts: [String] {
		return BreedingConditions.all.map { $0.description }
	}
}
enum Genus: CustomStringConvertible {
	case Aedes
	case Culex
	case Quinks
	var description: String {
		switch self {
		case .Aedes:
			"Aedes"
		case .Culex:
			"Culex"
		case .Quinks:
			"Quinks"
		}
	}
	static func fromString(_ s: String) -> Genus? {
		switch s.lowercased() {
		case "aedes":
			return .Aedes
		case "culex":
			return .Culex
		case "quinks":
			return .Quinks
		default:
			return nil
		}
	}
}

enum LifeStage: CustomStringConvertible {
	case FirstInstar
	case SecondInstar
	case ThirdInstar
	case FourthInstar

	var description: String {
		switch self {
		case .FirstInstar:
			"First instar"
		case .SecondInstar:
			"Second instar"
		case .ThirdInstar:
			"Third instar"
		case .FourthInstar:
			"Fourth instar"
		}
	}
	static func fromInt(_ i: Int) -> LifeStage? {
		switch i {
		case 1: return .FirstInstar
		case 2: return .SecondInstar
		case 3: return .ThirdInstar
		case 4: return .FourthInstar
		default: return nil
		}
	}
}
enum Species: CustomStringConvertible {
	case Aegypti
	var description: String {
		switch self {
		case .Aegypti:
			"Aegypti"
		}
	}
	static func fromString(_ s: String) -> Species? {
		switch s.lowercased() {
		case "aegypti":
			return .Aegypti
		default:
			return nil
		}
	}
}

enum TreatmentType {
	case SumilarvWSP
}

struct BreedingKnowledgeGraph {
	var conditions: BreedingConditions?
	var eggQuantity: Int?
	var isBreedingExplicit: Bool?
	var genus: Genus?
	var larvaeQuantity: Int?
	var pupaeQuantity: Int?
	var species: Species?
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

enum FieldseekerReportType {
	case Inspection
	case MosquitoSource
}
struct FieldseekerReportGraph {
	var dipCount: Int?
	var reportType: FieldseekerReportType?
}
struct RootCauseKnowledgeGraph {
	var fix: String?
	var legalAbatement: String?
}
enum SourceType {
	case Flood
}
/// A structure representing what we know about a mosquito source
struct SourceKnowledgeGraph {
	var hasFish: Bool?
	var preemptiveTreatment: String?
	var productionCapacity: String?
	var sourceElimination: String?
	// The type of mosquito source, or nil if we have no knowledge yet
	var type: SourceType?
	var volume: Volume
}

struct KnowledgeGraph {
	var adultProduction: AdultProductionKnowledgeGraph
	var breeding: BreedingKnowledgeGraph
	var driver: DriverKnowledgeGraph
	var facilitator: FacilitatorKnowledgeGraph
	var fieldseeker: FieldseekerReportGraph
	var rootCause: RootCauseKnowledgeGraph
	var source: SourceKnowledgeGraph
	var transcriptTags: [TranscriptTag]

	var hasAdultProduction: Bool {
		return adultProduction.adulticideTreatment != nil
			|| adultProduction.landingCounts != nil
	}
	var hasBreeding: Bool {
		if let breeding = breeding.isBreedingExplicit {
			return breeding
		}
		return breeding.genus != nil || breeding.stage != nil
			|| breeding.treatment != nil
	}
	var hasConditions: Bool {
		return breeding.conditions != nil
	}
	var hasDipCount: Bool {
		return fieldseeker.dipCount != nil
	}
	var hasDriver: Bool {
		return driver.behaviorModification != nil || driver.contact != nil
	}
	var hasEggCount: Bool {
		return breeding.eggQuantity != nil
	}
	var hasFacilitator: Bool {
		return facilitator.blocking != nil || facilitator.pathToRootCause != nil
			|| facilitator.pathToSource != nil
	}
	var hasFieldseekerReport: Bool {
		return fieldseeker.reportType != nil
	}
	var hasGenus: Bool {
		return breeding.genus != nil
	}
	var hasRootCause: Bool {
		return rootCause.fix != nil
			|| rootCause.legalAbatement != nil
	}
	var hasLarvaeCount: Bool {
		return breeding.larvaeQuantity != nil
	}
	var hasPupaeCount: Bool {
		return breeding.pupaeQuantity != nil
	}
	var hasSource: Bool {
		return source.type != nil || hasVolume
	}
	var hasStage: Bool {
		return breeding.stage != nil
	}
	var hasSurfaceArea: Bool {
		return source.volume.length != nil && source.volume.width != nil
	}
	var hasVolume: Bool {
		return source.volume.length != nil && source.volume.width != nil
			&& source.volume.depth != nil
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
	var isFieldseekerReportComplete: Bool {
		return fieldseeker.dipCount != nil && breeding.larvaeQuantity != nil
			&& breeding.pupaeQuantity != nil && breeding.eggQuantity != nil
			&& breeding.stage != nil && breeding.genus != nil
			&& breeding.conditions != nil
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
			conditions: nil,
			genus: nil,
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
		fieldseeker: FieldseekerReportGraph(
			reportType: nil
		),
		rootCause: RootCauseKnowledgeGraph(
			fix: nil,
			legalAbatement: nil
		),
		source: source
			?? SourceKnowledgeGraph(
				preemptiveTreatment: nil,
				productionCapacity: nil,
				sourceElimination: nil,
				type: nil,
				volume: Volume(
					depth: nil,
					length: nil,
					width: nil,
				)
			),
		transcriptTags: []
	)
}
