import SQLite

/*
extension UInt64: Number, Value {

	public static let declaredDatatype = Blob.declaredDatatype

	public static func fromDatatypeValue(_ datatypeValue: Blob) -> UInt64 {
        return 0
		guard datatypeValue.bytes.count >= MemoryLayout<UInt64>.size else { return 0 }
		let bigEndianUInt64 = datatypeValue.bytes.withUnsafeBytes({
			$0.load(as: UInt64.self)
		})
		return UInt64(bigEndian: bigEndianUInt64)
	}

	public var datatypeValue: Blob {
		var bytes: [UInt8] = []
		withUnsafeBytes(of: self) { pointer in
			// little endian by default on iOS/macOS, so reverse to get bigEndian
			bytes.append(contentsOf: pointer.reversed())
		}
		return Blob(bytes: bytes)
	}

}
*/

extension UInt64: Value {
	public static func fromDatatypeValue(_ datatypeValue: SQLite.Blob) throws -> UInt64 {
		guard datatypeValue.bytes.count >= MemoryLayout<UInt64>.size else { return 0 }
		let bigEndianUInt64 = datatypeValue.bytes.withUnsafeBytes({
			$0.load(as: UInt64.self)
		})
		return UInt64(bigEndian: bigEndianUInt64)
	}

	public var datatypeValue: SQLite.Blob {
		var bytes: [UInt8] = []
		withUnsafeBytes(of: self) { pointer in
			// little endian by default on iOS/macOS, so reverse to get bigEndian
			bytes.append(contentsOf: pointer.reversed())
		}
		return Blob(bytes: bytes)
	}

	public typealias Datatype = Blob

	public static var declaredDatatype: String {
		Blob.declaredDatatype
	}

}
