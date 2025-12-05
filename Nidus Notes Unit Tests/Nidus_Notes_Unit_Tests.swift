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
		#expect(knowledge.fieldseeker.reportType != nil)
		guard let reportType = knowledge.fieldseeker.reportType else {
			Issue.record("No report type found")
			return
		}
		#expect(reportType == .Inspection)
		guard let conditions = knowledge.breeding.conditions else {
			Issue.record("No conditions found")
			return
		}
		#expect(conditions == .PoolGreen)
		guard let isBreeding = knowledge.breeding.isBreeding else {
			Issue.record("No isBreeding found")
			return
		}
		#expect(isBreeding)
		#expect(knowledge.fieldseeker.dipCount == 10)
		#expect(knowledge.breeding.larvaeQuantity == 100)
		#expect(knowledge.breeding.pupaeQuantity == 20)
		#expect(knowledge.breeding.stage == .FourthInstar)
		guard let hasFish = knowledge.source.hasFish else {
			Issue.record("No hasFish found")
			return
		}
		#expect(!hasFish)
		guard let length = knowledge.source.volume.length else {
			Issue.record("No length found")
			return
		}
		#expect(length == Measurement(value: 15, unit: .feet))
		guard let width = knowledge.source.volume.width else {
			Issue.record("No width found")
			return
		}
		#expect(width == Measurement(value: 30, unit: .feet))
		guard let depth = knowledge.source.volume.depth else {
			Issue.record("No depth found")
			return
		}
		#expect(depth == Measurement(value: 5, unit: .feet))
	}
}
