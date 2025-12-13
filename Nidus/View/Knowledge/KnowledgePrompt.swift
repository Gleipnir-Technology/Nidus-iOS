import SwiftUI

struct KnowledgePrompt: View {
	let controller: RootController
	let knowledge: KnowledgeGraph?

	var body: some View {

		if knowledge == nil {
			EmptyView()
		}
		else {
			VStack {
				KnowledgeTagDisplay(
					tags: knowledge!.userTags,
					tagColors: [
						"safety": .red,
						"followup": .blue,
					]
				)
				switch knowledge!.fieldseeker.reportType {
				case nil:
					Text(
						"Don't try to render AudioTagFieldseeker with nil reportType"
					)
				case .MosquitoSource:
					KnowledgePromptMosquitoSource(knowledge: knowledge!)
				case .Inspection:
					KnowledgePromptInspection(
						controller: controller,
						knowledge: knowledge!
					)
				}
			}
		}
	}
}

struct KnowledgePromptInspection: View {
	let controller: RootController
	let knowledge: KnowledgeGraph

	var body: some View {
		VStack {
			/*if knowledge.impliesNeedsTreatment {
				NavigationLink(destination: TreatmentRecommendationView()) {
                    Button(action: {
                        // Handle alter treatment
                    }) {
                        HStack {
                            Image(systemName: "syringe")
                            Text("Recommended Treatment")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
				}
             }
			*/
			NavigationLink(destination: TreatmentRecommendationView()) {
				HStack {
					Image(systemName: "syringe")
					Text("Treatment").foregroundStyle(Color.white).font(.title)
				}
				.padding()
				.foregroundColor(.white)
				.background(
					Color.orange.clipShape(
						.rect(cornerRadius: 10)
					)
				)
			}
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
							name: "Fish",
							prompt: "[no] fish present",
							isDone: knowledge.source.hasFish != nil,
							value: knowledge.source.hasFish?
								.description
								?? "nil"
						),
						KnowledgeField(
							name: "Dimensions",
							prompt: "x by y by z feet|meters",
							isDone: knowledge.hasVolume,
							value: knowledge.source.volume.description,
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
		NavigationStack {
			KnowledgePrompt(controller: RootControllerPreview(), knowledge: knowledge)
		}
	}
}
struct KnowledgePrompt_Previews: PreviewProvider {
	static func makeKnowledge(
		breeding: BreedingKnowledgeGraph? = nil,
		source: SourceKnowledgeGraph? = nil
	) -> KnowledgeGraph {
		return knowledgeForPreview(
			breeding: breeding,
			fieldseeker: FieldseekerReportGraph(
				reportType: .Inspection,
			),
			source: source,
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
		KnowledgePromptPreview(
			makeKnowledge(
				breeding: BreedingKnowledgeGraph(
					conditions: .PoolGreen,
					genus: .Aedes,
					stage: .SecondInstar
				),
				source: SourceKnowledgeGraph(
					volume: Volume(
						depth: Measurement(value: 4, unit: .feet),
						length: Measurement(value: 10, unit: .feet),
						width: Measurement(value: 20, unit: .feet),
					)
				)
			)
		).previewDisplayName("needs treatment")
	}
}
