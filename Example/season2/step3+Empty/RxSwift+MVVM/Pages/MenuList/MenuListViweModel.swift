//
//  MenuListViweModel.swift
//  RxSwift+MVVM
//
//  Created by 김주영 on 2022/09/03.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {

    var menuObservable = BehaviorRelay<[Menu]>(value: [])
    
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
                
                let decodedMenuItems = try! JSONDecoder().decode(Response.self, from: data)
                return decodedMenuItems.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { index, item in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0) // Relay는 에러를 무시하기 때문에 onNext로 걸러 받을 필요 없이 그냥 받아드리면 됨
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
                self.menuObservable.accept($0)
            })
    }
    
    func changeCount(menu: Menu, increase: Int) {
        menuObservable
            .map { menus in
                menus.map {
                    if $0.id == menu.id {
                        return Menu(id: $0.id, name: $0.name, price: $0.price, count: max($0.count + increase, 0))
                    } else {
                        return $0
                    }
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
}

