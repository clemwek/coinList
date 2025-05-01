//
//  CoinDetailViewController.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import UIKit
import Combine
import SwiftUI

class CoinDetailViewController: UIViewController {
  private let viewModel: CoinDetailViewModel
  private var subs = Set<AnyCancellable>()

  private let nameLabel  = UILabel()
  private let priceLabel = UILabel()
  private let segment    = UISegmentedControl(items: CoinDetailViewModel.Period.allCases.map { $0.title })
  private var chartHost : UIHostingController<PerformanceChartView>!
  private let statsStack = UIStackView()

  init(uuid: String) {
    self.viewModel = CoinDetailViewModel(uuid: uuid)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError() }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupUI()
    bindViewModel()
  }
  
  private func setupUI() {
    nameLabel.font  = .systemFont(ofSize: 24, weight: .bold)
    priceLabel.font = .systemFont(ofSize: 20, weight: .medium)
    segment.selectedSegmentIndex = 0
    
    [nameLabel, priceLabel, segment, statsStack].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
    
    chartHost = UIHostingController(rootView: PerformanceChartView(data: []))
    addChild(chartHost)
    chartHost.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(chartHost.view)
    chartHost.didMove(toParent: self)
    
    statsStack.axis = .vertical
    statsStack.spacing = 8
    
    NSLayoutConstraint.activate([
      nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      
      priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
      priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      
      segment.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
      segment.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      segment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      
      chartHost.view.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 16),
      chartHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      chartHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      chartHost.view.heightAnchor.constraint(equalToConstant: 200),
      
      statsStack.topAnchor.constraint(equalTo: chartHost.view.bottomAnchor, constant: 16),
      statsStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      statsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])

    segment.addTarget(self, action: #selector(didChangePeriod), for: .valueChanged)
  }

  private func bindViewModel() {
    viewModel.$coin
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] detail in
        self?.nameLabel.text  = detail.name
        self?.priceLabel.text = String(format: "$%.2f", Double(detail.price) ?? 0)
        self?.buildStats(with: detail)
      }
      .store(in: &subs)

    viewModel.$sparkline
      .receive(on: DispatchQueue.main)
      .sink { [weak self] data in
        self?.chartHost.rootView = PerformanceChartView(data: data)
      }
      .store(in: &subs)

    viewModel.$error
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] error in
        let alert = UIAlertController(
          title: "Error",
          message: error.rawValue,
          preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        self?.present(alert, animated: true)
      }
      .store(in: &subs)
  }

  @objc private func didChangePeriod() {
    guard let period = CoinDetailViewModel.Period(rawValue: segment.selectedSegmentIndex) else { return }
    viewModel.filterSparkline(for: period)
  }

  private func buildStats(with coin: CoinDetail) {
    statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let items: [(label: String, value: String)] = [
      ("Market Cap", coin.marketCap),
      ("24h Volume", coin.volume24h),
      ("Rank", "\(coin.rank)"),
      ("Change", "\(coin.change)%")
    ]

    for item in items {
      let lbl = UILabel()
      lbl.font = .systemFont(ofSize: 16)
      lbl.text = "\(item.label): \(item.value)"
      statsStack.addArrangedSubview(lbl)
    }
  }
}
