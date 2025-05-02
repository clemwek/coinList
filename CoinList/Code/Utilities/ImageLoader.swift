//
//  ImageLoader.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import UIKit
import Combine

protocol ImageLoading {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoader: ImageLoading {
  
  static let shared = ImageLoader()
  
  private let cache: NSCache<NSURL, UIImage>
  private var inFlightRequests: [NSURL: AnyPublisher<UIImage?, Never>]
  private let lock: NSLock
  
  private init() {
    self.cache = NSCache<NSURL, UIImage>()
    self.cache.countLimit = 100
    self.inFlightRequests = [:]
    self.lock = NSLock()
  }
  
  func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
    let nsURL = url as NSURL
    
    // 1. Return cached image if available
    if let cachedImage = cache.object(forKey: nsURL) {
      return Just(cachedImage).eraseToAnyPublisher()
    }
    
    lock.lock()
    defer { lock.unlock() }
    
    // 2. Return existing publisher if request is in flight
    if let existingPublisher = inFlightRequests[nsURL] {
      return existingPublisher
    }
    
    // 3. Create new request
    let publisher = URLSession.shared.dataTaskPublisher(for: url)
      .map { data, _ -> UIImage? in
        // Process image on background thread
        UIImage(data: data)?.resized(to: CGSize(width: 200, height: 200))
      }
      .replaceError(with: nil)
      .handleEvents(
        receiveOutput: { [weak self] image in
          guard let self = self, let image = image else { return }
          self.cache.setObject(image, forKey: nsURL)
        },
        receiveCompletion: { [weak self] _ in
          self?.removeRequest(for: nsURL)
        },
        receiveCancel: { [weak self] in
          self?.removeRequest(for: nsURL)
        }
      )
      .share()
      .eraseToAnyPublisher()
    
    // Store the publisher
    inFlightRequests[nsURL] = publisher
    return publisher
  }
  
  private func removeRequest(for url: NSURL) {
    lock.lock()
    defer { lock.unlock() }
    inFlightRequests.removeValue(forKey: url)
  }
}
