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
        
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        _ = downloadJson(MEMBER_LIST_URL)
            .map { json in json?.count ?? 0}    // operator
            .filter { count in count > 0 }  // operator
            .map { String($0) } // operator
            .observeOn(MainScheduler.instance)  // 어떤 스레드에서 처리할지 정해줄 수 있음 ==> 이렇게 데이터가 전달되는 중간에 처리해주는 sugar = operator
            .subscribe(onNext: { json in
//                DispatchQueue.main.async {
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
//                }
            })
    }
}

// 이 기본 사용법 마저도 길고 귀찮다! -> Sugar
