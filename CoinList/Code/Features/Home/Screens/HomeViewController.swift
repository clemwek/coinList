//
//  HomeViewController.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
  
  private var viewModel = HomeViewModel()
  private var subs = Set<AnyCancellable>()
  private let tableView = UITableView()
  private let search = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Coins"
    navigationItem.searchController = search

    tableView.register(CoinTableViewCell.self,
                       forCellReuseIdentifier: CoinTableViewCell.reuseID)
    tableView.dataSource = self
    tableView.delegate   = self
    
    view.addSubview(tableView)
    tableView.frame = view.bounds

    // Bind data → reload
    viewModel.$displayedVMs
      .receive(on: DispatchQueue.main)
      .sink { _ in self.tableView.reloadData() }
      .store(in: &subs)

    // Bind search text → filter
    search.searchBar.delegate = self

    viewModel.fetchCoins()
  }
}

extension HomeViewController: UISearchBarDelegate {

  func searchBar(_ sb: UISearchBar, textDidChange text: String) {
    viewModel.filter(by: text)
  }
}

extension HomeViewController: UITableViewDataSource {

  func tableView(_ tv: UITableView,
                 numberOfRowsInSection s: Int) -> Int {
    viewModel.displayedVMs.count
  }

  func tableView(_ tv: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tv.dequeueReusableCell(
      withIdentifier: CoinTableViewCell.reuseID,
      for: indexPath
    ) as! CoinTableViewCell

    let cellViewModel = viewModel.displayedVMs[indexPath.row]
    cell.configure(with: cellViewModel)
    cell.accessoryType = viewModel.favoriteUUIDs.contains(cellViewModel.uuid)
       ? .checkmark
       : .none

    return cell
  }
}

extension HomeViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let cellVM = viewModel.displayedVMs[indexPath.row]

    let detailVC = CoinDetailViewController(uuid: cellVM.uuid)
    navigationController?.pushViewController(detailVC, animated: true)
  }

  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    let vm = viewModel.displayedVMs[indexPath.row]
    let isFav = viewModel.favoriteUUIDs.contains(vm.uuid)
    
    let action = UIContextualAction(
      style: .normal,
      title: isFav ? "Unfavorite" : "Favorite"
    ) { [weak self] _, _, completion in
      guard let self = self else { return completion(false) }
      self.viewModel.toggleFavorite(uuid: vm.uuid)

      // reload just this row so the checkmark updates
      self.tableView.reloadRows(at: [indexPath], with: .automatic)

      completion(true)
    }
    action.backgroundColor = isFav ? .systemGray : .systemOrange

    return UISwipeActionsConfiguration(actions: [action])
  }
}
