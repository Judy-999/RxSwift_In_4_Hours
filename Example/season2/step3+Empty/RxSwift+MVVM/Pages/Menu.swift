//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by 김주영 on 2022/09/03.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation

// ViewModel - 뷰를 위한 모델
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu { // MenuItem 타입을 Menu 타입으로 변경해서 생성하는 함수
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
