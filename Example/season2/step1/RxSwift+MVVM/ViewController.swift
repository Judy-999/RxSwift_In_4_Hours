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

    
    func downloadJson(_ url: String) -> Observable<String?> {
        return Observable.create { f in
            DispatchQueue.global().async { // 힘수 자체를 비동기로 처리
                let url = URL(string: MEMBER_LIST_URL)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                DispatchQueue.main.async {
                    f.onNext(json)
                }
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        self.setVisibleWithAnimation(self.activityIndicator, true) // UI변경 -> main
        
        let disposable = downloadJson(MEMBER_LIST_URL)
            .subscribe { event in
                switch event {
                case .next(let json):   // 데이터가 전달될 때
                    self.editView.text = json // UI변경 -> main
                    self.setVisibleWithAnimation(self.activityIndicator, false) // UI변경 -> main
                case .completed: // 데이터가 전달되고 끝났을 때
                    break
                case .error:    // 에러가 발생했을 때(데이터가 전달되지 못했을 때)
                    break
                }
            }
        
        disposable.dispose()    // 반환 안기다리고 취소할래 -> 받아오라고 시켜놓고 취소를 해서 계속 인디케이터만 돌음
    }
}


// func subscribe(_ on: @escaping (Event<String?>) -> Void) -> Disposable
// Disposable을 반환
