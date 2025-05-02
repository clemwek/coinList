//
//  FavoritesViewController.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import UIKit
import Combine

class FavoritesViewController: UIViewController {

  private let viewModel: HomeViewModel
  private let tableView = UITableView()
  private var favoriteVMs: [CoinCellViewModel] = []
  private var subscriptions = Set<AnyCancellable>()

  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    title = "Favorites"
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupTableView()
    bindViewModel()
  }

  private func setupTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(
      CoinTableViewCell.self,
      forCellReuseIdentifier: CoinTableViewCell.reuseID
    )
    tableView.dataSource = self
    tableView.delegate   = self
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(
        equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(
        equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(
        equalTo: view.bottomAnchor)
    ])
  }

  private func bindViewModel() {
    viewModel.$allVMs
      .combineLatest(viewModel.$favoriteUUIDs)
      .map { allVMs, favUUIDs in
        allVMs.filter { favUUIDs.contains($0.uuid) }
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] vms in
        self?.favoriteVMs = vms
        self?.tableView.reloadData()
      }
      .store(in: &subscriptions)
  }
}

extension FavoritesViewController: UITableViewDataSource {

  func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
    favoriteVMs.count
  }
  
  func tableView(
    _ tv: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let vm = favoriteVMs[indexPath.row]
    let cell = tv.dequeueReusableCell(
      withIdentifier: CoinTableViewCell.reuseID,
      for: indexPath
    ) as! CoinTableViewCell
    cell.configure(with: vm)
    return cell
  }
}

extension FavoritesViewController: UITableViewDelegate {

  func tableView(
    _ tv: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    tv.deselectRow(at: indexPath, animated: true)
    let vm = favoriteVMs[indexPath.row]
    let detailVC = CoinDetailViewController(uuid: vm.uuid)
    navigationController?.pushViewController(detailVC, animated: true)
  }

  func tableView(
    _ tv: UITableView,
    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    let vm = favoriteVMs[indexPath.row]
    let action = UIContextualAction(
      style: .destructive,
      title: "Unfavorite"
    ) { [weak self] _, _, completion in
      self?.viewModel.toggleFavorite(uuid: vm.uuid)
      completion(true)
    }
    return UISwipeActionsConfiguration(actions: [action])
  }
}
