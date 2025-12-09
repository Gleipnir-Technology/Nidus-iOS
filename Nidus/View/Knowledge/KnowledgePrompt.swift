import SwiftUI

struct KnowledgePrompt: View {
	let knowledge: KnowledgeGraph?

	var body: some View {
		if knowledge == nil {
			EmptyView()
		}
		else {
			switch knowledge!.fieldseeker.reportType {
			case nil:
				Text("Don't try to render AudioTagFieldseeker with nil reportType")
			case .MosquitoSource:
				KnowledgePromptMosquitoSource(knowledge: knowledge!)
			case .Inspection:
				KnowledgePromptInspection(knowledge: knowledge!)
			}
		}
	}
}

struct KnowledgePromptInspection: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		VStack {
			if !knowledge.isReportComplete {
				KnowledgeTable(
					title: "Inspection",
					fields: [
						KnowledgeField(
							name: "Condition",
							prompt: "green/blue/murky",
							promptChoices: [
								"green", "maintained", "dry",
								"murky",
							],
							isDone: knowledge.hasConditions,
							value: knowledge.breeding.conditions?
								.description
								?? "nil",
						),
						KnowledgeField(
							name: "Breeding",
							prompt: "[not] breeding/larvae present",
							isDone: knowledge.impliesBreeding,
							value: knowledge.impliesBreeding
								.description,
						),
						KnowledgeField(
							name: "Dip",
							prompt: "# dips",
							isDone: knowledge.hasDipCount,
							value: knowledge.fieldseeker.dipCount?
								.description
								?? "nil"
						),
						KnowledgeField(
							name: "Pupa",
							prompt: "# pupa",
							isDone: knowledge.hasPupaeCount,
							value: knowledge.breeding.pupaeQuantity?
								.description
								?? "nil"
						),
						KnowledgeField(
							name: "Larva",
							prompt: "# larva",
							isDone: knowledge.hasEggCount,
							value: knowledge.breeding.eggQuantity?
								.description
								?? "nil"
						),
						KnowledgeField(
							name: "Stage",
							prompt: "# Instar, adult",
							isDone: knowledge.hasStage,
							value: knowledge.breeding.stage?.description
								?? "nil"
						),
						KnowledgeField(
							name: "Genus",
							prompt: "genus",
							promptChoices: ["Aedes", "Culex"],
							isDone: knowledge.hasGenus,
							value: knowledge.breeding.genus?.description
								?? "nil"
						),
						KnowledgeField(
							name: "Fish",
							prompt: "[no] fish present",
							isDone: knowledge.hasConditions,
							value: knowledge.breeding.conditions?
								.description
								?? "nil"
						),
						KnowledgeField(
							name: "Dimensions",
							prompt: "x by y by z feet|meters",
							isDone: knowledge.hasSurfaceArea,
							value: knowledge.breeding.conditions?
								.description
								?? "nil"
						),
					]
				)
			}
		}
	}
}
struct KnowledgePromptMosquitoSource: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		VStack {
			if !knowledge.isReportComplete {
				KnowledgeTable(
					title: "Mosquito Source",
					fields: [
						KnowledgeField(
							name: "Dip",
							prompt: "# dips",
							isDone: knowledge.hasDipCount,
							value: knowledge.fieldseeker.dipCount?
								.description
								?? "nil"
						),

						KnowledgeField(
							name: "Larva",
							prompt: "# larva",
							isDone: knowledge.hasLarvaeCount,
							value: knowledge.breeding.larvaeQuantity?
								.description ?? "nil"
						),
						KnowledgeField(
							name: "Pupa",
							prompt: "# pupa",
							isDone: knowledge.hasPupaeCount,
							value: knowledge.breeding.pupaeQuantity?
								.description
								?? "nil"
						),
						KnowledgeField(
							name: "Larva",
							prompt: "# larva",
							isDone: knowledge.hasLarvaeCount,
							value: knowledge.breeding.larvaeQuantity?
								.description
								?? "nil"
						),
						KnowledgeField(
							name: "Stage",
							prompt: "# Instar, adult",
							isDone: knowledge.hasStage,
							value: knowledge.breeding.stage?.description
								?? "nil"
						),
						KnowledgeField(
							name: "Genus",
							prompt: "genus",
							promptChoices: ["Aedes", "Culex"],
							isDone: knowledge.hasGenus,
							value: knowledge.breeding.genus?.description
								?? "nil"
						),
						KnowledgeField(
							name: "Conditions",
							prompt: "conditions",
							promptChoices: BreedingConditions.prompts,
							isDone: knowledge.hasConditions,
							value: knowledge.breeding.conditions?
								.description
								?? "nil"
						),
					]
				)
			}
		}
	}
}

struct KnowledgePromptPreview: View {
	let knowledge: KnowledgeGraph
	init(_ knowledge: KnowledgeGraph) {
		self.knowledge = knowledge
	}
	var body: some View {
		KnowledgePrompt(knowledge: knowledge)
	}
}
struct KnowledgePrompt_Previews: PreviewProvider {
	static func makeKnowledge(breeding: BreedingKnowledgeGraph? = nil) -> KnowledgeGraph {
		return knowledgeForPreview(
			breeding: breeding,
			fieldseeker: FieldseekerReportGraph(
				reportType: .Inspection,
			)
		)
	}
	static var previews: some View {
		KnowledgePromptPreview(makeKnowledge()).previewDisplayName("empty")
		KnowledgePromptPreview(
			makeKnowledge(
				breeding: BreedingKnowledgeGraph(
					genus: .Aedes,
					stage: .SecondInstar
				),
			)
		).previewDisplayName("partial")
	}
}
