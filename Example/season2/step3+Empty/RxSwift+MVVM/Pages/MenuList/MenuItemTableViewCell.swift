//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!

//    var viewModel: MenuListViewModel! // 방법1) 시킬 viewModel 받아오기
    var onChange: ((Int) -> Void)?  // 방법2) 클로저로 +,- 인걸 받아오기 (Int를 넘겨주면 반환값아 없는 함수를 리턴하는 클로저)
    
    @IBAction func onIncreaseCount() {
        // 방법1) viewModel한테 시키키
//        viewModel.changeCount()
        
        // 방법2) 클로저로 처리는 뷰컨에서 하도록 (뷰컨에서 뷰모델한테 시킴)
        onChange?(+1)
    }

    @IBAction func onDecreaseCount() {
        onChange?(-1)
    }
}
