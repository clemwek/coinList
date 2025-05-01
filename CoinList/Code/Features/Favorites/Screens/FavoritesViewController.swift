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
  private var subscriptions = Set<AnyCancellable>()
  private var favoriteVMs: [CoinCellViewModel] = []

  private let tableView: UITableView = {
    let tv = UITableView()
    tv.register(CoinTableViewCell.self,
                forCellReuseIdentifier: CoinTableViewCell.reuseID)
    return tv
  }()

  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.delegate   = self
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    bindViewModel()
  }
  
  private func bindViewModel() {
    Publishers
      .CombineLatest(viewModel.$allVMs, viewModel.$favoriteUUIDs)
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

  func tableView(_ tv: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    favoriteVMs.count
  }
  
  func tableView(_ tv: UITableView,
                 cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tv.dequeueReusableCell(
      withIdentifier: CoinTableViewCell.reuseID,
      for: indexPath
    ) as! CoinTableViewCell
    cell.configure(with: favoriteVMs[indexPath.row])
    return cell
  }
}

extension FavoritesViewController: UITableViewDelegate {

  func tableView(_ tv: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    tv.deselectRow(at: indexPath, animated: true)
    let vm = favoriteVMs[indexPath.row]
    let detailVC = CoinDetailViewController(uuid: vm.uuid)
    navigationController?.pushViewController(detailVC, animated: true)
  }

  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    let vm = favoriteVMs[indexPath.row]
    let action = UIContextualAction(
      style: .normal,
      title: "Unfavorite"
    ) { [weak self] _, _, completion in
      self?.viewModel.toggleFavorite(uuid: vm.uuid)
      completion(true)
    }
    action.backgroundColor = .systemRed
    return UISwipeActionsConfiguration(actions: [action])
  }
}

