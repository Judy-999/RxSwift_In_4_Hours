//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MenuViewController: UIViewController {
    
    let cellId = "MenuItemTableViewCell"
    let viewModel = MenuListViewModel()
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil // 데이터소스 연결 끊기, 데이터소스 없이도 테이블뷰 값이 바뀌면 자동으로 업데이트 되도록
        
        // viewModel의 menus는 테이블 뷰의 데이터들과 연결해야 함
        viewModel.menuObservable
            .observeOn(MainScheduler.instance)
        // 테이블 뷰의 셀들은 결국 datasource임 -> datasource를 사용하려면 cell identifier, cell 타입을 알아야 함
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                // dequeue를 해줌
                cell.title.text = item.name
                cell.price.text = String(item.price)  // menuObservable이 바끠면 테이블뷰(셀)이 바뀔텐데 이 때 셀을 이렇게 바꿔라
                cell.count.text = String(item.count)
            }
            .disposed(by: disposeBag)
       // ---> 결국 DataSource가 필요없음
        
        viewModel.itemsCount.map { "\($0)" }
            .observeOn(MainScheduler.instance)
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        viewModel.totalPrice
            .scan(0, accumulator: +)
            .map{ $0.currencyKR() }
            .observeOn(MainScheduler.instance)
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
        
//        viewModel.totalPrice += 100 이렇게 하나하나 해주고 UI업데이트를 직접 부르지말고 값이 변경되면 바로 바뀌면 좋겠다..!
        
        // 값을 어떻게 변경하지? 옵저버블은 값을 넘겨주는 애지 값을 받아서 주는 애가 아님
        // 옵저버블처럼 값은 넘거주는데 밖에서 값을 컨트롤할 수는 없을까? --> Subject
//        viewModel.totalPrice.onNext(100)
    }
}

//extension MenuViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.menus.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//
//        let menu = viewModel.menus[indexPath.row]
//        cell.title.text = menu.name
//        cell.price.text = String(menu.price)
//        cell.count.text = String(menu.count)
//
//        return cell
//    }
//}
