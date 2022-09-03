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
            DispatchQueue.global().async {
                let url = URL(string: MEMBER_LIST_URL)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                DispatchQueue.main.async {
                    f.onNext(json)
                    f.onCompleted()  // 끝났다고 알려주면 클로저가 끝남 -> 클로저가 들고있는 self 참조가 없어지므로 문제가 없어짐
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
            .subscribe { event in // 순환참조가 생기는 문제가 있음 -> 문제를 없게 하려면 [weak self] 아니면 클로저가 self를 캡쳐해서 레퍼런스 카운트가 증가해서 발생하는 문제이므로 클로저를 다시 없애주면 됨 -> completed, error 케이스일 때 클로저가 없어짐
                switch event {
                case .next(let json):
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false) 
                case .completed:
                    break
                case .error:
                    break
                }
            }
        
        disposable.dispose()
    }
}


