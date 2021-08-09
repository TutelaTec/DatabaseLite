import ArgumentParser
import Foundation
import Spreadsheet
import SQLite3

struct Experiment: DLTablable {
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
    
    func inspect() -> String {
        let toStr = StringsEncoder()
        let str = try? toStr.encode(self)
        return type(of: self).tableName + " : " + (str ?? "-- error --")
    }
}

struct DatabaseLite: ParsableCommand {
    @Option(help:"Database Name")
    var name: String = "test.sqlite"
    
    func run() throws {
        DLLogging.log(.debug(.low), "Hello World")
        
        let fm = FileManager.default
        try? fm.removeItem(atPath: name)
                
        do {
            
            let db = try DLDatabase(atPath: name)
            try db.create(tableFor: Experiment.self)
            
            var exp = Experiment(rowId: 1, timestamp: 2000, download: 300.0, upload: 200.0, status: "Success")
            try db.insert(&exp)
            
            let other = try db.select(tableFor: Experiment.self, whereRowId: 1)
            if let other = other {
                print( other.inspect() )
            }
            //print( other.inspect() )

        }
        catch {
            print("failed: \(error)")
        }
        
    }
}

DatabaseLite.main()

