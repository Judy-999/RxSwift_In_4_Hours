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

    var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.count * $0.price }.reduce(0, +)
    }
    
    init() {
        // 이제 API에서 받아와서 초기화해주기
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                
                let decodedMenuItems = try! JSONDecoder().decode(Response.self, from: data) // MenuItems 배열을 디코드
                return decodedMenuItems.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { index, item in
                    let menu = Menu.fromMenuItems(id: index, item: item) // MenuItem 타입을 Menu 타입으로 변경
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
            //.bind(to: menuObservable) // 이거 왜 bind로 하신거지?
    }
    
    func clearAllItemSelections() {
        menuObservable
            .map { menus in
                menus.map {
                    Menu(id: $0.id, name: $0.name, price: $0.price, count: 0)
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
    
    func changeCount(menu: Menu, increase: Int) {
        menuObservable
            .map { menus in
                menus.map {
                    if $0.id == menu.id {
                        return Menu(id: $0.id, name: $0.name, price: $0.price, count: max($0.count + increase, 0)) // 0보다 작은 값이 들어가지 않도록
                    } else {
                        return $0
                    }
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
}

