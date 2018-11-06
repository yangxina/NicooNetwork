//
//  NicooAPIProxy.swift
//  CloudLibrary
//
//  Created by NicooYang on 22/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit
import Alamofire

typealias NicooAPICallback = (_ response: NicooURLResponse?) -> Void

class NicooAPIProxy: NSObject {

    private lazy var dispatchTable: [String: URLSessionTask] = {
        return [String: URLSessionTask]()
    }()
    private lazy var sessionManager: SessionManager = {
        let manager = SessionManager.default
        return manager
    }()
    static let shareInstance = NicooAPIProxy()


    // MARK: - Life cycle

    private override init() {
        super.init()
    }

    // MARK: - Public functions

    func cancelRequest(_ requestId: Int) {
        let task = self.dispatchTable["\(requestId)"]
        task?.cancel()
        self.dispatchTable.removeValue(forKey: "\(requestId)")
    }

    func cancelRequests(_ requestIdList: [Int]) {
        for requestId in requestIdList {
            self.cancelRequest(requestId)
        }
    }

    func callGET(_ params: [String: Any]?, serviceIdentifier: String, methodName: String,success: NicooAPICallback?, fail: NicooAPICallback?) -> Int {
        let request = NicooRequestGenerator.shareInstance.generateGETRequest(serviceIdentifier, requestParams: params, methodName: methodName)
        if request == nil {
            fail?(nil)
            return 0
        }
        let requestId = self.callAPI(request!, requestParams: params, success: success, fail: fail)
        return requestId
    }

    func callPOST(_ params: [String: Any]?, serviceIdentifier: String, methodName: String,  parameterEnconding: NicooAPIManagerParameterEncodeing, success: NicooAPICallback?, fail: NicooAPICallback?) -> Int {
        let request = NicooRequestGenerator.shareInstance.generatePOSTRequest(serviceIdentifier, requestParams: params, methodName: methodName, parameterEnconding: parameterEnconding)
        if request == nil {
            fail?(nil)
            return 0
        }
        let requestId = self.callAPI(request!, requestParams: params, success: success, fail: fail)
        return requestId
    }

    func callPUT(_ params: [String: Any]?, serviceIdentifier: String, methodName: String, parameterEnconding: NicooAPIManagerParameterEncodeing, success: NicooAPICallback?, fail: NicooAPICallback?) -> Int {
        let request = NicooRequestGenerator.shareInstance.generatePUTRequest(serviceIdentifier, requestParams: params, methodName: methodName, parameterEnconding: parameterEnconding)
        if request == nil {
            fail?(nil)
            return 0
        }
        let requestId = self.callAPI(request!, requestParams: params, success: success, fail: fail)
        return requestId
    }

    func callDELETE(_ params: [String: Any]?, serviceIdentifier: String, methodName: String, parameterEnconding: NicooAPIManagerParameterEncodeing, success: NicooAPICallback?, fail: NicooAPICallback?) -> Int {
        let request = NicooRequestGenerator.shareInstance.generateDELETERequest(serviceIdentifier, requestParams: params, methodName: methodName, parameterEnconding: parameterEnconding)
        if request == nil {
            fail?(nil)
            return 0
        }
        let requestId = self.callAPI(request!, requestParams: params, success: success, fail: fail)
        return requestId
    }

    func callAPI(_ request: URLRequest, requestParams: [String: Any]? ,success: NicooAPICallback?, fail: NicooAPICallback?) -> Int {
        weak var dataRequest: DataRequest? = nil
        sessionManager.startRequestsImmediately = false
        dataRequest = sessionManager.request(request)
            .validate(statusCode: 200 ..< 500)
            .downloadProgress(closure: { (progress) in
                 print("Progress: \(progress.fractionCompleted) / \(progress.totalUnitCount)")
            })
            .response(completionHandler: { [weak self] (response) in
                let requestId = dataRequest!.task!.taskIdentifier
                self?.dispatchTable.removeValue(forKey: "\(requestId)")
                var responseString: String? = nil
                if let data = response.data {
                    responseString = String(data: data, encoding: String.Encoding.utf8)
                }

                if let error = response.error {
                    // error有可能能转换为AFError，但是一定能转换为NSError（但是能够转换为AFError的error，转换为NSError获取不到太多有用的数据）
                    let tzResponse = NicooURLResponse(responseString, requestId: requestId, request: request, requestParams: requestParams, responseData: response.data, error: error as NSError)
                    fail?(tzResponse)
                } else {
                    let tzResponse = NicooURLResponse(responseString, requestId: requestId, request: request, requestParams: requestParams, responseData: response.data, status: .success)
                    success?(tzResponse)
                }
            })

        let requestId = dataRequest!.task!.taskIdentifier
        self.dispatchTable["\(requestId)"] = dataRequest!.task!
        dataRequest!.resume()
        sessionManager.startRequestsImmediately = true // 这里纯属为了兼容不使用TZNetworking框架的代码，当然一个项目最好别使用两种方式。
        return requestId
    }
}
