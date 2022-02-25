import XCTest
@testable import DatabaseLite

extension Int {
    var randomRoll : Int {
        if self > 0 {
            return (1 ... self).randomElement() ?? 0
        }
        else if self < 0 {
            return (self ... -1).randomElement() ?? 0
        }
        return 0
    }
}

extension Double {
    var randomRoll : Double {
        if self > 1 {
            return Double(Int(self).randomRoll)
        }
        return 0
    }
}

extension String {
    static func randomRoll(_ opts: [String]) -> String {
        return opts.randomElement() ?? "Oops"
    }
}


struct TestTable: DLTablable {
    var rowId: RowId = .invalid
    let timestamp: Int
    let download: Double
    let upload: Double
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case rowId = "_id"
        case timestamp = "Q0"
        case download = "T1"
        case upload = "T2"
        case status = "S"
    }
    
    public func inspect() -> String {
        let toStr = StringsEncoder()
        let str = try? toStr.encode(self)
        return type(of: self).tableName + " : " + (str ?? "-- error --")
    }

    static func make() -> TestTable {
        TestTable(rowId: .toBeDefined, timestamp: 2000.randomRoll, download: 300.0.randomRoll, upload: 200.0.randomRoll, status: String.randomRoll(["Success", "Failure"]))
    }
}

extension TestTable: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rowId == rhs.rowId && lhs.timestamp == rhs.timestamp && lhs.download == rhs.download && lhs.upload == rhs.upload && lhs.status == rhs.status
    }
}
  


final class DatabaseLiteTests: XCTestCase {
    var databaseName = "DatabaseLiteTests.sqlite"
    
    override func setUpWithError() throws {
        try? FileManager.default.removeItem(atPath: databaseName)
    }
    
    public func testBasic() throws {
        DLLogging.log(.debug(.low), "Hello World")
                        
        let db = try DLDatabase(atPath: databaseName)
        try db.create(tableFor: TestTable.self)
        
        var exp = TestTable.make()
        try db.insert(&exp)
        
        let other = try db.select(tableFor: TestTable.self, whereRowId: exp.rowId)
        XCTAssertNotNil(other)
        if let other = other {
            print( other.inspect() )
            
            XCTAssertEqual(exp.rowId, other.rowId)
            XCTAssertEqual(exp.timestamp, other.timestamp)
            XCTAssertEqual(exp.download, other.download)
            XCTAssertEqual(exp.upload, other.upload)
            XCTAssertEqual(exp.status, other.status)
        }
    }
    
    public func testRowIds() throws {
        let db = try DLDatabase(atPath: databaseName)
        try db.create(tableFor: TestTable.self)
        
        let howMany = 100
        
        for _ in 1 ... howMany {
            var exp = TestTable.make()
            try db.insert(&exp)
        }
        
        let rowIds = try db.select(rowIdsForTable: TestTable.self)
        XCTAssertEqual( howMany, rowIds.count)
        
        let row0 = rowIds.randomElement()!
        let it0 = try db.fetch(forTable: TestTable.self, whereRowId: row0)
        XCTAssertEqual( it0.rowId, row0)
        XCTAssertEqual( it0, try db.fetch(forTable: TestTable.self, whereRowId: row0))
        
        for rowId in rowIds {
            _ = try db.fetch(forTable: TestTable.self, whereRowId: rowId)
        }
        
        for rowId in rowIds {
            let cached = try db.fetch(forTable: TestTable.self, whereRowId: rowId)
            let selected = try db.select(tableFor: TestTable.self, whereRowId: rowId)
            XCTAssertEqual(cached, selected)
        }

    }
}
