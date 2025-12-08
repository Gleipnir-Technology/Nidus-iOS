//
//  Nidus_Notes_Unit_Tests.swift
//  Nidus Notes Unit Tests
//
//  Created by Eli Ribble on 9/30/25.
//

import Foundation
import Testing

@testable import Nidus_Notes

struct Nidus_Notes_Unit_Tests {

	@Test func mosquitoSource() async throws {
		let text = "Checking on a mosquito source"
		let knowledge = ExtractKnowledge(text)
		#expect(knowledge.fieldseeker.reportType != nil)
		guard let reportType = knowledge.fieldseeker.reportType else {
			Issue.record("No report type found")
			return
		}
		#expect(reportType == FieldseekerReportType.MosquitoSource)
	}

	@Test func mosquitoSourceCounts() async throws {
		let text =
			"Checking on a mosquito source at 123 Main Street. 10 dips. 20 pupae. 30 eggs"
		let knowledge = ExtractKnowledge(text)
		#expect(knowledge.fieldseeker.reportType != nil)
		guard let reportType = knowledge.fieldseeker.reportType else {
			Issue.record("No report type found")
			return
		}
		#expect(reportType == FieldseekerReportType.MosquitoSource)
		#expect(knowledge.fieldseeker.dipCount == 10)
		#expect(knowledge.breeding.eggQuantity == 30)
		#expect(knowledge.breeding.pupaeQuantity == 20)
	}

	@Test func mosquitoSourceStage() async throws {
		let text =
			"Checking on a mosquito source at 123 Main Street. 10 dips. 20 pupae. 30 eggs. second instar"
		let knowledge = ExtractKnowledge(text)
		#expect(knowledge.fieldseeker.reportType != nil)
		guard let reportType = knowledge.fieldseeker.reportType else {
			Issue.record("No report type found")
			return
		}
		#expect(reportType == .MosquitoSource)
		guard let stage = knowledge.breeding.stage else {
			Issue.record("No stage found")
			return
		}
		#expect(stage == .SecondInstar)
	}

	@Test func mosquitoSourceGenus() async throws {
		let text =
			"Checking on a mosquito source at 123 Main Street. 10 dips. 20 pupae. 30 eggs. Looks like Culex."
		let knowledge = ExtractKnowledge(text)
		#expect(knowledge.fieldseeker.reportType != nil)
		guard let reportType = knowledge.fieldseeker.reportType else {
			Issue.record("No report type found")
			return
		}
		#expect(reportType == .MosquitoSource)
		guard let genus = knowledge.breeding.genus else {
			Issue.record("No genus found")
			return
		}
		#expect(genus == .Culex)
	}

	@Test func mosquitoSourceConditions() async throws {
		let text =
			"Checking on a mosquito source at 123 Main Street. Conditions are dry"
		let knowledge = ExtractKnowledge(text)
		#expect(knowledge.fieldseeker.reportType != nil)
		guard let reportType = knowledge.fieldseeker.reportType else {
			Issue.record("No report type found")
			return
		}
		#expect(reportType == .MosquitoSource)
		guard let conditions = knowledge.breeding.conditions else {
			Issue.record("No conditions found")
			return
		}
		#expect(conditions == .Dry)
	}

	@Test func fromOrdinalToIntConversion() async throws {
		#expect(fromOrdinal("first") == 1)
		#expect(fromOrdinal("second") == 2)
		#expect(fromOrdinal("third") == 3)
		#expect(fromOrdinal("fourth") == 4)
		#expect(fromOrdinal("fifth") == 5)
	}

	@Test func inspectionTest1() async throws {
		let text =
			"Begin inspection. I'm at a swimming pool that is green and has high organic content. It is breeding heavily. I did 10 dips and found about 100 larvae stage one and stage four and 20 pupae. No fish present. The pool dimensions are 15 by 30 by 5 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolGreen,
			dipCount: 10,
			fishPresence: false,
			isBreeding: true,
			larvaeQuantity: 100,
			pupaeQuantity: 20,
			reportType: FieldseekerReportType.Inspection,
			stage: LifeStage.FourthInstar,
			volume: Volume(
				depth: Measurement(value: 5, unit: .feet),
				length: Measurement(value: 15, unit: .feet),
				width: Measurement(value: 30, unit: .feet),
			)
		)
	}

	@Test func inspectionTest2() async throws {
		let text =
			"Begin inspection. Checked the backyard pool. It is maintained, clear, and blue. I took 10 dips all around the steps and deep end. No larvae and no pupae found. No fish seen. The pool is 20 feet wide by 40 feet long by 8 feet deep."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolMaintained,
			dipCount: 10,
			fishPresence: false,
			isBreeding: false,
			larvaeQuantity: 0,
			pupaeQuantity: 0,
			reportType: FieldseekerReportType.Inspection,
			stage: nil,
			volume: Volume(
				depth: Measurement(value: 8, unit: .feet),
				length: Measurement(value: 40, unit: .feet),
				width: Measurement(value: 20, unit: .feet),
			)
		)
	}

	@Test func inspectionTest3() async throws {
		let text =
			"Begin inspection. I was able to get a visual from the neighbor's house. The pool is murky with scum on top. I accessed it and found breeding. 5 dips had 10 larvae and 2 tumblers. They look like Aedes aegypti. I verified fish are present but struggling. Dimensions are 12 by 24 by 4 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolMurky,
			dipCount: 5,
			fishPresence: true,
			genus: .Aedes,
			isBreeding: true,
			larvaeQuantity: 10,
			pupaeQuantity: 2,
			reportType: FieldseekerReportType.Inspection,
			species: .Aegypti,
			stage: nil,
			volume: Volume(
				depth: Measurement(value: 4, unit: .feet),
				length: Measurement(value: 12, unit: .feet),
				width: Measurement(value: 24, unit: .feet),
			)
		)
	}

	@Test func inspectionTest4() async throws {
		let text =
			"Begin inspection. Swimming pool is completely dry at this time, actually full of grass at the bottom. No breeding and no fish. I’m measuring it for the record pool is 18 feet by 36 feet by 6 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.Dry,
			dipCount: nil,
			fishPresence: false,
			isBreeding: false,
			larvaeQuantity: nil,
			pupaeQuantity: nil,
			reportType: FieldseekerReportType.Inspection,
			stage: nil,
			volume: Volume(
				depth: Measurement(value: 6, unit: .feet),
				length: Measurement(value: 18, unit: .feet),
				width: Measurement(value: 36, unit: .feet),
			)
		)
	}

	@Test func inspectionTest5() async throws {
		let text =
			"Begin inspection. This is a green pool. Fish are present and alive. There was still very light breeding so I added more. 10 dips total with 5 larvae stage two. The pool size is 16 by 32 by 5 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolGreen,
			dipCount: 10,
			fishPresence: true,
			isBreeding: true,
			larvaeQuantity: 5,
			pupaeQuantity: nil,
			reportType: FieldseekerReportType.Inspection,
			stage: .SecondInstar,
			volume: Volume(
				depth: Measurement(value: 5, unit: .feet),
				length: Measurement(value: 16, unit: .feet),
				width: Measurement(value: 32, unit: .feet),
			)
		)
	}
	@Test func inspectionTest6() async throws {
		let text =
			"Begin inspection. I’m at a murky pool, visibility is low. It is breeding. I did 10 dips and found 40 larvae and 15 Pupae stages three and four. No fish found. I measured the pool at 16 by 32 by 6 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolMurky,
			dipCount: 10,
			fishPresence: false,
			isBreeding: true,
			larvaeQuantity: 40,
			pupaeQuantity: 15,
			reportType: FieldseekerReportType.Inspection,
			stage: .FourthInstar,
			volume: Volume(
				depth: Measurement(value: 6, unit: .feet),
				length: Measurement(value: 16, unit: .feet),
				width: Measurement(value: 32, unit: .feet),
			)
		)
	}
	@Test func inspectionTest7() async throws {
		let text =
			"Begin inspection. Backyard pool is maintained, water is crystal clear. I took 5 dips near the skimmer, zero larvae and zero pupae. No fish needed. Dimensions are 18 feet wide, 36 feet long, and 5 feet deep."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolMaintained,
			dipCount: 5,
			fishPresence: false,
			isBreeding: false,
			larvaeQuantity: 0,
			pupaeQuantity: 0,
			reportType: FieldseekerReportType.Inspection,
			stage: nil,
			volume: Volume(
				depth: Measurement(value: 5, unit: .feet),
				length: Measurement(value: 36, unit: .feet),
				width: Measurement(value: 18, unit: .feet),
			)
		)
	}
	@Test func inspectionTest8() async throws {
		let text =
			"Begin inspection. This pool is green with high organic matter. Breeding is heavy. I took 10 dips getting 200 larvae and 30 tumblers. Fish are established but struggling. The pool is 20 by 40 by 8 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolGreen,
			dipCount: 10,
			fishPresence: true,
			isBreeding: true,
			larvaeQuantity: 200,
			pupaeQuantity: 30,
			reportType: FieldseekerReportType.Inspection,
			stage: nil,
			volume: Volume(
				depth: Measurement(value: 8, unit: .feet),
				length: Measurement(value: 20, unit: .feet),
				width: Measurement(value: 40, unit: .feet),
			)
		)
	}
	@Test func inspectionTest9() async throws {
		let text =
			"Begin inspection. The pool is dry, actually bone dry with dirt at the bottom. No breeding and no fish."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.Dry,
			dipCount: nil,
			fishPresence: false,
			isBreeding: false,
			larvaeQuantity: nil,
			pupaeQuantity: nil,
			reportType: FieldseekerReportType.Inspection,
			stage: nil,
			volume: Volume(
				depth: nil,
				length: nil,
				width: nil,
			)
		)
	}
	@Test func inspectionTest10() async throws {
		let text =
			"Begin inspection. Pool is green and stagnant. Breeding confirmed. 3 dips showed 50 Aedes aegypti larvae and 2 egg rafts. No fish present. It’s a small pool 1 by 2 by 1 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolGreen,
			dipCount: 3,
			eggQuantity: 2,
			fishPresence: false,
			genus: .Aedes,
			isBreeding: true,
			larvaeQuantity: 50,
			pupaeQuantity: nil,
			reportType: FieldseekerReportType.Inspection,
			species: .Aegypti,
			stage: nil,
			volume: Volume(
				depth: Measurement(value: 1, unit: .feet),
				length: Measurement(value: 1, unit: .feet),
				width: Measurement(value: 2, unit: .feet),
			)
		)
	}
	@Test func inspectionTest11() async throws {
		let text =
			"Begin inspection. I checked the pool and it is green. It is breeding heavy. I did 10 dips and caught 100 larvae all stages. No fish present."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolGreen,
			dipCount: 10,
			eggQuantity: nil,
			fishPresence: false,
			genus: nil,
			isBreeding: true,
			larvaeQuantity: 100,
			pupaeQuantity: nil,
			reportType: FieldseekerReportType.Inspection,
			species: nil,
			stage: .FourthInstar,
			volume: Volume(
				depth: nil,
				length: nil,
				width: nil,
			)
		)
	}
	@Test func inspectionTest12() async throws {
		let text =
			"Begin inspection. The pool is maintained and blue. No breeding found today. No fish. The pool is 15 by 30 by 5 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolMaintained,
			dipCount: nil,
			eggQuantity: nil,
			fishPresence: false,
			genus: nil,
			isBreeding: false,
			larvaeQuantity: nil,
			pupaeQuantity: nil,
			reportType: FieldseekerReportType.Inspection,
			species: nil,
			stage: nil,
			volume: Volume(
				depth: Measurement(value: 5, unit: .feet),
				length: Measurement(value: 15, unit: .feet),
				width: Measurement(value: 30, unit: .feet),
			)
		)
	}
	@Test func inspectionTest13() async throws {
		let text =
			"Begin inspection. This is a murky pool behind the vacant house. It is breeding lightly. 10 dips yielded 15 larvae stage two. The pool is 12 by 24 by 4 feet."
		let knowledge = ExtractKnowledge(text)
		expectInspectionReport(
			knowledge,
			conditions: BreedingConditions.PoolMurky,
			dipCount: 10,
			eggQuantity: nil,
			fishPresence: nil,
			genus: nil,
			isBreeding: true,
			larvaeQuantity: 15,
			pupaeQuantity: nil,
			reportType: FieldseekerReportType.Inspection,
			species: nil,
			stage: .SecondInstar,
			volume: Volume(
				depth: Measurement(value: 4, unit: .feet),
				length: Measurement(value: 12, unit: .feet),
				width: Measurement(value: 24, unit: .feet),
			)
		)
	}
}

func expectInspectionReport(
	_ knowledge: KnowledgeGraph,
	conditions: BreedingConditions,
	dipCount: Int?,
	eggQuantity: Int? = nil,
	fishPresence: Bool?,
	genus: Genus? = nil,
	isBreeding: Bool?,
	larvaeQuantity: Int?,
	pupaeQuantity: Int?,
	reportType: FieldseekerReportType,
	species: Species? = nil,
	stage: LifeStage?,
	volume: Volume?
) {
	#expect(knowledge.hasBreeding == isBreeding)
	#expect(knowledge.breeding.conditions == conditions)
	#expect(knowledge.breeding.genus == genus)
	#expect(knowledge.breeding.eggQuantity == eggQuantity)
	#expect(knowledge.fieldseeker.dipCount == dipCount)
	#expect(knowledge.source.hasFish == fishPresence)
	#expect(knowledge.breeding.larvaeQuantity == larvaeQuantity)
	#expect(knowledge.breeding.pupaeQuantity == pupaeQuantity)
	#expect(knowledge.fieldseeker.reportType == reportType)
	#expect(knowledge.breeding.species == species)
	#expect(knowledge.breeding.stage == stage)
	#expect(knowledge.source.volume == volume)
}
