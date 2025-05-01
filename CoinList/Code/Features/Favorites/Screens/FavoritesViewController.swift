//
//  FavoritesViewController.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//
import UIKit
import Combine

class FavoritesViewController: UIViewController {
  // MARK: – Dependencies
  private let viewModel: HomeViewModel
  
  // MARK: – UI
  private let tableView = UITableView()
  
  // MARK: – State
  private var favoriteVMs: [CoinCellViewModel] = []
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: – Init
  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    title = "Favorites"
  }
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: – Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupTableView()
    bindViewModel()
  }
  
  // MARK: – Setup
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
  
  // MARK: – Bindings
  private func bindViewModel() {
    // Combine allVMs + favoriteUUIDs, then filter
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

// MARK: – UITableViewDataSource
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

// MARK: – UITableViewDelegate
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
  
  // Swipe left → unfavorite
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
