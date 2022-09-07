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
                
                cell.onChange = { [weak self] Increase in
                    self?.viewModel.changeCount(menu: item, increase: Increase)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.itemsCount.map { "\($0)" }
            .catchErrorJustReturn("") // 에러가 발생한다고 끊기지 말고 그냥 빈문자열을 내보내라 = UI는 에러난다고 스트림이 끊어져버리면 안되니 따로 처리
            .observeOn(MainScheduler.instance)
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        viewModel.totalPrice
            .map{ $0.currencyKR() }
            .asDriver(onErrorJustReturn: "")    // 에러가 발생하면 리턴할 값도 알려줌
            .drive(totalPrice.rx.text)  // Driver는 항상 메인스레드에서 돌아감
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
