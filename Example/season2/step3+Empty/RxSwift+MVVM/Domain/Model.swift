//
//  Model.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation

struct MenuItem: Decodable { // 서버에서 보내주는 데이터
    var name: String
    var price: Int
}
