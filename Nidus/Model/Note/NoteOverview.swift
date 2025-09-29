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
	var time: Date
	var type: NoteType
}

func noteOverviewPreview(_ icons: Set<NoteOverviewIcon>) -> NoteOverview {
	return NoteOverview(
		color: .red,
		icon: Image("mosquito.sideview"),
		icons: icons,
		id: UUID(),
		location: RegionControllerPreview.userCell,
		time: Date.now,
		type: .mosquitoSource
	)
}
