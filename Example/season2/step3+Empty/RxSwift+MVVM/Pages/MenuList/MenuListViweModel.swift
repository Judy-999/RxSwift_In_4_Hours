//
//  MenuListViweModel.swift
//  RxSwift+MVVM
//
//  Created by 김주영 on 2022/09/03.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation

class MenuListViewModel {
    
    let menus: [Menu] = [
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0),
        Menu(name: "튀김", price: 100, count: 0)
    ]
    
    let itemsCount: Int = 0
    let totalPrice: Int = 0
}
