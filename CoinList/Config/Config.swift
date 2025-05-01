//
//  Config.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

class Config {

  static let shared = Config()

  let scheme: String = "https"
  let host: String = "api.coinranking.com"
  let apiVersion: String = "/v2"
}
