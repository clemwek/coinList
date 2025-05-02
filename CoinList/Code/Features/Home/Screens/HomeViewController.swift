//
//  HomeViewController.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

  private let viewModel: HomeViewModel
  private var subs = Set<AnyCancellable>()
  private let tableView = UITableView()
  private let searchController = UISearchController(searchResultsController: nil)

  private let refreshControl = UIRefreshControl()

  init(viewModel: HomeViewModel = HomeViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    setupSearchController()
    setupTableView()
    bindViewModel()

    viewModel.fetchCoins()
  }
  
  @objc private func refreshData() {
    viewModel.fetchCoins()
  }

  private func setupSearchController() {
    navigationItem.searchController = searchController
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    navigationItem.hidesSearchBarWhenScrolling = false
  }
  
  private func showErrorAlert(error: APIError) {
    let alert = UIAlertController(
      title: "Error",
      message: error.localizedDescription,
      preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(
      title: "Retry",
      style: .default,
      handler: { [weak self] _ in
        self?.viewModel.retryLastFetch()
      }
    ))

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alert, animated: true)
  }

  private func setupTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(CoinTableViewCell.self,
                       forCellReuseIdentifier: CoinTableViewCell.reuseID)
    tableView.register(LoadingTableViewCell.self,
                       forCellReuseIdentifier: LoadingTableViewCell.reuseID)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.prefetchDataSource = self
    tableView.keyboardDismissMode = .onDrag

    let refresh = UIRefreshControl()
    refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    tableView.refreshControl = refresh

    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  private func bindViewModel() {
    viewModel.$displayedVMs
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.tableView.reloadData()
      }
      .store(in: &subs)

    viewModel.$hasMorePages
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.tableView.reloadData()
      }
      .store(in: &subs)

    viewModel.$error
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] error in
        self?
          .showErrorAlert(error: error)
      }
      .store(in: &subs)

    viewModel.$displayedVMs
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.tableView.reloadData()
        self?.tableView.refreshControl?.endRefreshing()
      }
      .store(in: &subs)
  }
}

extension HomeViewController: UISearchBarDelegate {

  func searchBar(_ sb: UISearchBar,
                 textDidChange text: String) {
    viewModel.filter(by: text)
  }
}

extension HomeViewController: UITableViewDataSource {

  func tableView(_ tv: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    let count = viewModel.displayedVMs.count
    return viewModel.hasMorePages ? count + 1 : count
  }

  func tableView(_ tv: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let count = viewModel.displayedVMs.count
    if indexPath.row < count {
      let cell = tv.dequeueReusableCell(
        withIdentifier: CoinTableViewCell.reuseID,
        for: indexPath
      ) as! CoinTableViewCell
      let vm = viewModel.displayedVMs[indexPath.row]
      cell.configure(with: vm)
      cell.accessoryType = viewModel.favoriteUUIDs.contains(vm.uuid) ? .checkmark : .none
      return cell
    } else {
      let cell = tv.dequeueReusableCell(
        withIdentifier: LoadingTableViewCell.reuseID,
        for: indexPath
      ) as! LoadingTableViewCell
      cell.activityIndicator.startAnimating()
      return cell
    }
  }
}

extension HomeViewController: UITableViewDelegate {

  func tableView(_ tv: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    let count = viewModel.displayedVMs.count
    guard indexPath.row < count else { return }

    tv.deselectRow(at: indexPath, animated: true)
    let vm = viewModel.displayedVMs[indexPath.row]
    let detailVC = CoinDetailViewController(uuid: vm.uuid)
    navigationController?.pushViewController(detailVC, animated: true)
  }

  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    let count = viewModel.displayedVMs.count
    guard indexPath.row < count else { return nil }

    let vm = viewModel.displayedVMs[indexPath.row]
    let isFav = viewModel.favoriteUUIDs.contains(vm.uuid)

    let action = UIContextualAction(
      style: .normal,
      title: isFav ? "Unfavorite" : "Favorite"
    ) { [weak self] _, _, completion in
      guard let self = self else { return completion(false) }
      self.viewModel.toggleFavorite(uuid: vm.uuid)

      self.tableView.reloadRows(at: [indexPath], with: .automatic)

      completion(true)
    }
    action.backgroundColor = isFav ? .systemGray : .systemOrange

    return UISwipeActionsConfiguration(actions: [action])
  }

  func tableView(_ tv: UITableView,
                 willDisplay cell: UITableViewCell,
                 forRowAt indexPath: IndexPath) {
    if viewModel.hasMorePages && indexPath.row == viewModel.displayedVMs.count {
      viewModel.fetchNextPage()
    }
  }
}

extension HomeViewController: UITableViewDataSourcePrefetching {

  func tableView(_ tv: UITableView,
                 prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { idx in
      let count = viewModel.displayedVMs.count
      if idx.row < count {
        let vm = viewModel.displayedVMs[idx.row]
        _ = vm.iconImage
      }
    }
  }
}


private class LoadingTableViewCell: UITableViewCell {

  static let reuseID = "LoadingCell"
  let activityIndicator = UIActivityIndicatorView(style: .medium)

  override init(style: UITableViewCell.CellStyle,
                reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(activityIndicator)
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    selectionStyle = .none
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
