//
//  CoinCellViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import Foundation

struct CoinCellViewModel {

  private let coin: CoinModel

  var uuid: String { coin.uuid }
  var name: String { coin.name }
  var iconURL: URL { URL(string: coin.iconUrl)! }

  var priceText: String {
    let p = Double(coin.price) ?? 0
    return String(format: "$%.2f", p)
  }

  var changeText: String {
    let c = Double(coin.change) ?? 0
    return String(format: "%+.2f%%", c)
  }

  var priceValue: Double { Double(coin.price)  ?? 0 }
  var changeValue: Double { Double(coin.change) ?? 0 }

  init(coin: CoinModel) {
    self.coin = coin
  }
}
