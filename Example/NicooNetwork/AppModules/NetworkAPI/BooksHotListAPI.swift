//
//  BooksHotListAPI.swift
//  CloudLibrary
//
//  Created by 小星星 on 2018/4/4.
//  Copyright © 2018年 TZPT. All rights reserved.
//

import UIKit
import NicooNetwork
/**
 获取图书一周热门列表
 */
class BooksHotListAPI: YTSGBaseAPI {

    static let kPageNumber = "pageNo"
    static let kPageCount = "pageCount"
    static let kCategoryId = "categoryId" // 可选参数，有分类的时候再传
    
    fileprivate var pageNumber: Int = 1
    
    // MARK: - Public method
    
    override func loadData() -> Int {
        self.pageNumber = 1
        if self.isLoading {
            self.cancelAllRequests()
        }
        return super.loadData()
    }
    
    func loadNextPage() -> Int {
        if self.isLoading {
            return 0
        }
        return super.loadData()
    }
    
    // MARK: - TZAPIManagerProtocol
    
    override func methodName() -> String {
        return "userApp/libraryBook/weeklyHot"
    }
    
    override func shouldCache() -> Bool {
        return true
    }
    
    // the optional method may used for pageable API manager
    override func reform(_ params: [String: Any]?) -> [String: Any]? {
        let superParams = super.reform(params)
        
        var newParams: [String: Any] = [BooksHotListAPI.kPageNumber: pageNumber,
                                        BooksHotListAPI.kPageCount: "20"]
        if superParams != nil {
            for (key, value) in superParams! {
                newParams[key] = value
            }
        }
        return newParams
    }
    
    // MARK: - TZAPIManagerInterceptorProtocol
    
    override func manager(_ manager: NicooBaseAPIManager, beforePerformSuccess response: NicooURLResponse) -> Bool {
        self.pageNumber += 1
        return true
    }
}
