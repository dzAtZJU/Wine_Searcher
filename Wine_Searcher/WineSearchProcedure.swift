//
//  WineSearchProcedure.swift
//  Wine_Searcher
//
//  Created by Zhou Wei Ran on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation

func searchProcedure3(_ wine: Wine) {
    searchWine(wine, location: URLPattern.locationGlobal, forAveragePrice: true) { (offer, error, _, _) in
        <#code#>
    }
}
