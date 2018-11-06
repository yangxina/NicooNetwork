//
//  BookReformer.swift
//  CloudLibrary
//
//  Created by Zhangyao on 30/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit
import NicooNetwork

class BookReformer: NSObject {

    // MARK: - Private functions

    /**
     首页“图书”模块、图书搜索、借阅排行榜、点赞排行榜、推荐排行榜
     */
    private func reformHomePageDatas(_ data: Data?) -> Any? {
        
        if let bookList = try? decode(response: data, of: ObjectResponse<BookList>.self)?.data {
            return bookList
        }
        return nil
    }

   
}

extension BookReformer: NicooAPIManagerDataReformProtocol {

    func manager(_ manager: NicooBaseAPIManager, reformData jsonData: Data?) -> Any? {
        
               if manager is BooksHotListAPI {
                    return reformHomePageDatas(jsonData)
                }

        return nil
    }
}
