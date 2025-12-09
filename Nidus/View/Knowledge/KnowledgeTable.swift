import SwiftUI

struct KnowledgeTable: View {
	var title: String
	var fields: [KnowledgeField] = []

	var fieldsComplete: [KnowledgeField] {
		return fields.filter({ $0.isDone == true })
	}
	var fieldsIncomplete: [KnowledgeField] {
		return fields.filter({ $0.isDone == false })
	}
	var headerIncomplete: some View {
		Text("\(title) - \(fields.count - fieldsComplete.count) needed")
	}
	var headerComplete: some View {
		Text("\(fieldsComplete.count)/\(fields.count) done")
	}
	var body: some View {
		List {
			Section(header: headerIncomplete) {
				KnowledgeTableRows(fields: fieldsIncomplete)
			}
			if fieldsComplete.isEmpty {
				EmptyView()
			}
			else {
				Section(header: headerComplete) {
					KnowledgeTableRows(fields: fieldsComplete)
				}
			}
		}
	}
}
private struct KnowledgeTableRows: View {
	let fields: [KnowledgeField]

	var body: some View {
		ForEach(Array(fields.enumerated()), id: \.offset) {
			i,
			field in
			field
		}
	}
}
