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
}

func expectInspectionReport(
	_ knowledge: KnowledgeGraph,
	conditions: BreedingConditions,
	dipCount: Int,
	fishPresence: Bool?,
	larvaeQuantity: Int?,
	pupaeQuantity: Int?,
	reportType: FieldseekerReportType,
	stage: LifeStage?,
	volume: Volume?
) {
	#expect(knowledge.breeding.conditions == conditions)
	#expect(knowledge.fieldseeker.dipCount == dipCount)
	#expect(knowledge.source.hasFish == fishPresence)
	#expect(knowledge.breeding.larvaeQuantity == larvaeQuantity)
	#expect(knowledge.breeding.pupaeQuantity == pupaeQuantity)
	#expect(knowledge.fieldseeker.reportType == reportType)
	#expect(knowledge.breeding.stage == stage)
	#expect(knowledge.source.volume == volume)
}
