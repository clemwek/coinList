//
//  CoinCellViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import UIKit
import Combine

class CoinCellViewModel: ObservableObject {

  private let coin: CoinModel

  let uuid: String
  let name: String
  let priceText: String
  let changeText: String
  let changeValue: Double
  @Published var iconImage: UIImage?

  private var cancellable: AnyCancellable?

  init(coin: CoinModel) {
    self.coin        = coin
    self.uuid        = coin.uuid
    self.name        = coin.name
    self.changeValue = Double(coin.change) ?? 0
    self.priceText   = String(format: "$%.2f", Double(coin.price) ?? 0)
    self.changeText  = String(format: "%+.2f%%", changeValue)

    loadImage(from: coin.iconUrl)
  }

  private func loadImage(from urlString: String) {
    guard let url = URL(string: urlString) else { return }
    cancellable = ImageLoader.shared
      .publisher(for: url)
      .receive(on: DispatchQueue.main)
      .assign(to: \.iconImage, on: self)
  }

  deinit {
    cancellable?.cancel()
  }
}
