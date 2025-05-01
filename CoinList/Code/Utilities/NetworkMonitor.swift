//
//  NetworkMonitor.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Network

class NetworkMonitor {

  static let shared: NetworkMonitor = NetworkMonitor()

  let monitor = NWPathMonitor()
  private var status: NWPath.Status = .requiresConnection
  var isReachable: Bool { status == .satisfied }

  func startMonitoring() {
    monitor.pathUpdateHandler = { path in
      self.status = path.status
    }

    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
  }

  func stopMonitoring() {
    monitor.cancel()
  }
}
