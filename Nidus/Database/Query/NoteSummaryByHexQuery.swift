import SQLite

struct NoteSummary {
	let cell: UInt64
	let count: UInt
	let noteType: NoteType
	let resolution: UInt
}

func NoteSummaryByHexAll(_ connection: SQLite.Connection, cells: Set<H3Cell>, noteType: NoteType)
	throws -> [NoteSummary]
{
	let rows = try connection.prepare(
		schema.noteSummaryByHex.table.filter(
			SQLite.Expression<String>(value: noteType.toString())
				== schema.noteSummaryByHex.noteType
				&& cells.contains(schema.noteSummaryByHex.cell)
		)
	)
	return rows.map { row in
		NoteSummary(
			cell: row[schema.noteSummaryByHex.cell],
			count: UInt(row[schema.noteSummaryByHex.noteCount]),
			noteType: NoteType.fromString(row[schema.noteSummaryByHex.noteType])!,
			resolution: UInt(row[schema.noteSummaryByHex.cellResolution])
		)
	}
}

func NoteSummaryByHexDeleteAll(_ connection: SQLite.Connection) throws {
	let update = schema.noteSummaryByHex.table.delete()
	try connection.run(update)
}

func NoteSummaryByHexUpsert(
	_ connection: SQLite.Connection,
	cell: UInt64,
	cellResolution: UInt,
	noteCount: Int,
	noteType: NoteType
) throws {
	let upsert = schema.noteSummaryByHex.table.upsert(
		schema.noteSummaryByHex.cell <- SQLite.Expression<UInt64>(value: cell),
		schema.noteSummaryByHex.cellResolution
			<- SQLite.Expression<Int>(value: Int(cellResolution)),
		schema.noteSummaryByHex.noteCount <- SQLite.Expression<Int>(value: noteCount),
		schema.noteSummaryByHex.noteType
			<- SQLite.Expression<String>(value: noteType.toString()),
		onConflictOf: Expression<Void>(literal: "\"cell\", \"note_type\"")
	)
	try connection.run(upsert)
}
