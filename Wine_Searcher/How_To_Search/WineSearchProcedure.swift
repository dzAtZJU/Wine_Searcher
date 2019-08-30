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

struct SearchProcedure4: SearchProcedure {
    
    static let shared = SearchProcedure4()
    
    func execute(_ wine: Wine, resultHost: WangYiLing, params: [String:Any]? = nil) {
        for location in URLPattern.markets1 {
            synchronizer.enter()
            let forAveragePrice = location == URLPattern.locationGlobal
            searchWine(wine, location: location, forAveragePrice: forAveragePrice) { (wineOffer, error, location, _) in
                appendResult(wine: wine, offer: wineOffer, location: location, error: error, resultHost: resultHost)
            }
        }
    }
}

let synchronizer = DispatchGroup()
let serialQueue = DispatchQueue(label: "aggregate batch results")
var n = 1
func appendResult(wine: Wine, offer: WineOffer?, location: String, error: SearchError?, resultHost: WangYiLing) {
    let searchResult = SearchReuslt(wine: wine, error: error, bestOffer: offer, location: location.mappedLocation)
    serialQueue.async {
        resultHost.searchReuslts.append(searchResult)
        print(n)
        n += 1
        synchronizer.leave()
    }
}
