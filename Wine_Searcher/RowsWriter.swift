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
