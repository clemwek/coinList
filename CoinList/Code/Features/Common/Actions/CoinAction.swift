//
//  CoinAction.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Foundation
import Combine

struct CoinActions {

  private let path       = "/coins"
  private let method     = HTTPMethods.get

  static func publisher(request: CoinRequest? = nil) -> AnyPublisher<CoinResponse, APIError> {
    APIRequest<CoinRequest, CoinResponse>
      .publisher(path: "/coins",
                 method: .get,
                 parameters: request)
  }
}
