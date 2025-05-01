//
//  CoinDetailActions.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import Foundation
import Combine

struct CoinDetailActions {

  private static let basePath = "/coin"
  private static let method   = HTTPMethods.get

  static func publisher(uuid: String) -> AnyPublisher<CoinDetailResponse, APIError> {
    let path = "\(basePath)/\(uuid)"
    return APIRequest<EmptyRequest, CoinDetailResponse>
      .publisher(
        path: path,
        method: method
      )
  }
}
