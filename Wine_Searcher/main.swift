//
//  main.swift
//  Wine_Searcher
//
//  Created by 周巍然 on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation
import CSV

let synchronizer = DispatchGroup()

let serialQueue = DispatchQueue(label: "aggregate batch results")

class WangYiLing {
    
    let sheetFile: String
    
    let chateauName: String
    
    let outputFilePath: String
    
    let merchantSpecificWorkFlow: MerchantSpecificWorkFlow
    
    init(sheetFile: String, chateauName: String, outputFilePath: String) {
        self.sheetFile = sheetFile
        self.chateauName = chateauName
        self.outputFilePath = outputFilePath
        merchantSpecificWorkFlow = merchant2WorkFlow[chateauName]!
    }
    
    var wineArray: [Wine]? = nil
    
    var searchReuslts = [SearchReuslt]()
    
    func work() {
        readRows()
        searchRows()
        writeRows()
    }
    
    func preprocessSheet() {
    }
    
    func readRows() {
        let csvReader = try! CSVReader(stream: InputStream(fileAtPath: sheetFile)!, hasHeaderRow: true)
        let rowsReader = RowsReader(csvReader: csvReader, chateauItemParser: merchantSpecificWorkFlow.wineNameParser, vintageParser: merchantSpecificWorkFlow.vintageParser)
        wineArray = rowsReader.read()
    }
    
    func searchRows() {
        for wine in wineArray! {
            merchantSpecificWorkFlow.searchProcedure.execute(wine, resultHost: self, params: nil)
            Thread.sleep(forTimeInterval: 0.1)
        }
        synchronizer.wait()
    }
    
    func writeRows() {
        FileManager.default.createFile(atPath: outputFilePath, contents: nil, attributes: nil)
        let outputStream = OutputStream(toFileAtPath: outputFilePath, append: false)!
        let csvWriter = try! CSVWriter(stream: outputStream)
        
        merchantSpecificWorkFlow.rowsWriter.write(searchReuslts, csvWriter: csvWriter)
    }
}


let sheetFile = "/Users/zhouweiran/Desktop/haopu.csv"//CommandLine.arguments[1]
let chateauName = "haopu"//CommandLine.arguments[2]
let outputFilePath = "/Users/zhouweiran/Desktop/haopu_result.csv"//CommandLine.arguments[3]
let cookie = "cookie_enabled=true; _ga=GA1.2.1855909706.1562562891; _gat_UA-216914-1=1; _gid=GA1.2.1293813888.1563330847; _px3=9f1578e9265b0436629c09f89cde2ad186ea1ee0b05b8821b469bdad9cde1e96:4HWo853HwIcpVhVwI2jSEsdoy3wB+/Y5+5Po9wiwSaKleV4qtiHWOjWSrL/sSQYxwJfcswuwEjy6Zzb5P6hl3w==:1000:xdwbPCFWnMbCC0KDCoR3yQUpkhpMImbWpJhPA5X6XkQhpeOMtL8ZtrpceTbSl8Thhq6hwgPTgKI5CBE0B/EzBoIEOa75Ju5ZvBKSG3aeGZxEMDlBrkBLupwJi1IPNBRWVSS7m0F5YIkZEnIDZPNiMZk6xjvvy6CAFZMCPPfXEv4=; _pxde=c37c4e67e2ff464a812f4f1469b0f49f92a0d9b47c5a241eff85183521f2c72d:eyJ0aW1lc3RhbXAiOjE1NjMzNDU4MzE1NzcsImlwY19pZCI6W119; fflag=flag_store_manager%3A0%2Cend; cookie_enabled=true; _pxhd=abe8a15a688d16eeaedd4497d65c3fba5136796a7f9035afb5965e6af725160a:39fc8c41-a30f-11e9-bbb0-b59bf048f68a; search=start%7Cmorgenster%2Blourens%2Briver%2Bvalley%7C2005%7C%7CCNY%7C%7C%7C%7C%7C%7C%7C%7C%7Ce%7Cend; __gads=ID=da16b9c3405ca065:T=1562562890:RT=1563330848:S=ALNI_MbwgUsBoOrncw7kfQRJu5XoxTNpXw; ID=3Z7JCD1BDGL001F; IDPWD=I74884208; x=1; _csrf=k9yGTOjZO6vWzdSK0pgDZPzSWq2-UIcN; cto_lwid=363e93ca-d43a-4709-95ad-de4ea52562b5; OX_plg=swf|shk|pm; _pxvid=4efeee1b-a13f-11e9-81e1-0242ac12000a; geoinfo=30.6667|104.0667|Chengdu|China|CN|47.244.156.35|1815286|IP|Chengdu%2C+China; visit=JN53CR1CDZQ0011|20190708061446|ws-api.lml|https%3A%2F%2Fwww.google.com%2F|end; COOKIE_ID=JN53CR1CDZQ0011"// //CommandLine.arguments[4]

let wangYiLin = WangYiLing(sheetFile: sheetFile, chateauName: chateauName, outputFilePath: outputFilePath)
wangYiLin.work()
