//
//  CoinModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Foundation

struct CoinModel: Codable {

  let uuid: String
  let symbol: String
  let name: String
  let color: String?
  let iconUrl: String
  let marketCap: String
  let price: String
  let listedAt: Int
  let tier: Int
  let change: String
  let rank: Int
  let sparkline: [String?]?
  let lowVolume: Bool
  let coinrankingUrl: String
  let volume24h: String
  let btcPrice: String
  let contractAddresses: [String]

  private enum CodingKeys: String, CodingKey {
    case uuid, symbol, name, color, iconUrl
    case marketCap, price, listedAt, tier, change, rank
    case sparkline, lowVolume, coinrankingUrl
    case volume24h  = "24hVolume"
    case btcPrice, contractAddresses
  }
}
