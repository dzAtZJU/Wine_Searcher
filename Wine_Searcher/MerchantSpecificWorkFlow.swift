//
//  configurations.swift
//  Wine_Searcher
//
//  Created by Zhou Wei Ran on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation

let year20xxMax = 22

struct MerchantSpecificWorkFlow {
    let wineNameParser: RowWineNameParser
    
    let vintageParser: RowVintageParser
    
    let searchProcedure: SearchProcedure
    
    let rowsWriter: RowsWriter
}

let merchant2WorkFlow = ["haopu": MerchantSpecificWorkFlow(wineNameParser: WineNameParser2(header: "英⽂品名"), vintageParser: VintageParser2(header: "年份"), searchProcedure: SearchProcedure3.shared, rowsWriter: RowsWriter2.shared)]
