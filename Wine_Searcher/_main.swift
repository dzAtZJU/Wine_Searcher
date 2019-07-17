////
////  main.swift
////  WinePriceCrawler
////
////  Created by 周巍然 on 2019/7/8.
////  Copyright © 2019 周巍然. All rights reserved.
////
//
import Foundation
import SwiftSoup
import CSV

struct Wine {
    let name: String
    let vintage: String
    let ordinal: Int
}

struct WineOffer {
    let price: String
    let name: String
}

enum SearchError {
    case badUrl
    case tcp(Error)
    case server(String)
    case parse(Error)
    case noOffer
}

struct SearchReuslt {
    let wine: Wine
    let error: SearchError?
    let bestOffer: WineOffer?
    let location: String
}

struct URLPattern {

    // name, vintage, location
    static let urlPattern = "https://www.wine-searcher.com/find/%@%@%@/-/u"

    static let markets1 = ["/china", "/hong+kong", ""]

    static let markets2 = ["/hong+kong", ""]

    static let locationGlobal = ""

    static func urlFor(wine: Wine, location: String) -> URLRequest? {
        let nameInURL = wine.name.replacingOccurrences(of: "[\'’/\\d]", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: " ", with: "+")
        if let url = URL(string: String(format: urlPattern, nameInURL, "/" + wine.vintage, location)) {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            return request
        }

        return nil
    }
}

func searchWine(_ wine: Wine, location: String, forAveragePrice: Bool, completion: @escaping (WineOffer?, SearchError?, String, Int?) -> ()) {
    guard let request = URLPattern.urlFor(wine: wine, location: location) else {
        completion(nil, .badUrl, location, nil)
        return
    }

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        let url = request.url?.absoluteString
        if let searchError = checkResponse(data: data, response: response, error: error) {
            completion(nil, searchError, location, nil)
            return
        }

        guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
            completion(nil, .server("bad html"), location, nil)
            return
        }

        do {
            let doc = try parse(htmlString)
            let (wineOffer, searchError, offerNums) = parseDoc(doc, forAveragePrice: forAveragePrice)
            completion(wineOffer, searchError, location, offerNums)
        } catch {
            completion(nil, .server("bad html"), location, nil)
        }
    }

    task.resume()
}

func checkResponse(data: Data?, response: URLResponse?, error: Error?) -> SearchError? {
    if let error = error {
        return .tcp(error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
        return .server("no response")
    }

    guard (200...299).contains(httpResponse.statusCode) else {
        return .server(String(httpResponse.statusCode))
    }

    guard httpResponse.mimeType == "text/html" else {
        return .server("mime error")
    }

    return nil
}

func parseDoc(_ doc: Document, forAveragePrice: Bool) -> (WineOffer?, SearchError?, Int?) {
    do {
        if forAveragePrice {
            if let name = try! doc.select("#top_header > span").first()?.text() ,let averagePrice = try! doc.select(".sidepanel-text > b").first()?.text(), averagePrice.contains("¥") {
                return (WineOffer(price: averagePrice.filterdPrice, name: name.filterdName), nil, 10)
            } else {
                return (nil, .noOffer, nil)
            }
        }

        // name
        var name = ""
        if let nameElement = try! doc.select("span.offer_winename").first() {
            name = try nameElement.text()
        } else {
            return (nil, .noOffer, nil)
        }

        var price1 = ""
        // Price
        let priceElements = try! doc.select(".offer_price")
        let offerNums = priceElements.array().count
        if let priceElement = priceElements.first() {
            if let unitPriceElement = try! priceElement.parent()!.select(".ebp-price").first() {
                price1 = try! unitPriceElement.text()
            } else {
                price1 = try! priceElement.child(1).text()
            }
        }


        return (WineOffer(price: price1.filterdPrice, name: name.filterdName), nil, offerNums)
    } catch {
        return (nil, .parse(error), nil)
    }
}
//
//let synchronizer = DispatchGroup()
//var batchResults = [SearchReuslt]()
//let serialQueue = DispatchQueue(label: "aggregate batch results")

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

extension String {
    var filterdPrice: String {
        let price = replacingOccurrences(of: "[,¥]", with: "", options: .regularExpression, range: nil)
    
        if let dotIndex = price.firstIndex(of: ".") {
            return String(price[price.startIndex..<dotIndex])
        } else {
            return price
        }
    }
    
    var filterdName: String {
        return replacingOccurrences(of: ",", with: " ")
    }
    
    var mappedLocation: String {
        if self == "/china" {
            return "C-MIN"
        } else if self == "/hong+kong" {
            return "H-MIN"
        } else if self == "" {
            return "G-AV"
        }
        return self
    }
}
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
