//
//  APIService.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import Combine

protocol APIService {

  func fetchCoins(page: Int, limit: Int)
  -> AnyPublisher<[CoinModel], APIError>

  func fetchCoinDetail(uuid: String)
  -> AnyPublisher<CoinDetail, APIError>
}
