//
//  CoinResponse.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

struct CoinResponseData: Decodable {

  let stats: CoinStatsModel
  let coins: [CoinModel]
}

struct CoinResponse: Decodable {

  let status: String
  let data: CoinResponseData
}
