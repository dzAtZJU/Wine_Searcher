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
    case invalid
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
        var nameInURL = wine.name.replacingOccurrences(of: "[^(a-zA-ZÀ-ÿ0-9+)]", with: " ", options: .regularExpression, range: nil)
        nameInURL = nameInURL.components(separatedBy:.whitespacesAndNewlines).filter { $0.count > 0 }.joined(separator: " ")
        nameInURL = nameInURL.replacingOccurrences(of: "\\s", with: "+", options: .regularExpression, range: nil)
        
        let urlString = String(format: urlPattern, nameInURL, "/" + wine.vintage, location).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = URL(string: urlString) {
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
        print("[ERROR]: HTTP Request Fail. Code \(httpResponse.statusCode). Try to get neew Cookie")
        exit(-1)
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


let hMin = "H-MIN"
let cMin = "C-MIN"
let gAV = "G-AV"
let labelOrder = [cMin: 0, hMin: 1, gAV: 2]

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
            return cMin
        } else if self == "/hong+kong" {
            return hMin
        } else if self == "" {
            return gAV
        }
        return self
    }
}
