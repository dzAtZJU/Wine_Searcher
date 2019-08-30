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
    
    let vintageParser: RowVintageParser?
    
    let searchProcedure: SearchProcedure
    
    let rowsWriter: RowsWriter
}

let merchant2WorkFlow = ["query_3_markets": MerchantSpecificWorkFlow(wineNameParser: WineNameParser1(chateauHeader: "Producer", itemHeader: "Wine Name"),
                                                                     vintageParser: VintageParser1(header: "Vintage"),
                                                                     searchProcedure: SearchProcedure4.shared,
                                                                     rowsWriter: RowsWriter3.shared),
                         "haopu": MerchantSpecificWorkFlow(wineNameParser: WineNameParser2(header: "英⽂品名"),
                                                           vintageParser: VintageParser2(header: "年份"),
                                                           searchProcedure: SearchProcedure3.shared,
                                                           rowsWriter: RowsWriter2.shared),
                         "haopu_all_markets": MerchantSpecificWorkFlow(wineNameParser: WineNameParser2(header: "英⽂品名"),
                                                                       vintageParser: VintageParser2(header: "年份"),
                                                                       searchProcedure: SearchProcedure4.shared,
                                                                       rowsWriter: RowsWriter3.shared),
                         "month_selection": MerchantSpecificWorkFlow(wineNameParser: WineNameParser2(header: "商品"),
                                                                     vintageParser: nil,
                                                                     searchProcedure: SearchProcedure3.shared,
                                                                     rowsWriter: RowsWriter2.shared)]
