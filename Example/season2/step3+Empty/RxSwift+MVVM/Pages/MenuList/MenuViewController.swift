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
        
        viewModel.menuObservable
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                cell.title.text = item.name
                cell.price.text = String(item.price)
                cell.count.text = String(item.count)
                
                // +, - 처리를 셀에서 해줘야 함 -> viewModel한테 시키자
                // 방법 1) 셀한테 viewmodel을 보내서 셀한테 시킴(셀이 뷰모델을 들고 있어야(알아야) 함) -> 셀이 다시 viewModel한테 시키기
                // 방법 2) 여기서 viewmodel을 호출해서 item을 넘겨주기 -> 셀이 +,-가 눌렸다는걸 알아야 함 = 셀이 클로저를 들고 있어서 알도록
                
                // 방법 2) 여기서 Void인 부분을 구현해주기
                cell.onChange = { [weak self] Increase in
                    self?.viewModel.changeCount(menu: item, increase: Increase)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.itemsCount.map { "\($0)" }
            .observeOn(MainScheduler.instance)
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        viewModel.totalPrice
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
        // itemCount를 0으로 만들기 -> viewModel한테 시키자
        viewModel.clearAllItemSelections()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
        

    }
}
