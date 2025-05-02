//
//  DefaultAPIService.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import Foundation
import Combine

final class DefaultAPIService: APIService {

  private let decoder = JSONDecoder()

  func fetchCoins(page: Int, limit: Int) -> AnyPublisher<[CoinModel], APIError> {
    let req = CoinRequest(offset: page, limit: limit)
    return CoinActions
      .publisher(request: req)
      .map { $0.data.coins }
      .retry(1)
      .mapError { error -> APIError in
        return error
      }
      .eraseToAnyPublisher()
  }

  func fetchCoinDetail(uuid: String) -> AnyPublisher<CoinDetail, APIError> {
    CoinDetailActions
      .publisher(uuid: uuid)
      .map(\.data.coin)
      .retry(1)
      .eraseToAnyPublisher()
  }
}
