//
//  ViewController.swift
//  NicooNetworkDemo
//
//  Created by NicooYang 2018/11/5.
//  Copyright © 2018年 yangxin. All rights reserved.
//

import UIKit
import MBProgressHUD
import NicooNetwork

class ViewController: UIViewController {
    
    fileprivate let cellReuseIdentifer = "BookTableViewCell"
    lazy fileprivate var tableView: UITableView = {
        let tableView = UITableView()
        var cellCalss: AnyClass = UITableViewCell.classForCoder()
        tableView.register(cellCalss, forCellReuseIdentifier: self.cellReuseIdentifer)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.groupTableViewBackground
        
        return tableView
    }()
    
    fileprivate var bookList: BookList?
    
    lazy fileprivate var hotBooksAPI: BooksHotListAPI = {
        let api = BooksHotListAPI()
        api.paramSource = self
        api.delegate = self
        return api
    }()
    var booksRequestId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        layoutPageSubViews()
        booksRequestId =  hotBooksAPI.loadData()
        
    }
    
    private func requestFail(error: String?, manager: NicooBaseAPIManager?){
        print(manager?.errorMessage)
    }
    
    private func requestSuccess(_ aBookList: BookList?) {
        bookList = aBookList
        if let books = bookList?.books, books.count > 0 {
            print("bookList  = \(bookList!)")
            tableView.reloadData()
        }
    }
    
    
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let books = bookList?.books else {
            return 0
        }
        return  books.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifer, for: indexPath)
        if let book = bookList?.books?[indexPath.row] {
            cell.textLabel?.text = String(format: "%@", book.bookName ?? "")
        }
        
        return cell
    }
}


// MARK: - NicooAPIManagerParamSourceDelegate,NicooAPIManagerCallbackDelegate

extension ViewController: NicooAPIManagerParamSourceDelegate, NicooAPIManagerCallbackDelegate {
    
    /// 网络请求参数添加  （这里是追加动态参数， 固定参数可以直接在BooksHotListAPI中拼接）
    ///
    /// - Parameter manager: NicooBaseAPIManager
    /// - Returns: params: [String: Any]
    
    func paramsForAPI(_ manager: NicooBaseAPIManager) -> [String : Any]? {
        MBProgressHUD.showAdded(to: view, animated: false)
        return nil
    }
    
    /// 请求成功回调
    ///
    /// - Parameter manager: NicooBaseAPIManager
    
    func managerCallAPISuccess(_ manager: NicooBaseAPIManager) {
        MBProgressHUD.hideAllHUDs(for: view, animated: false)
        let list = manager.fetchJSONData(BookReformer()) as? BookList
        if manager == hotBooksAPI {
            self.requestSuccess(list)
        }
    }
    
    /// 请求失败回调
    ///
    /// - Parameter manager: manager descriptionNicooBaseAPIManager
    func managerCallAPIFailed(_ manager: NicooBaseAPIManager) {
        MBProgressHUD.hideAllHUDs(for: view, animated: false)
        if manager == hotBooksAPI {
            self.requestFail(error: manager.errorMessage, manager: manager)
        }
    }
}

// MARK: - layout
extension ViewController {
    
    private func layoutPageSubViews() {
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
}

