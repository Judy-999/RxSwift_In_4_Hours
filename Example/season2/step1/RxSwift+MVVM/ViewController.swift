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

    var disposables: [Disposable] = []
    var disposeBag = DisposeBag()   // 위의 기능을 해주는 것, 따로 처리해주지 않아도 클래스(ViewController)의 멤버 변수라 클래스가 날아가면 같이 날아가면서 없어짐
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        disposables.forEach{ $0.dispose() } // 화면을 나가면 다운 받던 모든 것을 취소하도록
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    func downloadJson(_ url: String) -> Observable<String> {
        return Observable.create { emiiter in
            let url = URL(string: MEMBER_LIST_URL)!
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else {
                    emiiter.onError(error!)
                    return
                }
                
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emiiter.onNext(json)
                }
                
                emiiter.onCompleted()
            }
                
            task.resume()
            
            return Disposables.create() {
                task.cancel()
            }
        }
    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        self.setVisibleWithAnimation(self.activityIndicator, true)
        
        
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservarble = Observable.just("Hello")
        
        let disposable = Observable.zip(jsonObservable, helloObservarble) { $1 + "\n" + $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
                
            })
            //.disposed(by: disposeBag) // 방법 3) 바로 이렇게 넣어줄 수 있음
        
        disposables.append(disposable) // 방법 1) 배열을 만들어 넣어주기
        disposeBag.insert(disposable)  // 방법 2) DisposeBag에 넣어주기
    }
}


