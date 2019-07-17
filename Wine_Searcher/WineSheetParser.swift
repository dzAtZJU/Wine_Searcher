//
//  WineSheetParser.swift
//  Wine_Searcher
//
//  Created by Zhou Wei Ran on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation
import CSV

protocol RowChateauItemParser {
    func parse(from: CSVReader) -> String
}

protocol RowVintageParser {
    func parse(from: CSVReader) -> [String]
}

struct ChateauItemParser1: RowChateauItemParser {
    let chateauHeader: String
    
    let itemHeader: String
    
    func parse(from: CSVReader) -> String {
        return csvReader[chateauHeader]! + " " + csvReader[itemHeader]!
    }
}

struct ChateauItemParser2: RowChateauItemParser {
    let header: String
    
    func parse(from: CSVReader) -> String {
        return csvReader[header]!
    }
}

struct VintageParser1: RowVintageParser {
    let header: String
    
    func parse(from: CSVReader) -> [String] {
        return [csvReader[header]!]
    }
}

struct VintageParser2: RowVintageParser {
    let header: String
    
    func parse(from: CSVReader) -> [String] {
        let abbrVintages = csvReader[header]!.split(separator: "/")
        var vintages = [String]()
        for abbrVintage in abbrVintages {
            let number = Int(abbrVintage)!
            let prefix = number < year20xxMax ? "20" : "19"
            vintages.append(prefix + String(abbrVintage))
        }
        return vintages
    }
}
