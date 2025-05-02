//
//  ImageLoader.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import UIKit
import Combine

final class ImageLoader {
  static let shared = ImageLoader()
  
  private let cache = NSCache<NSURL, UIImage>()
  private var inFlight = [NSURL: AnyPublisher<UIImage?, Never>]()
  private let lock = NSLock()
  
  private init() {}
  
  func publisher(for url: URL) -> AnyPublisher<UIImage?, Never> {
    let nsURL = url as NSURL
    
    // 1) Return cached immediately
    if let image = cache.object(forKey: nsURL) {
      return Just(image).eraseToAnyPublisher()
    }
    
    lock.lock(); defer { lock.unlock() }
    
    // 2) If already fetching, return that publisher
    if let inFlightPub = inFlight[nsURL] {
      return inFlightPub
    }
    
    // 3) Otherwise create a new one
    let pub = URLSession.shared
      .dataTaskPublisher(for: url)
      .map(\.data)
      .map { UIImage(data: $0) }
      .handleEvents(receiveOutput: { [weak self] img in
        if let img = img {
          self?.cache.setObject(img, forKey: nsURL)
        }
      })
      .catch { _ in Just(nil) }
      .share()
      .eraseToAnyPublisher()
    
    inFlight[nsURL] = pub

    // remove from inFlight once complete
    pub
      .sink { [weak self] _ in
        self?.lock.lock()
        self?.inFlight.removeValue(forKey: nsURL)
        self?.lock.unlock()
      }
      .cancel()

    return pub
  }
}
