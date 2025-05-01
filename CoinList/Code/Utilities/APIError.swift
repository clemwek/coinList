//
//  APIError.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

enum APIError: String, Error {

  case jsonDecoding
  case response
  case noInternet
}
