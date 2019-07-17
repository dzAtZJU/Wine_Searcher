//
//  WIneFormReader.swift
//  Wine_Searcher
//
//  Created by Zhou Wei Ran on 2019/7/16.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation
import CSV

class RowsReader {
    
    init(csvReader: CSVReader, chateauItemParser: RowWineNameParser, vintageParser: RowVintageParser) {
        self.csvReader = csvReader
        self.chateauItemParser = chateauItemParser
        self.vintageParser = vintageParser
    }
    
    let csvReader: CSVReader
    
    let chateauItemParser: RowWineNameParser
    
    let vintageParser: RowVintageParser
    
    private var wineArray: [Wine]?
    
    func read() -> [Wine] {
        if let wineArray = wineArray {
            return wineArray
        }
        
        var ordinal = 0
        wineArray = [Wine]()
        while csvReader.next() != nil {
            let chateauItem = chateauItemParser.parse(from: csvReader)
            let vintages = vintageParser.parse(from: csvReader)
            for vintage in vintages {
                wineArray!.append(Wine(name: chateauItem, vintage: vintage, ordinal: ordinal))
                ordinal += 1
            }
        }
        return wineArray!
    }
}

