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
    
    let menus: [Menu] = [
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0)
    ]
    
    var itemsCount: Int = 0
    var totalPrice: PublishSubject<Int> = PublishSubject()

    // Subject
    // 옵저버블처럼 값을 받을 수 있지만, 밖에서 값을 "통제"할 수도 있음
}
