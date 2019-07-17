//
//  WineSheetParser.swift
//  Wine_Searcher
//
//  Created by Zhou Wei Ran on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation
import CSV

protocol RowWineNameParser {
    func parse(from: CSVReader) -> String
}

protocol RowVintageParser {
    func parse(from: CSVReader) -> [String]
}

struct WineNameParser1: RowWineNameParser {
    let chateauHeader: String
    
    let itemHeader: String
    
    func parse(from: CSVReader) -> String {
        return from[chateauHeader]! + " " + from[itemHeader]!
    }
}

struct WineNameParser2: RowWineNameParser {
    let header: String
    
    func parse(from: CSVReader) -> String {
        return from[header]!
    }
}

struct VintageParser1: RowVintageParser {
    let header: String
    
    func parse(from: CSVReader) -> [String] {
        return [from[header]!]
    }
}

struct VintageParser2: RowVintageParser {
    let header: String
    
    func parse(from: CSVReader) -> [String] {
        let field = from[header]!
        
        if field == "NV" {
            return [""]
        }
        
        let abbrVintages = field.split(separator: "/")
        var vintages = [String]()
        for abbrVintage in abbrVintages {
            let number = Int(abbrVintage)!
            let prefix = number < year20xxMax ? "20" : "19"
            vintages.append(prefix + String(abbrVintage))
        }
        return vintages
    }
}
