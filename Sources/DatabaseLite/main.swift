import ArgumentParser
import Foundation
import Spreadsheet
import SQLite3


struct DatabaseLite: ParsableCommand {
    @Option(help:"Database Name")
    var name: String = "test.sqlite"
    
    func run() throws {
        print( "hello world + " + name )
    }
}

DatabaseLite.main()

