//
//  NicooRequestGenerator.swift
//  CloudLibrary
//
//  Created by NicooYang on 23/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import UIKit
import Alamofire

enum NicooHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class NicooRequestGenerator: NSObject {

    static let shareInstance: NicooRequestGenerator = NicooRequestGenerator()

    private override init() {
        super.init()
    }

    // MARK: - Public functions

    func generateGETRequest(_ serviceIdentifier: String, requestParams: [String: Any]?, methodName: String) -> URLRequest? {
        return self.generateRequest(serviceIdentifier, requestParams: requestParams, methodName: methodName, method: .get, parameterEnconding: .url)
    }

    func generatePOSTRequest(_ serviceIdentifier: String, requestParams: [String: Any]?, methodName: String, parameterEnconding: NicooAPIManagerParameterEncodeing)  -> URLRequest? {
        return self.generateRequest(serviceIdentifier, requestParams: requestParams, methodName: methodName, method: .post, parameterEnconding: parameterEnconding)
    }

    func generatePUTRequest(_ serviceIdentifier: String, requestParams: [String: Any]?, methodName: String, parameterEnconding: NicooAPIManagerParameterEncodeing)  -> URLRequest? {
        return self.generateRequest(serviceIdentifier, requestParams: requestParams, methodName: methodName, method: .put, parameterEnconding: parameterEnconding)
    }

    func generateDELETERequest(_ serviceIdentifier: String, requestParams: [String: Any]?, methodName: String, parameterEnconding: NicooAPIManagerParameterEncodeing)  -> URLRequest? {
        return self.generateRequest(serviceIdentifier, requestParams: requestParams, methodName: methodName, method: .delete, parameterEnconding: parameterEnconding)
    }

    func generateRequest(_ serviceIdentifier: String, requestParams: [String: Any]?, methodName: String, method: NicooHTTPMethod, parameterEnconding: NicooAPIManagerParameterEncodeing)  -> URLRequest? {
        let service = NicooServiceFactory.shareInstance.serviceWith(serviceIdentifier) as!NicooService
        let urlString = service.urlGeneratingRule(methodName)
        let fullParams = self.fullParamsWithExtraParams(service, requestParams: requestParams)
        /*
         为了配合RESTful结构的api，需要将参数替换进methodName里面去。
         如：news/{newsId}/setReadStatus
         现在要将fullParams里newsId对应的值与{newsId}相替换
         */
        guard let array = restulPath(urlString, parameters: fullParams) else {
            return nil
        }
        let restfulPath = array[0] as! String
        let finalParams = array[1] as! [String: Any]

        var request: URLRequest?
        do {
            request = try URLRequest(url: restfulPath, method: HTTPMethod(rawValue: method.rawValue)!)
            request?.timeoutInterval = NicooNetworkingConfigurationManager.shareInstance.apiNetworkingTimeoutSeconds
            if method != .get &&
                NicooNetworkingConfigurationManager.shareInstance.shouldSetParamsInHTTPBodyButGET {
                request!.httpBody = try JSONSerialization.data(withJSONObject: finalParams, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            }
            if let headers = service.child?.extraHttpHeadParams(methodName) {
                for (key, value) in headers {
                    request?.addValue(value, forHTTPHeaderField: key)
                }
            }

            if parameterEnconding == .json {
                let encodedURLRequest = try JSONEncoding.default.encode(request!, with: finalParams)
                return encodedURLRequest
            } else {
                let encodedURLRequest = try URLEncoding.default.encode(request!, with: finalParams)
                return encodedURLRequest
            }

/*
            if method != .get && NicooNetworkingConfigurationManager.shareInstance.shouldSetParamsInHTTPBodyButGET {
                let encodedURLRequest = try JSONEncoding.default.encode(request!, with: finalParams)
                return encodedURLRequest
            } else {
                let encodedURLRequest = try URLEncoding.default.encode(request!, with: finalParams)
                return encodedURLRequest
            }
 */
        } catch {
            print("\(methodName)生成request错误")
        }
        return nil
    }

    // MARK: - Private functions

    private func fullParamsWithExtraParams(_ service: NicooService, requestParams: [String: Any]?) -> [String: Any]? {
        var fullParams = [String: Any]()
        if requestParams != nil {
            for (key, value) in requestParams! {
                fullParams[key] = value
            }
        }
        if let extraParams = service.child?.extraParams() {
            for (key, value) in extraParams {
                fullParams[key] = value
            }
        }
        return fullParams
    }

    private func restulPath(_ path: String, parameters: [String: Any]?) -> [Any]? {
        if parameters == nil {
            return [path, parameters ?? [String: Any]()]
        }
        var finalParams = parameters!
        var finalStr = path
        var haveDone = false
        repeat {
            if let range = finalStr.range(of: "\\{.*?\\}", options: .regularExpression, range: nil, locale: nil) {
                let subString = String(finalStr[range])
                var key = subString.replacingOccurrences(of: "{", with: "")
                key = key.replacingOccurrences(of: "}", with: "")
                guard let value = finalParams[key] else {
                    return nil
                }
                // 解决类似中文这样的编码问题
                var encodedValue = value
                if encodedValue is String {
                    encodedValue = (encodedValue as! String).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                }
                finalStr = finalStr.replacingCharacters(in: range, with: "\(encodedValue)")
                finalParams.removeValue(forKey: key)
            } else {
                haveDone = true
            }
        } while !haveDone
        return [finalStr, finalParams]
    }

}
