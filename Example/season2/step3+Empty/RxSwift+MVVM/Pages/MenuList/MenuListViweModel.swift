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
    var totalPrice: Observable<Int> = Observable.just(10000) //10000원을 subscribe해서 받을 수 있는 Int 값이 됨
}
