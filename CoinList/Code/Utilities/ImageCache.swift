//
//  ImageCache.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import Foundation
import UIKit

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}
