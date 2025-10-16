import MapKit
import SwiftUI
import UIKit

enum NoteOverviewIcon {
	// Types from our ideal set of information
	case AbundanceTrendUp
	case AbundanceTrendDown
	case AggressiveAnimal
	case CallInAdvance
	case CompleteDataIndicator
	case ContactInformationAvailable
	case FacilitatorIndicator
	case FollowupScheduled
	case InteractionsNoted
	case RootCauseIndicator
	case PartOfCluster
	case PreviousTreatmentFailure
	case ProbabilityDeterminedByObservation
	case ProblematicResident
	case SpeciesFoundPreviously
	case SourceProbabilityIndicator

	// Types from FieldSeeker
	case HasComments
	case HasHabitat
	case HasInspections
	case HasNextActionScheduled
	case HasTreatments
	case HasUseType
	case HasWaterOrigin
	case SourceActive

	static let allCases: [NoteOverviewIcon] = [
		// Types from FieldSeeker. These go first so that we show the icons on our truncated grid
		.HasComments,
		.HasHabitat,
		.HasInspections,
		.HasNextActionScheduled,
		.HasTreatments,
		.HasUseType,
		.HasWaterOrigin,
		.SourceActive,

		// Types from our ideal set of information
		.AbundanceTrendUp,
		.AbundanceTrendDown,
		.AggressiveAnimal,
		.CallInAdvance,
		.CompleteDataIndicator,
		.ContactInformationAvailable,
		.FacilitatorIndicator,
		.FollowupScheduled,
		.InteractionsNoted,
		.RootCauseIndicator,
		.PartOfCluster,
		.PreviousTreatmentFailure,
		.ProbabilityDeterminedByObservation,
		.ProblematicResident,
		.SpeciesFoundPreviously,
		.SourceProbabilityIndicator,
	]
}

struct NoteOverview: Identifiable {
	var color: Color
	var icon: Image
	var icons: Set<NoteOverviewIcon>
	var id: UUID
	var location: H3Cell
	var text: String
	var time: Date
	var type: NoteType

	/// Return true if the given filter text would include the note
	func MatchesFilterText(_ text: String) -> Bool {
		if text.isEmpty {
			return false
		}
		return self.text.lowercased().contains(text.lowercased())
	}

	/// Given a filter string, show the text around it that matches
	func FilterContext(_ searchString: String, contextLength: Int = 10) -> String {
		let text = text.lowercased()
		let searchString = searchString.lowercased()

		// Make sure search string exists in text
		guard let range = text.range(of: searchString) else {
			return ""  // Search string not found
		}

		// Calculate start and end indices for context
		let startIndex =
			text.index(
				range.lowerBound,
				offsetBy: -min(
					contextLength,
					text.distance(from: text.startIndex, to: range.lowerBound)
				),
				limitedBy: text.startIndex
			) ?? text.startIndex
		let endIndex =
			text.index(
				range.upperBound,
				offsetBy: min(
					contextLength,
					text.distance(from: range.upperBound, to: text.endIndex)
				),
				limitedBy: text.endIndex
			) ?? text.endIndex

		// Create result string with the context
		var result = String(text[startIndex..<endIndex])

		// Add ellipsis if needed
		if startIndex > text.startIndex {
			result = "..." + result
		}

		if endIndex < text.endIndex {
			result = result + "..."
		}

		return result
	}
}

func noteOverviewPreview(_ icons: Set<NoteOverviewIcon>) -> NoteOverview {
	return NoteOverview(
		color: .red,
		icon: Image("mosquito.sideview"),
		icons: icons,
		id: UUID(),
		location: RegionControllerPreview.userCell,
		text: "",
		time: Date.now,
		type: .mosquitoSource
	)
}
