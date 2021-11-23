//
//  ViewController.swift
//  campustaxi
//
//  Created by minsekim on 2021/10/30.
//

import UIKit
import WebKit

//class ViewController: UIViewController, WKUIDelegate,WKNavigationDelegate {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }


//}

class ViewController: UIViewController,WKUIDelegate,WKNavigationDelegate{

    
    // 웹뷰 목록 관리
    var webViews = [WKWebView]()
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        webView = createWebView(frame: screenSize, configuration: WKWebViewConfiguration())
//        뒤로가기 제스쳐 활성화
        webView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
        // https://www.campus-taxi.com
        let myURL = URL(string:"http://172.30.1.22:3000")
        let myRequest = URLRequest(url: myURL!)
        
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        
        webView.load(myRequest)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
 
        view = webView
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        print(navigationAction.request.url?.absoluteString ?? "")

        // 카카오 SDK가 호출하는 커스텀 스킴인 경우 open(_ url:) 메소드를 호출합니다.
        if let url = navigationAction.request.url
            , ["kakaokompassauth", "kakaolink", "kakaoplus"].contains(url.scheme) {

            // 카카오톡 실행
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

            decisionHandler(.cancel)
            return
        }

        // 서비스 상황에 맞는 나머지 로직을 구현합니다.


        decisionHandler(.allow)
    }
    

    /// ---------- 팝업 열기 ----------
    /// - 카카오 JavaScript SDK의 로그인 기능은 popup을 이용합니다.
    /// - window.open() 호출 시 별도 팝업 webview가 생성되어야 합니다.
    ///
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard let frame = self.webViews.last?.frame else {
            return nil
        }

        // 웹뷰를 생성하여 리턴하면 현재 웹뷰와 parent 관계가 형성됩니다.
        return createWebView(frame: frame, configuration: configuration)
    }

    /// ---------- 팝업 닫기 ----------
    /// - window.close()가 호출되면 앞에서 생성한 팝업 webview를 닫아야 합니다.
    ///
    func webViewDidClose(_ webView: WKWebView) {
        destroyCurrentWebView()
    }

    // 웹뷰 생성 메소드 예제
    func createWebView(frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: frame, configuration: configuration)

        // set delegate
        webView.uiDelegate = self
        webView.navigationDelegate = self

        // 화면에 추가
        self.view.addSubview(webView)

        // 웹뷰 목록에 추가
        self.webViews.append(webView)

        // 그 외 서비스 환경에 최적화된 뷰 설정하기


        return webView
    }

    // 웹뷰 삭제 메소드 예제
    func destroyCurrentWebView() {
        // 웹뷰 목록과 화면에서 제거하기
        self.webViews.popLast()?.removeFromSuperview()
    }
    
}
    
