//
//  HomeViewController.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

  private var viewModel: HomeViewModel!
  private var subscriptions = Set<AnyCancellable>()

  private let tableView = UITableView()
  private let search    = UISearchController(searchResultsController: nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = HomeViewModel()
    setupUI()
    setupBindings()
    viewModel.fetchCoins()
  }

  private func setupUI() {
    view.backgroundColor = .systemBackground
    navigationItem.searchController = search
    // add & layout tableView…
    view.addSubview(tableView)
    tableView.frame = view.bounds
    tableView.dataSource = self
  }

  private func setupBindings() {
    // Reload when coins change
    viewModel.$coins
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in self?.tableView.reloadData() }
      .store(in: &subscriptions)

    // Show an alert on error
    viewModel.$error
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] err in
        let alert = UIAlertController(
          title: "Error",
          message: err.rawValue,
          preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        self?.present(alert, animated: true)
      }
      .store(in: &subscriptions)
  }
}

extension HomeViewController: UITableViewDataSource {

  func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.coins.count
  }

  func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // dequeue & configure with viewModel.coins[indexPath.row]
    let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
    ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
    let coin = viewModel.coins[indexPath.row]
    cell.textLabel?.text = coin.name
    cell.detailTextLabel?.text = "$" + coin.price
    return cell
  }
}
