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
			AudioTagTableFieldseekerMosquitoSource(knowledge: knowledge)
		case .Inspection:
			AudioTagTableFieldseekerInspection(knowledge: knowledge)
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

struct AudioTagReportField: View {
	let name: String
	let prompt: String
	var promptChoices: [String] = []
	let isDone: Bool
	let value: String

	var font: Font { .system(size: 13) }
	var body: some View {
		GridRow(alignment: .top) {
			if isDone {
				Image(systemName: "checkmark.square")
				Text(name).font(font).gridColumnAlignment(.leading)
					.foregroundStyle(
						Color.primary.opacity(0.5)
					)
				Text(value).font(font).gridColumnAlignment(
					.leading
				).foregroundStyle(Color.primary.opacity(0.7))
			}
			else {
				Image(systemName: "square")
				Text(name).font(font).gridColumnAlignment(.leading)
					.foregroundStyle(Color.primary)
				if promptChoices.isEmpty {
					Text("\"\(prompt)\"").font(font).gridColumnAlignment(
						.leading
					)
				}
				else {
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
					}.frame(height: 150).border(Color.gray.opacity(0.3))
				}
			}
		}
	}
}

struct AudioTagTable: View {
	var fields: [AudioTagReportField] = []

	var fieldsComplete: [AudioTagReportField] {
		return fields.filter({ $0.isDone == true })
	}
	var fieldsIncomplete: [AudioTagReportField] {
		return fields.filter({ $0.isDone == false })
	}
	var body: some View {
		VStack {
			Grid(alignment: .topLeading) {
				AudioTagTableRows(fields: fieldsIncomplete)
				Spacer()
				AudioTagTableRows(fields: fieldsComplete)
			}
		}
	}
}
struct AudioTagTableRows: View {
	let fields: [AudioTagReportField]

	var body: some View {
		ForEach(Array(fields.enumerated()), id: \.offset) {
			i,
			field in
			GridRow {
				field
			}
		}
	}
}
struct AudioTagTableFieldseekerInspection: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		VStack {
			AudioTagFieldseekerReportType(
				name: "Inspection",
				isComplete: knowledge.isFieldseekerReportComplete
			)
			if !knowledge.isFieldseekerReportComplete {
				AudioTagTable(fields: [
					AudioTagReportField(
						name: "Condition",
						prompt: "green/blue/murky",
						promptChoices: [
							"green", "maintained", "dry", "murky",
						],
						isDone: knowledge.hasConditions,
						value: knowledge.breeding.conditions?.description
							?? "nil",
					),
					AudioTagReportField(
						name: "Breeding",
						prompt: "[not] breeding/larvae present",
						isDone: knowledge.impliesBreeding,
						value: knowledge.impliesBreeding.description,
					),
					AudioTagReportField(
						name: "Dip",
						prompt: "# dips",
						isDone: knowledge.hasDipCount,
						value: knowledge.fieldseeker.dipCount?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "",
						prompt: "# pupae",
						isDone: knowledge.hasPupaeCount,
						value: knowledge.breeding.pupaeQuantity?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Eggs",
						prompt: "# eggs",
						isDone: knowledge.hasEggCount,
						value: knowledge.breeding.eggQuantity?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Stage",
						prompt: "# Instar, adult",
						isDone: knowledge.hasStage,
						value: knowledge.breeding.stage?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Genus",
						prompt: "genus",
						promptChoices: ["Aedes", "Culex"],
						isDone: knowledge.hasGenus,
						value: knowledge.breeding.genus?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Fish",
						prompt: "fish [not] present",
						isDone: knowledge.hasConditions,
						value: knowledge.breeding.conditions?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Dimensions",
						prompt: "x meters by y meters",
						isDone: knowledge.hasSurfaceArea,
						value: knowledge.breeding.conditions?.description
							?? "nil"
					),
				])
			}
		}
	}
}
struct AudioTagTableFieldseekerMosquitoSource: View {
	let knowledge: KnowledgeGraph

	var body: some View {
		VStack {
			AudioTagFieldseekerReportType(
				name: "Mosquito Source",
				isComplete: knowledge.isFieldseekerReportComplete
			)
			if !knowledge.isFieldseekerReportComplete {
				AudioTagTable(fields: [
					AudioTagReportField(
						name: "Dip",
						prompt: "# dips",
						isDone: knowledge.hasDipCount,
						value: knowledge.fieldseeker.dipCount?.description
							?? "nil"
					),

					AudioTagReportField(
						name: "Larvae",
						prompt: "# larvae",
						isDone: knowledge.hasLarvaeCount,
						value: knowledge.breeding.larvaeQuantity?
							.description ?? "nil"
					),
					AudioTagReportField(
						name: "Pupae",
						prompt: "# pupae",
						isDone: knowledge.hasPupaeCount,
						value: knowledge.breeding.pupaeQuantity?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Eggs",
						prompt: "# eggs",
						isDone: knowledge.hasEggCount,
						value: knowledge.breeding.eggQuantity?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Stage",
						prompt: "# Instar, adult",
						isDone: knowledge.hasStage,
						value: knowledge.breeding.stage?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Genus",
						prompt: "genus",
						promptChoices: ["Aedes", "Culex"],
						isDone: knowledge.hasGenus,
						value: knowledge.breeding.genus?.description
							?? "nil"
					),
					AudioTagReportField(
						name: "Conditions",
						prompt: "conditions",
						promptChoices: BreedingConditions.prompts,
						isDone: knowledge.hasConditions,
						value: knowledge.breeding.conditions?.description
							?? "nil"
					),
				])
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
