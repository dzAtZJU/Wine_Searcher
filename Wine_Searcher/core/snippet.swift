//
//  snippet.swift
//  Wine_Searcher
//
//  Created by Zhou Wei Ran on 2019/8/30.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

//let synchronizer = DispatchGroup()
//var batchResults = [SearchReuslt]()
//let serialQueue = DispatchQueue(label: "aggregate batch results")
//
////func searchWineProcedure1(_ wine: Wine) {
////    searchWine(wine, location: URLPattern.markets1[0], forAveragePrice: false) { (wineOffer, error, location) in
////        if let error = error, case .noOffer = error {
////            searchWine(wine, location: URLPattern.markets1[1], forAveragePrice: false) { (wineOffer, error, location) in
////                if let error = error, case .noOffer = error {
////                    searchWine(wine, location: URLPattern.markets1[2], forAveragePrice: true){ (wineOffer, error, location) in
////                        appendResult(wine: wine, offer: wineOffer, location: location, error: error)
////                    }
////                } else {
////                    appendResult(wine: wine, offer: wineOffer, location: location, error: error)
////                }
////            }
////        } else {
////            appendResult(wine: wine, offer: wineOffer, location: location, error: error)
////        }
////    }
////}
//
//func searchWineProcedure2(_ wine: Wine, times: Int, max: Int) {
//    if times == max {
//        return
//    }
//    synchronizer.enter()
//    searchWine(wine, location: URLPattern.markets1[times], forAveragePrice: times == max - 1) { (wineOffer, error, location, offerNums) in
//        if let error = error, case .noOffer = error {
//            if times == max - 1 {
//                appendResult(wine: wine, offer: wineOffer, location: location, error: error)
//            } else {
//                searchWineProcedure2(wine, times: times + 1, max: max)
//                synchronizer.leave()
//            }
//        } else if let wineOffer = wineOffer, offerNums! == 1 {
//            appendResult(wine: wine, offer: wineOffer, location: location, error: error)
//            searchWineProcedure2(wine, times: times + 1, max: max)
//        } else {
//            appendResult(wine: wine, offer: wineOffer, location: location, error: error)
//        }
//    }
//}
//
//let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
//
//var wineArray = [Wine]()
////
//let inputPath = desktopPath + "/wine_to_search.csv"
//let inputStream = InputStream(fileAtPath: inputPath)!
//let csvReader = try! CSVReader(stream: inputStream, hasHeaderRow: true)
//var order = 0
//while csvReader.next() != nil {
//    let name = "\(csvReader["Brand English"]!) \(csvReader["Item English"]!)".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\'", with: "")
//    let vintage = "\(csvReader["Vintage"]!)"
//    wineArray.append(Wine(name: name, vintage: vintage, ordinal: order))
//    order += 1
//}
//
////wineArray.append(Wine(name: "Jayer (Lucien) Echezeaux grand cru", vintage: "1978"))
//
//for wine in wineArray {
//    searchWineProcedure2(wine, times:0 , max: 3)
//    Thread.sleep(forTimeInterval: 0.1)
//}
//synchronizer.wait()
//
//let wineName2SearchResult = Dictionary(grouping: batchResults) { (searchResult: SearchReuslt) -> String in
//    return String(searchResult.wine.ordinal)
//}
//
//
//let outputPath = desktopPath + "/wine_search_output_" + String(Int(Date().timeIntervalSince1970)) + ".csv"
//let isCreated = FileManager.default.createFile(atPath: outputPath, contents: nil, attributes: nil)
//let outputStream = OutputStream(toFileAtPath: outputPath, append: false)!
//let csv = try CSVWriter(stream: outputStream)
//try! csv.write(row: ["下一步操作","年份", "酒名(查询)", "酒名(实际)", "价格", "地区", "价格", "地区", "价格", "地区"])
//
//for group in wineName2SearchResult.values {
//
//    var priceLocations = [(String,String)]()
//    var state = "比较酒名"
//    var wineName = ""
//    var vintage = ""
//    var searchName = ""
//    for searchResult in group {
//        wineName = searchResult.wine.name
//        vintage = searchResult.wine.vintage
//
//        if let error = searchResult.error {
//            state = "手动查询 \(error)"
//            break
//        }
//
//        searchName = searchResult.bestOffer!.name.replacingOccurrences(of: ",", with: " ")
//
//        let csvLcoation = locationCSVFrom(search: searchResult.location)
//        var csvPrice = searchResult.bestOffer!.price.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "¥", with: "")
//        if let dotIndex = csvPrice.firstIndex(of: ".") {
//            csvPrice = String(csvPrice[csvPrice.startIndex..<dotIndex])
//        }
//
//        priceLocations.append((csvLcoation, csvPrice))
//    }
//
//    csv.beginNewRow()
//    try! csv.write(field: state)
//    try! csv.write(field: vintage)
//    try! csv.write(field: wineName)
//    try! csv.write(field: searchName)
//    for priceLocation in priceLocations {
//        try! csv.write(field: priceLocation.0)
//        try! csv.write(field: priceLocation.1)
//    }
//}
//
////for result in batchResults {
////    var state = "比较酒名"
////    if let error = result.error {
////        state = "手动查询 \(error)"
////    }
////
////    var beautifulLocation = result.location
////    if beautifulLocation == "/china" {
////        beautifulLocation = "C-MIN"
////    } else if beautifulLocation == "/hong+kong" {
////        beautifulLocation = "H-MIN"
////    } else if beautifulLocation == "" {
////        beautifulLocation = "G-AV"
////    }
////
////    var price = (result.bestOffer?.price ?? "").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "¥", with: "")
////    if let dotIndex = price.firstIndex(of: ".") {
////        price = String(price[price.startIndex..<dotIndex])
////    }
////
////    try! csv.write(row: [state, result.wine.vintage, result.wine.name, (result.bestOffer?.name ?? "").replacingOccurrences(of: ",", with: " "), price, beautifulLocation])
////}
//csv.stream.close()
