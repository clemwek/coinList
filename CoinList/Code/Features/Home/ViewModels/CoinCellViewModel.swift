//
//  CoinCellViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import UIKit
import Combine

class CoinCellViewModel: ObservableObject {

  @Published var iconImage: UIImage?
  let uuid: String
  let name: String
  let priceText: String
  let changeText: String
  let changeValue: Double

  private var cancellable: AnyCancellable?
  private let imageLoader: ImageLoading

  init(coin: CoinModel, imageLoader: ImageLoading) {
    self.uuid = coin.uuid
    self.name = coin.name
    self.changeValue = Double(coin.change) ?? 0
    self.priceText = String(format: "$%.2f", Double(coin.price) ?? 0)
    self.changeText = String(format: "%+.2f%%", changeValue)
    self.imageLoader = imageLoader

    loadImage(from: coin.iconUrl)
  }

  private func loadImage(from urlString: String) {
    guard let url = URL(string: urlString) else {
      iconImage = UIImage(systemName: "coloncurrencysign.circle.fill")
      return
    }

    cancellable = imageLoader.loadImage(from: url)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] image in
        self?.iconImage = image ?? UIImage(systemName: "coloncurrencysign.circle.fill")
      }
  }

  func cancelImageLoading() {
    cancellable?.cancel()
  }
}
