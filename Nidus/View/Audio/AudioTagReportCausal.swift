import SwiftUI

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
