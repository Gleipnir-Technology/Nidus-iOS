//
//  Nidus_Notes_Unit_Tests.swift
//  Nidus Notes Unit Tests
//
//  Created by Eli Ribble on 9/30/25.
//

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

	@Test func mosquitoSourceAndCounts() async throws {
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
}
