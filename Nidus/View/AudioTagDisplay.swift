import NaturalLanguage
import SwiftUI

struct TagRow: Identifiable {
	let id: Int
	let type: String
	let word: String
}

struct AudioTagDisplay: View {
	let knowledge: KnowledgeGraph?

	var body: some View {
		if knowledge == nil {
			EmptyView()
		}
		else {
			if knowledge!.hasFieldseekerReport {
				AudioTagFieldseeker(knowledge: knowledge!)
			}
			else {
				AudioTagNidusFlow(knowledge: knowledge!)
			}
		}
	}
}

struct AudioTagFieldseeker: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		switch knowledge.fieldseeker.reportType {
		case nil:
			Text("Don't try to render AudioTagFieldseeker with nil reportType")
		case .MosquitoSource:
			AudioTagFieldseekerMosquitoSource(knowledge: knowledge)
		case .Inspection:
			AudioTagFieldseekerInspection(knowledge: knowledge)
		}
	}
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
struct AudioTagFieldseekerReportField<T: CustomStringConvertible>: View {
	let name: String
	let prompt: String
	var promptChoices: [String] = []
	let isDone: Bool
	let value: T?

	var font: Font { .system(size: 13) }
	var body: some View {
		GridRow(alignment: .top) {
			if isDone {
				Image(systemName: "checkmark.square")
				Text(name).font(font).gridColumnAlignment(.leading)
					.foregroundStyle(
						Color.primary.opacity(0.5)
					)
				Text(value?.description ?? "nil").font(font).gridColumnAlignment(
					.leading
				).foregroundStyle(Color.primary.opacity(0.7))
			}
			else {
				Image(systemName: "square")
				Text(name).font(font).gridColumnAlignment(.leading)
					.foregroundStyle(Color.primary)
				Text("\"\(prompt)\"").font(font).gridColumnAlignment(.leading)
				if !promptChoices.isEmpty {
					ScrollView {
						VStack {
							ForEach(promptChoices, id: \.self) {
								promptChoice in
								Text(promptChoice).font(font).frame(
									maxWidth: 200,
									alignment: .leading
								)
							}
						}
					}
				}
			}
		}
	}
}

struct AudioTagFieldseekerInspection: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		VStack {
			AudioTagFieldseekerReportType(
				name: "Inspection",
				isComplete: knowledge.isFieldseekerReportComplete
			)
			if !knowledge.isFieldseekerReportComplete {
				Grid {
					AudioTagFieldseekerReportField(
						name: "Condition",
						prompt: "green/blue/murky",
						promptChoices: [
							"green", "maintained", "dry", "murky",
						],
						isDone: knowledge.hasConditions,
						value: knowledge.breeding.conditions,
					)
					AudioTagFieldseekerReportField(
						name: "Breeding",
						prompt: "[not] breeding/larvae present",
						isDone: knowledge.impliesBreeding,
						value: knowledge.impliesBreeding,
					)
					AudioTagFieldseekerReportField(
						name: "Dip",
						prompt: "# dips",
						isDone: knowledge.hasDipCount,
						value: knowledge.fieldseeker.dipCount
					)
					AudioTagFieldseekerReportField(
						name: "",
						prompt: "# pupae",
						isDone: knowledge.hasPupaeCount,
						value: knowledge.breeding.pupaeQuantity
					)
					AudioTagFieldseekerReportField(
						name: "Eggs",
						prompt: "# eggs",
						isDone: knowledge.hasEggCount,
						value: knowledge.breeding.eggQuantity
					)
					AudioTagFieldseekerReportField(
						name: "Stage",
						prompt: "# Instar, adult",
						isDone: knowledge.hasStage,
						value: knowledge.breeding.stage
					)
					AudioTagFieldseekerReportField(
						name: "Genus",
						prompt: "genus",
						promptChoices: ["Aedes", "Culex"],
						isDone: knowledge.hasGenus,
						value: knowledge.breeding.genus
					)
					AudioTagFieldseekerReportField(
						name: "Fish",
						prompt: "fish [not] present",
						isDone: knowledge.hasConditions,
						value: knowledge.breeding.conditions
					)
					AudioTagFieldseekerReportField(
						name: "Dimensions",
						prompt: "x meters by y meters",
						isDone: knowledge.hasSurfaceArea,
						value: knowledge.breeding.conditions
					)
				}
			}
		}
	}
}
struct AudioTagFieldseekerMosquitoSource: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		VStack {
			AudioTagFieldseekerReportType(
				name: "Mosquito Source",
				isComplete: knowledge.isFieldseekerReportComplete
			)
			if !knowledge.isFieldseekerReportComplete {
				Grid {
					AudioTagFieldseekerReportField(
						name: "Dip",
						prompt: "# dips",
						isDone: knowledge.hasDipCount,
						value: knowledge.fieldseeker.dipCount
					)
					AudioTagFieldseekerReportField(
						name: "Larvae",
						prompt: "# larvae",
						isDone: knowledge.hasLarvaeCount,
						value: knowledge.breeding.larvaeQuantity
					)
					AudioTagFieldseekerReportField(
						name: "Pupae",
						prompt: "# pupae",
						isDone: knowledge.hasPupaeCount,
						value: knowledge.breeding.pupaeQuantity
					)
					AudioTagFieldseekerReportField(
						name: "Eggs",
						prompt: "# eggs",
						isDone: knowledge.hasEggCount,
						value: knowledge.breeding.eggQuantity
					)
					AudioTagFieldseekerReportField(
						name: "Stage",
						prompt: "# Instar, adult",
						isDone: knowledge.hasStage,
						value: knowledge.breeding.stage
					)
					AudioTagFieldseekerReportField(
						name: "Genus",
						prompt: "genus",
						promptChoices: ["Aedes", "Culex"],
						isDone: knowledge.hasGenus,
						value: knowledge.breeding.genus
					)
					AudioTagFieldseekerReportField(
						name: "Conditions",
						prompt: "conditions",
						promptChoices: BreedingConditions.prompts,
						isDone: knowledge.hasConditions,
						value: knowledge.breeding.conditions
					)
				}
			}
		}
	}
}

struct AudioTagNidusFlow: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		Grid(horizontalSpacing: 1, verticalSpacing: 1) {
			AudioTagDriverRow(color: .brown, knowledge: knowledge)
			AudioTagRootRow(color: .purple, knowledge: knowledge)
			AudioTagFacilitatorRow(color: .blue, knowledge: knowledge)
			AudioTagSourceRow(color: .red, knowledge: knowledge)
			AudioTagBreedingRow(color: .orange, knowledge: knowledge)
		}

	}
}

struct AudioTagBreedingRow: View {
	let color: Color
	let knowledge: KnowledgeGraph

	var body: some View {
		if knowledge.impliesDriver {
			GridRow {
				/*AudioTagIcon(
					"number",
					color: knowledge.breeding.quantity != nil ? color : .gray
				)*/
				AudioTagIcon(
					"squares.leading.rectangle",
					color: knowledge.breeding.stage != nil ? color : .gray
				)
				AudioTagIconMajor("B", color: knowledge.hasBreeding ? color : .gray)
				AudioTagIcon(
					"ant",
					color: knowledge.breeding.genus != nil ? color : .gray
				)
				AudioTagIcon(
					"exclamationmark.triangle",
					color: knowledge.breeding.treatment != nil ? color : .gray
				)
			}
		}
		else {
			EmptyView()
		}
	}
}

struct AudioTagDriverRow: View {
	let color: Color
	let knowledge: KnowledgeGraph

	var body: some View {
		if knowledge.impliesDriver {
			GridRow {
				AudioTagIcon(
					"person",
					color: knowledge.driver.contact != nil ? color : .gray
				)
				AudioTagIconMajor("D", color: knowledge.hasDriver ? color : .gray)
				AudioTagIcon(
					"figure.stand.line.dotted.figure.stand",
					color: knowledge.driver.behaviorModification != nil
						? color : .gray
				)
			}
		}
		else {
			EmptyView()
		}
	}
}

struct AudioTagFacilitatorRow: View {
	let color: Color
	let knowledge: KnowledgeGraph

	var body: some View {
		if knowledge.impliesFacilitator {
			GridRow {
				AudioTagIcon(
					"point.topleft.down.to.point.bottomright.curvepath",
					color: knowledge.facilitator.pathToRootCause != nil
						? color : .gray
				)
				AudioTagIcon(
					"facemask",
					color: knowledge.facilitator.blocking != nil ? color : .gray
				)
				AudioTagIconMajor(
					"F",
					color: knowledge.hasFacilitator ? color : .gray
				)
				AudioTagIcon(
					"point.bottomleft.forward.to.point.topright.filled.scurvepath",
					color: knowledge.facilitator.pathToRootCause != nil
						? color : .gray
				)
			}
		}
		else {
			EmptyView()
		}
	}
}

struct AudioTagRootRow: View {
	let color: Color
	let knowledge: KnowledgeGraph

	var body: some View {
		if knowledge.impliesRootCause {
			GridRow {
				AudioTagIcon(
					"squareroot",
					color: knowledge.rootCause.fix != nil ? color : .gray
				)
				AudioTagIconMajor(
					"R",
					color: knowledge.hasRootCause ? color : .gray
				)
				AudioTagIcon(
					"sportscourt",
					color: knowledge.rootCause.legalAbatement != nil
						? color : .gray
				)
			}
		}
		else {
			EmptyView()
		}
	}
}

struct AudioTagSourceRow: View {
	let color: Color
	let knowledge: KnowledgeGraph

	var body: some View {
		if knowledge.impliesSource {
			GridRow {
				AudioTagIcon(
					"line.diagonal.arrow",
					color: knowledge.source.productionCapacity != nil
						? color : .gray
				)
				AudioTagIcon(
					"cube",
					color: knowledge.hasVolume ? .gray : .red
				)
				AudioTagIconMajor("S", color: knowledge.hasSource ? color : .gray)
				AudioTagIcon(
					"water.waves",
					color: knowledge.source.type != nil ? color : .gray
				)
				AudioTagIcon(
					"water.waves.and.arrow.trianglehead.up",
					color: knowledge.source.sourceElimination != nil
						? color : .gray
				)
				AudioTagIcon(
					"waterbottle.fill",
					color: knowledge.source.preemptiveTreatment != nil
						? color : .gray
				)
			}
		}
		else {
			EmptyView()
		}
	}
}

struct AudioTagIcon: View {
	let color: Color
	let systemName: String

	init(_ systemName: String, color: Color = .gray) {
		self.color = color
		self.systemName = systemName
	}

	var body: some View {
		ZStack {
			Circle().stroke(color, lineWidth: 3).frame(width: 30, height: 30)
			Image(systemName: systemName)
		}.padding(3)
	}
}

struct AudioTagIconMajor: View {
	let color: Color
	let letter: String

	init(_ letter: String, color: Color = .gray) {
		self.color = color
		self.letter = letter
	}
	var body: some View {
		ZStack {
			Circle().stroke(color, lineWidth: 3).frame(width: 40, height: 40)
			Text(letter)
		}.padding(3)
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
