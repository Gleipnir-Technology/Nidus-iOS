//
//  Nidus_Notes_Unit_Tests.swift
//  Nidus Notes Unit Tests
//
//  Created by Eli Ribble on 9/30/25.
//

import Testing

@testable import Nidus_Notes

struct Nidus_Notes_Unit_Tests {

	@Test func example() async throws {
		let text = "I see a flooded gutter."
		let knowledge = ExtractKnowledge(text)
		#expect(knowledge.source.type == .Flood)
	}

}
