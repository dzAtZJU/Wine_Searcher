//
//  main.swift
//  Wine_Searcher
//
//  Created by 周巍然 on 2019/7/17.
//  Copyright © 2019 Paper Scratch. All rights reserved.
//

import Foundation
import CSV

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
        searchReuslts.sort { (a, b) -> Bool in
            return a.wine.ordinal < b.wine.ordinal
        }
        merchantSpecificWorkFlow.rowsWriter.write(searchReuslts, csvWriter: csvWriter)
    }
}

// CSV 格式的预处理之后的酒单
let sheetFile = "/Users/zhouweiran/Desktop/Offer 28-08-2019 LBV 3/Offer-Table 1.csv"//CommandLine.arguments[1]
// 使用的 Workflow (表单分析方法和酒价查询方法), see code in MerchantSpecificWorkFlow.swift
let chateauName = "query_3_markets"//CommandLine.arguments[2]
// 查询结果文件的位置
let outputFilePath = "/Users/zhouweiran/Desktop/xindewenjian.csv"//CommandLine.arguments[3]
// wine-searcher 网站的 cookie
let cookie = "cookie_enabled=true; visit=6MS3CK30D7300D5%7C20190707125544%7C%2Ffind%2Fde%2Bbeaucastel%2Bcoudoulet%2Bcote%2Bdu%2Brhone%2Bfrance%2F2016%2Fchina%7C%7Cend+; _csrf=gQrVm6ph9t0IygvBxi-KOnV2PT1dAYcC; _pxvid=2bac3565-a0ae-11e9-87de-0242ac12000d; COOKIE_ID=6MS3CK30D7300D5; geoinfo=31.0449|121.4012|Shanghai|China|CN|218.79.175.211|1796236|IP|Shanghai%2C+China; __gads=ID=58e32773d20e508f:T=1562500559:S=ALNI_Maf2rg0XF_zjmBbxap_iWKE60g96Q; OX_plg=pm; cookie_enabled=true; ID=CTVMC5XRDSM003Q; IDPWD=I42099223; _gid=GA1.2.1815533492.1567094195; _pxhd=e7bdf73be7ff433ab42ada4ae5fe7062911b0a03be11395a120c0bc5d093d0c1:f2e93a30-ca7b-11e9-bd30-e3e2be03704d; __pxvid=01874b92-ca7c-11e9-a7ce-0242ac110003; search=start%7Cchassagne-montrachet%2Bchateau%2Bde%2Bla%2Bmaltroye%7C1%7Cany%7CCNY%7C%7C%7C%7C%7C%7C%7C%7C%7Ce%7Cend; _pxff_tm=1; _gat_UA-216914-1=1; _ga=GA1.1.1432282382.1562500558; _ga_M0W3BEYMXL=GS1.1.1567124746.2.1.1567126287.0; _px3=47d524b56abda2a53170c03794c56edf1b877b04284551ccc91d987ceae8c517:AEE4sy8NohBfID/4Lc0HhFD6blmo29FNGPhRe7F3inD3G+QJDRb3c2fEh66X6/FcUo2o6DphEjAshBUbxLlgXA==:1000:LoYEamIJrpf498bh6Cxg7AQ0QJyeXWvDNz4Simq8qDM0OZczy64ywcukwdAkBJ5JPPMnzaSrO24Z0oI8DeKuMeexHLq33swRW4PQzO3VwRB/g1dobLrZ+1eS5x3Lab/0AenamCaV0G+Qlba4nae71x0RKjY8GoEKmcHxY0QhO58=; _pxde=6cad7fe76e4ff541ead1506b9c00b704360a7ed2042a847ca3942b8cd0b5ad16:eyJ0aW1lc3RhbXAiOjE1NjcxMjYyODg5MzUsImZfa2IiOjAsImlwY19pZCI6W119; fflag=FLAG_AA_BUCKET_CKY:0,FLAG_STORE_MANAGER:0,FLAG_FIND_EXP_BIG_LABEL:1,end"// //CommandLine.arguments[4]

let wangYiLin = WangYiLing(sheetFile: sheetFile, chateauName: chateauName, outputFilePath: outputFilePath)
wangYiLin.work()
