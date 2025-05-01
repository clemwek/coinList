//
//  CoinStatusModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

struct CoinStatsModel: Decodable {

  let total: Int
  let totalCoins: Int
  let totalMarkets: Int
  let totalExchanges: Int
  let totalMarketCap: String
  let total24hVolume: String

  private enum CodingKeys: String, CodingKey {
    case total, totalCoins, totalMarkets, totalExchanges
    case totalMarketCap
    case total24hVolume
  }
}
