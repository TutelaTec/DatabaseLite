import ArgumentParser
import Foundation
import Spreadsheet
import SQLite3

struct Experiment: Codable, DLTablable {
    let rowId: Int 
    let timestamp: Int
    let download: Double
    let upload: Double?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case rowId = "_id"
        case timestamp = "Q0"
        case download = "T1"
        case upload = "T2"
        case status = "S"
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
            
        }
        catch {
            print("failed: \(error)")
        }
        
    }
}

DatabaseLite.main()

