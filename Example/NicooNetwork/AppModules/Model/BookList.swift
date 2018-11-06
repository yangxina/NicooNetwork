//
//  BookList.swift
//  CloudLibrarySwift
//
//  Created by Zhangyao on 25/3/2016.
//  Copyright © 2016 TZPT. All rights reserved.
//

/*
 Description:
 书籍列表的model

 History:
 */

import Foundation
/**
 书籍列表的model

 - superclass: Mappable
 - classdesign: 没有设定模式
 - author: Zhangyao
 */
struct BookList: Codable {

    var books: [BookModel]?
    var totalCount: Int? = 0
    /// 这个字段只会出现在馆内图书列表、图书搜索以及图书高级搜索里，标记包含复本率的书籍总数量，单位为“册”
    var totalBooks: Int? = 0
    
    enum CodingKeys: String, CodingKey {
        case books = "resultList"
        case totalCount = "totalCount"
        case totalBooks = "totalBooks"
    }
}
struct BookModel: Codable {
    var id: String?           // 用于请求书籍详细信息，图书编目库id
    var bookId: String?       // 图书基库id
    var bookName: String?
    var image: String?
    var isbn: String?
    var author: String?
    var publisher: String?   //出版社 publisher
    var publishDate: String?
    var libName: String?
    var libCode: String?      // 所在馆馆号
    var libId: String?        // 所在馆id
    var categoryName: String?
    var appointTime: String?
    var appointTimeEnd: String?
    var storageTime: String?   //上架时间
    var barNumber: String?
    var storeRoom: String?
    var frameCode: String?
    var callNumber: String?
    var readerLimit: Int?
    var isNeedIdCard: Int?
    var htmlUrl: String?      // 网页详情URL
    var isShowNewBookTips: Bool? //是否展示新书标签
   
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case bookId = "bookId"
        case bookName = "bookName"
        case image = "image"
        case isbn = "isbn"
        case author = "author"
        case publisher = "publisher"
        case publishDate = "publishDate"
        case libName = "libName"
        case libCode = "libCode"
        case libId = "libId"
        case categoryName = "categoryName"
        case appointTime = "appointTime"
        case appointTimeEnd = "appointTimeEnd"
        case storageTime = "storageTime"
        case barNumber = "barNumber"
        case storeRoom = "storeRoom"
        case frameCode = "frameCode"
        case callNumber = "callNumber"
        case readerLimit = "readerLimit"
        case isNeedIdCard = "isNeedIdCard"
        case htmlUrl = "htmlUrl"
    }
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let tempStorageTime = try? container.decode(String.self, forKey: .storageTime) {
            // 上架时间存在，转换
            isShowNewBookTips = isNewBook(tempStorageTime)
            storageTime = tempStorageTime
        } else {
            storageTime = try? container.decode(String.self, forKey: .storageTime)
            isShowNewBookTips = false
        }
        
        id                       = try? container.decode(String.self, forKey: .id      )
        bookId                   = try? container.decode(String.self, forKey: .bookId)
        bookName                 = try? container.decode(String.self, forKey: .bookName)
        image                    = try? container.decode(String.self, forKey: .image)
        isbn                     = try? container.decode(String.self, forKey: .isbn)
        author                   = try? container.decode(String.self, forKey: .author)
        publisher                = try? container.decode(String.self, forKey: .publisher)
        publishDate              = try? container.decode(String.self, forKey: .publishDate)
        libName                  = try? container.decode(String.self, forKey: .libName)
        libCode                  = try? container.decode(String.self, forKey: .libCode)
        libId                    = try? container.decode(String.self, forKey: .libId)
        categoryName             = try? container.decode(String.self, forKey: .categoryName)
        appointTime              = try? container.decode(String.self, forKey: .appointTime)
        appointTimeEnd           = try? container.decode(String.self, forKey: .appointTimeEnd)
        barNumber                = try? container.decode(String.self, forKey: .barNumber)
        storeRoom                = try? container.decode(String.self, forKey: .storeRoom)
        frameCode                = try? container.decode(String.self, forKey: .frameCode)
        callNumber               = try? container.decode(String.self, forKey: .callNumber)
        readerLimit              = try? container.decode(Int.self, forKey: .readerLimit)
        isNeedIdCard             = try? container.decode(Int.self, forKey: .isNeedIdCard)
        htmlUrl                  = try? container.decode(String.self, forKey: .htmlUrl)
    }
   private func isNewBook(_ storageTime: String) -> Bool {
    // 计算手机15前的时间
    let oneDay: TimeInterval = 86400
    let dateNow = Date()
    let fifteenDaysAgo = Date(timeIntervalSinceNow: oneDay * (-15)) //15天前
    let timeZone = TimeZone.current
    let interval = timeZone.secondsFromGMT(for: dateNow)
    let theDateOfFifteenDaysAgo = fifteenDaysAgo.addingTimeInterval(TimeInterval(interval))
    
    // 计算系统时间
    let datefmatter = DateFormatter()
    datefmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = datefmatter.date(from: storageTime) else {
        return false
    }
    let systemDate = date.addingTimeInterval(TimeInterval(interval))
    
    // 对比时间
    return theDateOfFifteenDaysAgo.compare(systemDate) != .orderedDescending
    }
}
