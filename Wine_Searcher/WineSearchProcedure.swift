//
//  WineSearchProcedure.swift
//  Wine_Searcher
//
//  Created by Zhou Wei Ran on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation

protocol SearchProcedure {
    func execute(_ wine: Wine, resultHost: WangYiLing, params: [String:Any]?)
}

struct SearchProcedure3: SearchProcedure {
    
    static let shared = SearchProcedure3()
    
    func execute(_ wine: Wine, resultHost: WangYiLing, params: [String:Any]? = nil) {
        synchronizer.enter()
        searchWine(wine, location: URLPattern.locationGlobal, forAveragePrice: true) { (wineOffer, error, location, _) in
            appendResult(wine: wine, offer: wineOffer, location: location, error: error, resultHost: resultHost)
        }
    }
}
