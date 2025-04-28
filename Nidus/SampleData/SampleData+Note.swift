//
//  SampleData+Note.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//
import Foundation

extension Note {
	static let advise = Note(
		category: NoteCategory.todo,
		content: "Make sure to let the Bob know we arrived.",
		location: NoteLocation(latitude: 33.3024121, longitude: -111.7349332)
	)
	static let dog = Note(
		category: NoteCategory.info,
		content: "There's a dog here.\nIt's annoying.",
		location: NoteLocation(latitude: 33.3026129, longitude: -111.7328528)
	)
	static let pool = Note(
		category: NoteCategory.todo,
		content: "Check on Wanda's green pool",
		location: NoteLocation(latitude: 33.3024125, longitude: -111.7340332)
	)
	static let roses = Note(
		category: NoteCategory.todo,
		content: "Smell the roses",
		location: NoteLocation(latitude: 33.3024131, longitude: -111.7349432)
	)
	static let wave = Note(
		category: NoteCategory.entry,
		content: "Wave at the nice guard.",
		location: NoteLocation(latitude: 33.3060406, longitude: -111.7342217)
	)
	static let standingWater = Note(
		category: NoteCategory.todo,
		content: "Drain standing water near shed - prime mosquito breeding ground",
		location: NoteLocation(latitude: 33.3024122, longitude: -111.7349333)
	)
	static let pondTreatment = Note(
		category: NoteCategory.todo,
		content: "Apply larvicide to backyard pond",
		location: NoteLocation(latitude: 33.3026130, longitude: -111.7328529)
	)
	static let denseBushes = Note(
		category: NoteCategory.info,
		content: "Dense bushes near fence - high mosquito population detected",
		location: NoteLocation(latitude: 33.3024126, longitude: -111.7340333)
	)
	static let brokenGutter = Note(
		category: NoteCategory.todo,
		content: "Recommend gutter repair - water collection point",
		location: NoteLocation(latitude: 33.3024132, longitude: -111.7349433)
	)
	static let trashCans = Note(
		category: NoteCategory.todo,
		content: "Treat and clean trash can areas - potential breeding sites",
		location: NoteLocation(latitude: 33.3060407, longitude: -111.7342218)
	)
	static let poolEquipment = Note(
		category: NoteCategory.todo,
		content: "Check pool equipment for water accumulation",
		location: NoteLocation(latitude: 33.3024123, longitude: -111.7349334)
	)
	static let gardenPonds = Note(
		category: NoteCategory.info,
		content: "Multiple decorative garden ponds - recommend biological control",
		location: NoteLocation(latitude: 33.3026131, longitude: -111.7328530)
	)
	static let constructionSite = Note(
		category: NoteCategory.todo,
		content: "Inspect construction site for water-filled containers",
		location: NoteLocation(latitude: 33.3024127, longitude: -111.7340334)
	)
	static let overgrownArea = Note(
		category: NoteCategory.info,
		content: "Overgrown vegetation near property line - high mosquito risk",
		location: NoteLocation(latitude: 33.3024133, longitude: -111.7349434)
	)
	static let roadSideDitch = Note(
		category: NoteCategory.todo,
		content: "Treat roadside drainage ditch with larvicide",
		location: NoteLocation(latitude: 33.3060408, longitude: -111.7342219)
	)
	static let abandonedSwimmingPool = Note(
		category: NoteCategory.todo,
		content: "Apply treatment to abandoned swimming pool",
		location: NoteLocation(latitude: 33.3024124, longitude: -111.7349335)
	)
	static let birdbath = Note(
		category: NoteCategory.todo,
		content: "Clean and treat birdbath - potential mosquito breeding site",
		location: NoteLocation(latitude: 33.3026132, longitude: -111.7328531)
	)
	static let compostPile = Note(
		category: NoteCategory.info,
		content: "Wet compost pile - high moisture environment for mosquitoes",
		location: NoteLocation(latitude: 33.3024128, longitude: -111.7340335)
	)
	static let garageClutter = Note(
		category: NoteCategory.todo,
		content: "Remove water-collecting items from garage area",
		location: NoteLocation(latitude: 33.3024134, longitude: -111.7349435)
	)
	static let irrigationSystem = Note(
		category: NoteCategory.todo,
		content: "Check irrigation system for leaks and standing water",
		location: NoteLocation(latitude: 33.3060409, longitude: -111.7342220)
	)
}
