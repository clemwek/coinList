//
//  APIRequest.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Foundation
import Combine

struct EmptyRequest: Encodable {}
struct EmptyResponse: Decodable {}

enum HTTPMethods: String {

  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

class APIRequest<Parameters: Encodable, Model: Decodable> {

  static func publisher(
    scheme: String = Config.shared.scheme,
    host:   String = Config.shared.host,
    path:   String,
    method: HTTPMethods,
    authorized: Bool = false,
    queryItems: [URLQueryItem]? = nil,
    parameters: Parameters? = nil,
    mockData: Data? = nil
  ) -> AnyPublisher<Model, APIError> {

    if let mock = mockData {
      return Just(mock)
        .decode(type: Model.self, decoder: JSONDecoder())
        .mapError { _ in .jsonDecoding }
        .eraseToAnyPublisher()
    }

    guard NetworkMonitor.shared.isReachable else {
      return Fail(error: .noInternet).eraseToAnyPublisher()
    }

    var components = URLComponents()
    components.scheme = scheme
    components.host   = host
    components.path   = Config.shared.apiVersion + path

    var items = queryItems ?? []

    if method == .get, let params = parameters {
      if let data = try? JSONEncoder().encode(params),
         let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        let paramItems = dict.compactMap { key, value -> URLQueryItem? in
          switch value {
          case let s as String:  return URLQueryItem(name: key, value: s)
          case let n as NSNumber: return URLQueryItem(name: key, value: n.stringValue)
          default:                return nil
          }
        }
        items.append(contentsOf: paramItems)
      }
    }
    
    components.queryItems = items

    guard let url = components.url else {
      return Fail(error: .response).eraseToAnyPublisher()
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    if method != .get, let params = parameters {
      request.httpBody = try? JSONEncoder().encode(params)
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    return URLSession.shared
      .dataTaskPublisher(for: request)
      .map(\.data)
      .decode(type: Model.self, decoder: JSONDecoder())
      .mapError { error in
        switch error {
        case is URLError:          return .response
        case is DecodingError:     return .jsonDecoding
        default:                   return .response
        }
      }
      .eraseToAnyPublisher()
  }
}
