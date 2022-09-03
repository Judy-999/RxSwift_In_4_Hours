//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> { // = Observable
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) {    // = subscribe
        task(f)
    }
}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
    func downloadJson(_ url: String) -> Observable<String?> {
        return Observable.create { emiiter in
            let url = URL(string: MEMBER_LIST_URL)!
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else {
                    emiiter.onError(error!) // 에러가 발생하면 에러를 전송
                    return
                }
                
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emiiter.onNext(json)    // 데이터가 준비되면 데이터를 전송
                }
                
                emiiter.onCompleted()   // 데이터가 준비되지 않았어도 종료
            }
                
            task.resume()
            
            return Disposables.create() {
                task.cancel()   // downloadJson를 subscribe 했을 때 dispose 하면 이 부분을 실행
            }
        }
        
//        return Observable.create { emitter in
//            emitter.onNext("Hello")
//            emitter.onNext("World") // 여러 개를 보낼 수 있음
//            emitter.onCompleted()
//
//            return Disposables.create()
//        }
        
//        return Observable.create { f in
//            DispatchQueue.global().async {
//                let url = URL(string: MEMBER_LIST_URL)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted()
//                }
//            }
//
//            return Disposables.create()
//        }
    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        self.setVisibleWithAnimation(self.activityIndicator, true)
        
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        _ = downloadJson(MEMBER_LIST_URL)
            .debug()    // 어떤 이벤트가 전달되는지 찍힘
            .subscribe { event in
                switch event {
                case .next(let json):
                    DispatchQueue.main.async {
                        self.editView.text = json   // URLSession을 처리하는 스레드에서 넘어왔기 때문에 main 스레드가 아님
                        self.setVisibleWithAnimation(self.activityIndicator, false)
                    }
                case .completed:
                    break
                case .error:
                    break
                }
            }
    }
}

// Rxswift의 사용법 알기
// 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
// 2. Observable로 오는 데이터를 받아서 처리하는 방법
