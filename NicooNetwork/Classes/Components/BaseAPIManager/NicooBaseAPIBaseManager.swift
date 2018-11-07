//
//  NicooAPIBaseManager.swift
//  CloudLibrary
//
//  Created by NicooYang on 21/8/2017.
//  Copyright © 2017 TZPT. All rights reserved.
//

import Foundation

public enum NicooAPIManagerErrorType: Int {
    case defaultError  // 没有产生过API请求，这个是manager的默认状态
    case success       // API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的
    case noContent     // API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个
    case paramsError   // 参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的
    case timeout       // 请求超时。CTAPIProxy设置的是20秒超时，具体超时时间可以自己配置
    case noNetwork     // 网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的
    case tokenError    // token失效
}

public enum NicooAPIManagerRequestType: Int {
    case get
    case post
    case put
    case delete
}

public enum NicooAPIManagerParameterEncodeing: Int {
    case url
    case json
}

public protocol NicooAPIManagerCallbackDelegate: class {
    func managerCallAPISuccess(_ manager: NicooBaseAPIManager)
    func managerCallAPIFailed(_ manager: NicooBaseAPIManager)
}

public protocol NicooAPIManagerParamSourceDelegate: class {
    func paramsForAPI(_ manager: NicooBaseAPIManager) -> [String: Any]?
}

open class NicooBaseAPIManager: NSObject {

    static var kAPIBaseManagerRequestId = "kAPIBaseManagerRequestId"
    static var kDefaultErrorMessage = "网络请求失败!"

    public weak var delegate: NicooAPIManagerCallbackDelegate?
    public weak var paramSource: NicooAPIManagerParamSourceDelegate?
    public weak var validator: NicooAPIManagerValidatorDelegate?
    public weak var interceptor: NicooAPIManagerInterceptorProtocol?
    private(set) weak var child: NicooAPIManagerProtocol?
    /*
     baseManager是不会去设置errorMessage的，派生的子类manager可能需要给controller提供错误信息。所以为了统一外部调用的入口，设置了这个变量。
     派生的子类需要通过extension来在保证errorMessage在对外只读的情况下使派生的manager子类对errorMessage具有写权限。默认提示语是“网络故障!”
     */
    public var errorMessage: String = NicooBaseAPIManager.kDefaultErrorMessage
    public var errorType: NicooAPIManagerErrorType = .defaultError
    public var response: NicooURLResponse!
    private var isReachable: Bool {
        let networkAvailable = NicooNetworkingConfigurationManager.shareInstance.isReachable
        if !networkAvailable {
            self.errorType = .noNetwork
        }
        return networkAvailable
    }
    public var isLoading: Bool {
        if self.requestIdList.count == 0 {
            return false
        }
        return self._isLoading
    }
    private var _isLoading: Bool = false
    private var fetchedRawData: Any?
    private var isNativeDataEmpty = true
    private lazy var requestIdList: [Int] = {
        return [Int]()
    }()
    

    // MARK: - Life cycle

    deinit {
        self.cancelAllRequests()
    }

    public override init() {
        super.init()

        if self is NicooAPIManagerProtocol {
            self.child = self as? NicooAPIManagerProtocol
        } else {
            assert(false, String(format: "%@没有遵循NicooAPIManagerProtocol协议", self))
        }
    }

    // MARK: - Public functions

    /**
     通过apimanager的reform转化数据

     - parameter            reformer: 实现了NicooAPIManagerDataReformProtocol的类

     - returns:             返回任意数据类型
     */
    public func fetchData(_ reformer: NicooAPIManagerDataReformProtocol) -> Any? {
        var result: Any? = self.fetchedRawData
        if let value = reformer.manager(self, reformData: self.fetchedRawData as? [String: Any]) {
            result = value
        }
        return result
    }
    
    /**
     通过apimanager的reform转化数据
     
     - parameter            reformer: 实现了NicooAPIManagerDataReformProtocol的类
     
     - returns:             返回任意数据类型
     */
    public func fetchJSONData(_ reformer: NicooAPIManagerDataReformProtocol) -> Any? {
        var result: Any? = self.fetchedRawData
        if let value = reformer.manager(self, reformData: response.responseData) {
            result = value
        }
        return result
    }

    /**
     来去从服务器获得的错误信息

     - parameter            feformer: 数据解析的类

     - returns:             返回的数据为任意类型
     */
    public func fetchFailedRequestMsg(_ reformer: NicooAPIManagerDataReformProtocol) -> Any? {
        var result: Any? = self.fetchedRawData

        if let value = reformer.manager(self, faildToReform: self.fetchedRawData as? [String: Any]) {
            result = value
        }
        return result
    }

    public func cancelAllRequests() {
        NicooAPIProxy.shareInstance.cancelRequests(self.requestIdList)
        self.requestIdList.removeAll()
    }

    public func cancelRequest(_ requestId: Int) {
        self.removeRequest(requestId)
        NicooAPIProxy.shareInstance.cancelRequest(requestId)
    }

    // MARK: - Calling API

    /**
     这个方法会通过param source来获得参数，这使得参数的生成逻辑位于controller中的固定位置

     - returns:             返回requestId
     */
    open func loadData() -> Int {
        let params = self.paramSource?.paramsForAPI(self)
        return self.loadData(params)
    }
    
    /**
     这个方法会通过param source来获得缓存参数
     
     - returns:             返回requestId
     */
    open func loadCacheData() -> Int {
        let params = self.paramSource?.paramsForAPI(self)
        return self.loadCacheData(params)
    }
    
    private func loadCacheData(_ params: [String: Any]?) -> Int {
        let requestId = 0
        let apiParams = self.reformParams(params)
        if self.shouldCallAPI(apiParams) {
            if self.validator!.manager(self, isCorrectWithParams: apiParams) {
                // 查看是否有缓存, 如果有，则从获取缓存中的数据
                if self.hasCacheWithParams(apiParams, refuseExpire: true) {
                    return requestId
                } else {
                    failedOnCallingAPI(nil, errorType: NicooAPIManagerErrorType.noContent)
                }
            }
        }
        return requestId
    }
    
    private func loadData(_ params: [String: Any]?) -> Int {
        var requestId = 0
        let apiParams = self.reformParams(params)
        if self.shouldCallAPI(apiParams) {
            if self.validator!.manager(self, isCorrectWithParams: apiParams) {

                // 查看是否有缓存, 如果有，则从获取缓存中的数据
                if self.shouldAPICache() && self.hasCacheWithParams(apiParams, refuseExpire: false) {
                    return requestId
                }

                // 从服务器请求数据
                if self.isReachable {
                    self._isLoading = true
                    switch self.child!.requestType() {
                    case .get:
                        requestId = NicooAPIProxy.shareInstance.callGET(apiParams, serviceIdentifier: self.child!.serviceType(), methodName: self.child!.methodName(), success: { [weak self] (response) in
                            self?.successedOnCallingAPI(response!)
                        }, fail: { [weak self] (response) in
                            self?.failedOnCallingAPI(response, errorType: .defaultError)
                        })
                    case .post:
                        requestId = NicooAPIProxy.shareInstance.callPOST(apiParams, serviceIdentifier: self.child!.serviceType(), methodName: self.child!.methodName(), parameterEnconding: self.child!.parameterEncodingType(), success: { [weak self] (response) in
                            self?.successedOnCallingAPI(response!)
                            }, fail: { [weak self] (response) in
                                self?.failedOnCallingAPI(response, errorType: .defaultError)
                        })
                    case .put:
                        requestId = NicooAPIProxy.shareInstance.callPUT(apiParams, serviceIdentifier: self.child!.serviceType(), methodName: self.child!.methodName(),parameterEnconding: self.child!.parameterEncodingType(), success: { [weak self] (response) in
                            self?.successedOnCallingAPI(response!)
                            }, fail: { [weak self] (response) in
                                self?.failedOnCallingAPI(response, errorType: .defaultError)
                        })
                    case .delete:
                        requestId = NicooAPIProxy.shareInstance.callDELETE(apiParams, serviceIdentifier: self.child!.serviceType(), methodName: self.child!.methodName(),parameterEnconding: self.child!.parameterEncodingType(), success: { [weak self] (response) in
                            self?.successedOnCallingAPI(response!)
                            }, fail: { [weak self] (response) in
                                self?.failedOnCallingAPI(response, errorType: .defaultError)
                        })
                    }
                    self.requestIdList.append(requestId)
                    var newParams: [String: Any] = apiParams ?? [String: Any]()
                    newParams[NicooBaseAPIManager.kAPIBaseManagerRequestId] = requestId
                    self.afterCallingAPI(params)
                    return requestId
                } else {
                    self.failedOnCallingAPI(nil, errorType: .noNetwork)
                }

            } else {
                self.failedOnCallingAPI(nil, errorType: .paramsError)
            }
        }
        return requestId
    }

    // MARK: - API callback

    private func successedOnCallingAPI(_ response: NicooURLResponse) {
        self._isLoading = false
        self.response = response
        self.fetchedRawData = response.content == nil ? response.responseData : response.content
        self.removeRequest(response.requestId)
        if self.validator!.manager(self, isCorrectWithCallbackData: response.content as? [String: Any]) {

            if self.shouldAPICache() && !response.isCache {
                let serviceIdentifier = self.child!.serviceType()
                let methodName = self.child!.methodName()
                NicooCacheTool.cache("\(serviceIdentifier)/\(methodName)",
                    parameters: response.requestParams,
                    data: response.responseData,
                    expireTime: NicooNetworkingConfigurationManager.shareInstance.cacheOutdateSeconds)
            }

            if self.beforePerformSuccess(response) {
                self.delegate?.managerCallAPISuccess(self)
            }
            self.afterPerformSuccess(response)
        } else {
            self.failedOnCallingAPI(response, errorType: .noContent)
        }
    }

    private func failedOnCallingAPI(_ response: NicooURLResponse? , errorType: NicooAPIManagerErrorType) {
        // 继续错误的处理
        self.errorType = errorType
        let serviceIdentifier = self.child!.serviceType()
        let service = NicooServiceFactory.shareInstance.serviceWith(serviceIdentifier) as! NicooService
        self._isLoading = false
        self.response = response
        var needCallBack = true
        if service.child != nil {
            needCallBack = service.child!.shouldCallBackByFailedOnCallingAPI(response)
            if service.child!.isTokenError() {
                self.errorType = .tokenError
            }
        }
        // 由service决定是否结束回调
        if !needCallBack {
            return
        }

        self.removeRequest(response?.requestId ?? 0)
        if response?.content != nil {
            self.fetchedRawData = response?.content
        } else {
            self.fetchedRawData = response?.responseData
        }
        if self.beforePerformFail(response) {
            self.delegate?.managerCallAPIFailed(self)
        }
        self.afterPerformFail(response)
    }


    // MARK: - interceptor

    // 拦截器方法，继承之后需要调用一下super
    /*
     拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
     当两种情况共存的时候，子类重载的方法一定要调用一下super
     然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现

     notes:
     正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
     但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
     所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
     这就是decorate pattern
     */
    func beforePerformSuccess(_ response: NicooURLResponse) -> Bool {
        self.errorType = .success
        if self.interceptor == nil {
            return true
        }
        return self.interceptor!.manager(self, beforePerformSuccess: response)
    }

    func afterPerformSuccess(_ response: NicooURLResponse) {
        if self.interceptor != nil {
            self.interceptor!.manager(self, afterPerformSuccess: response)
        }
    }

    func beforePerformFail(_ response: NicooURLResponse?) -> Bool {
        if self.interceptor == nil {
            return true
        }
        return self.interceptor!.manager(self, beforePerformFail: response)
    }

    func afterPerformFail(_ response: NicooURLResponse?) {
        self.interceptor?.manager(self, afterPerformFail: response)
    }

    /**
     询问是否继续访问，默认返回true

     - parameter            params: api参数

     - returns:             true：允许继续调用api  false: 终止调用api
     */
    func shouldCallAPI(_ params: [String: Any]?) -> Bool {
        if self.interceptor == nil {
            return true
        }
        return self.interceptor!.manager(self, shouldCallAPI: params)
    }

    func afterCallingAPI(_ params: [String: Any]?) {
        self.interceptor?.manager(self, afterCallAPI: params)
    }


    // MARK: - Function for child

    /*
     用于给继承的类做重载，在调用API之前额外添加一些参数,但不应该在这个函数里面修改已有的参数。
     子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
     CTAPIBaseManager会先调用这个函数，然后才会调用到 id<CTAPIManagerValidator> 中的 manager:isCorrectWithParamsData:
     所以这里返回的参数字典还是会被后面的验证函数去验证的。

     假设同一个翻页Manager，ManagerA的paramSource提供page_size=15参数，ManagerB的paramSource提供page_size=2参数
     如果在这个函数里面将page_size改成10，那么最终调用API的时候，page_size就变成10了。然而外面却觉察不到这一点，因此这个函数要慎用。

     这个函数的适用场景：
     当两类数据走的是同一个API时，为了避免不必要的判断，我们将这一个API当作两个API来处理。
     那么在传递参数要求不同的返回时，可以在这里给返回参数指定类型。

     具体请参考AJKHDXFLoupanCategoryRecommendSamePriceAPIManager和AJKHDXFLoupanCategoryRecommendSameAreaAPIManager

     */

    //如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
    //子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
    func reformParams(_ params: [String: Any]?) -> [String: Any]? {
        if self.child == nil {
            return params
        }
        // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
        // 如果child是另一个对象，就会跑到这里
        let result = self.child?.reform(params)
        return result ?? params
    }


    func shouldAPICache() -> Bool {
        if self.child == nil {
            return NicooNetworkingConfigurationManager.shareInstance.shouldCache
        }
        return self.child!.shouldCache()
    }

    func cleanData() {
        self.fetchedRawData = nil
        self.errorMessage = NicooBaseAPIManager.kDefaultErrorMessage
        self.errorType = .defaultError
    }

    // MARK: - Private functions

    func removeRequest(_ requestId: Int) {
        if let index = self.requestIdList.index(of: requestId) {
            self.requestIdList.remove(at: index)
        }
    }

    /**
     获取对应请求的缓存
     
     - parameter            params: url参数
     - parameter            refuseExpire: 拒绝超时处理，直接取缓存
     
     - returns:             true：允许继续调用api  false: 终止调用api
     */
    func hasCacheWithParams(_ params: [String: Any]?, refuseExpire: Bool) -> Bool {
        let serviceIdentifier = self.child!.serviceType()
        let methodName = self.child!.methodName()
        if let data = NicooCacheTool.getCacheData("\(serviceIdentifier)/\(methodName)", params: params, refuseExpire: refuseExpire) {
            if !self.isReachable && NicooNetworkingConfigurationManager.shareInstance.shouldLoadCacheDataWhileNoNetwork {
                return false
            }
            DispatchQueue.main.async { [weak self] in
                let response = NicooURLResponse(data)
                response.requestParams = params
                self?.successedOnCallingAPI(response)
            }
            return true
        }
        return false
    }

}
