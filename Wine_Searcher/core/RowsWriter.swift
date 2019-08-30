//
//  RowsWriter.swift
//  Wine_Searcher
//
//  Created by 周巍然 on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation
import CSV

protocol RowsWriter {
    func write(_ searchResults: [SearchReuslt], csvWriter: CSVWriter)
}

struct RowsWriter2: RowsWriter {
    static let shared = RowsWriter2()
    
    func write(_ searchResults: [SearchReuslt], csvWriter: CSVWriter) {
        try! csvWriter.write(row: ["下一步操作","年份", "酒名(查询)", "酒名(实际)", "价格", "地区"])
        
        for searchResult in searchResults {
            if let error = searchResult.error {
                let state = "手动查询 \(error)"
                try! csvWriter.write(row: [state, searchResult.wine.vintage, searchResult.wine.name, "", "", "G-AV"])
                continue
            }
            
            try! csvWriter.write(row: ["比较酒名", searchResult.wine.vintage, searchResult.wine.name, searchResult.bestOffer!.name, searchResult.bestOffer!.price ,searchResult.location])
        }
    }
}

struct RowsWriter3: RowsWriter {
    static let shared = RowsWriter3()
    
    func write(_ searchResults: [SearchReuslt], csvWriter: CSVWriter) {
        try! csvWriter.write(row: ["年份", "酒名(查询)", "酒名(实际)", "价格", "地区", "价格", "地区", "价格", "地区"])
        
        let groups = Dictionary(grouping: searchResults) { (result: SearchReuslt) -> Int in
            return result.wine.ordinal
        }
        let orderedGroups = groups.sorted { a, b in
            a.key < b.key
        }
        for group in orderedGroups {
            
            var priceLocations = [(String,String)]()
            var wineName = ""
            var vintage = ""
            var searchName = ""
            for searchResult in group.value {
                wineName = searchResult.wine.name
                vintage = searchResult.wine.vintage
        
                var price = ""
                if let error = searchResult.error {
                    price = "\(error)"
                } else {
                    price = searchResult.bestOffer!.price
                    searchName = searchResult.bestOffer!.name
                }
        
                priceLocations.append((searchResult.location.mappedLocation, price))
            }
        
            csvWriter.beginNewRow()
            try! csvWriter.write(field: vintage)
            try! csvWriter.write(field: wineName)
            try! csvWriter.write(field: searchName)
            priceLocations.sort {
                labelOrder[$0.0]! < labelOrder[$1.0]!
            }
            for priceLocation in priceLocations {
                try! csvWriter.write(field: priceLocation.0)
                try! csvWriter.write(field: priceLocation.1)
            }
        }
    }
}
