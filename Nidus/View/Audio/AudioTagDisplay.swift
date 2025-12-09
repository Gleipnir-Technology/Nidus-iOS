import NaturalLanguage
import SwiftUI

struct TagRow: Identifiable {
	let id: Int
	let type: String
	let word: String
}

struct AudioTagFieldseekerReportType: View {
	let name: String
	let isComplete: Bool

	var body: some View {
		if isComplete {
			Text("FS: \(name)").font(.system(size: 12)).frame(
				height: 15
			).padding(5).background(
				RoundedRectangle(cornerRadius: 30, style: .continuous).fill(
					PALETTE_LIGHT.B
				)
			)
		}
		else {
			Text("FS: \(name)").font(.system(size: 12)).frame(
				height: 15
			).padding(5).background(
				RoundedRectangle(cornerRadius: 30, style: .continuous).fill(
					PALETTE_LIGHT.A
				)
			)
		}
	}

}

/*
struct AudioTagDisplay_Previews: PreviewProvider {
	static var previews: some View {
		AudioTagDisplay(knowledge: nil).previewDisplayName("no knowledge")
		//AudioTagDisplay(knowledge: knowledgeForPreview()).previewDisplayName("empty knowledge")
		AudioTagDisplay(knowledge: knowledgeForPreview(
            source: SourceKnowledgeGraph(preemptiveTreatment: nil, productionCapacity: nil, sourceElimination: nil, type: .Flood, volume: nil)
        )).previewDisplayName("source")
	}
}*/
