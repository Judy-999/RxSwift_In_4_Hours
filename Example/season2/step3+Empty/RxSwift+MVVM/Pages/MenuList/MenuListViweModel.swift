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
    
    // menuObservable 또는 itemsCount 또는 totalPrice를 subscribe 할 수 있음
    
    // 메뉴도 밖에서 바뀔 수 있어야 하니 Observable.just(menus) 대신에 PublishSubject
    var menuObservable = PublishSubject<[Menu]>() // Menu 배열를 받음(외부에서 받을 예정)
    
    lazy var itemsCount = menuObservable.map { // menuObservable를 바라보며 menuObservable가 바뀔 때마다 개수의 총합을 구함
        $0.map { $0.count }.reduce(0, +)
    }
    // totalPrice란건 menus의 (각 가격 * 개수)의 총합
    lazy var totalPrice = menuObservable.map { // menuObservable가 Observable이니까 값이 바뀌면 자동으로 바뀐 값으로 계산해줌
        $0.map { $0.count * $0.price }.reduce(0, +)
    }

    
    init() {
        let menus: [Menu] = [
            Menu(name: "튀김", price: 100, count: 0),
            Menu(name: "튀김", price: 100, count: 0),
            Menu(name: "튀김", price: 100, count: 0),
            Menu(name: "튀김", price: 100, count: 0),
            Menu(name: "튀김", price: 100, count: 0)
        ]
        
        menuObservable.onNext(menus)
    }
}
