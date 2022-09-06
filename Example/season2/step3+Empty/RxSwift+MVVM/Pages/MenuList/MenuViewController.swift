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
    
    let viewModel = MenuListViewModel()
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        viewModel.totalPrice
            .scan(0, accumulator: +) // 0부터 시작해서 새로운 값이 들어오면 + 해라
            .map{ $0.currencyKR() }
            .subscribe(onNext: {
                self.totalPrice.text = $0
            })
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
        viewModel.totalPrice.onNext(100)    // 이렇게만 해주면 누를 때마다 100을 계속 보냄(누적은 안 됨)
        updateUI()
    }
    
    func updateUI() {
        itemCountLabel.text = "\(viewModel.itemsCount)"
//        totalPrice.text = viewModel.totalPrice.currencyKR()
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menus.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell

        let menu = viewModel.menus[indexPath.row]
        cell.title.text = menu.name
        cell.price.text = String(menu.price)
        cell.count.text = String(menu.count)

        return cell
    }
}
