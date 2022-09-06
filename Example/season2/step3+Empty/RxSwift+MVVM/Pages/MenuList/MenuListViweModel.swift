//
//  MenuListViweModel.swift
//  RxSwift+MVVM
//
//  Created by 김주영 on 2022/09/03.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    
    // PublishSubject로 하면 init으로 값이 들어오고 나서 밖에서 subscribe해서 값이 변경돼야만 값을 전해줌 -> 테이블 뷰에 아무것도 안나옴
    // 내가 구독했을 때 가장 최근의 값을 바로 받아오고 싶다? -> BehaviorSubject
    var menuObservable = BehaviorSubject<[Menu]>(value: []) // BehaviorSubject는 초기값이 있어야 해서 빈배열을 넣어줌
    
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.count * $0.price }.reduce(0, +)
    }
    
    init() {
        let menus: [Menu] = [
            Menu(name: "튀김", price: 100, count: 1),
            Menu(name: "튀김", price: 100, count: 1),
            Menu(name: "튀김", price: 100, count: 1),
            Menu(name: "튀김", price: 100, count: 1),
            Menu(name: "튀김", price: 100, count: 1)
        ]
        
        menuObservable.onNext(menus)
    }
    
    func clearAllItemSelections() {
        menuObservable
            .map { menus in
                menus.map {
                    Menu(name: $0.name, price: $0.price, count: 0)
                }
            }
            .take(1)
            .subscribe(onNext: { // subscribe해서 변경한 값을 다시 넣어주기 -> 값을 넣어준다? = onNext
                self.menuObservable.onNext($0)
            })
        // subscribe는 한 번만 해놓으면 알아서 자동으로 해주는데 clear 버튼이 누를 때마다 실행할 필요(스트림을 만들 필요)가 없음 -> 한 번만 수행해라 = take(1)
    }
}
