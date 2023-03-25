//
//  NewsWebViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/25.
//

import UIKit
import WebKit

class NewsWebViewController: UIViewController {

    //MARK: - IBOutlet & IBAction
    
    
    
    //MARK: - property
    
    private var webView: WKWebView!  // 웹 뷰
    
    var search: String!
    var url: String!
    
    //MARK: - drawing cycle
    
    override func loadView() {
        super.loadView()
        
        self.webView = WKWebView(frame: self.view.frame)
        self.view = self.webView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebPage()
    }
    
    //MARK: - method

    private func loadWebPage() {
        let sURL = "https://www.naver.com/"
        let uURL = URL(string: sURL)
        var request = URLRequest(url: uURL!)
        self.webView.load(request)
    }
    

}
