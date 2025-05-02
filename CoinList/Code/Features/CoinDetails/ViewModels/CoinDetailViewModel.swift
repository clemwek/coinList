//
//  CoinDetailViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import Foundation
import Combine

class CoinDetailViewModel: ObservableObject {

  @Published var coin: CoinDetail?
  @Published var sparkline: [Double] = []
  @Published var error: APIError?

  private let api: APIService
  private let uuid: String
  private var cancellables = Set<AnyCancellable>()

  init(uuid: String, apiService: APIService = DefaultAPIService()) {
    self.uuid = uuid
    self.api = apiService
    fetchDetails()
  }

  func fetchDetails() {
    api.fetchCoinDetail(uuid: uuid)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        if case let .failure(err) = completion {
          self?.error = err
        }
      } receiveValue: { [weak self] detail in
        guard let self = self else { return }
        self.coin = detail
        // initialize sparkline with full data
        self.sparkline = detail.sparkline
          .compactMap(Double.init)
      }
      .store(in: &cancellables)
  }

  func filterSparkline(for period: Period) {
    guard let detail = coin else { return }
    let values = detail.sparkline.compactMap(Double.init)
    switch period {
    case .oneDay:
      sparkline = values         // assume full array is 24h
    case .sevenDays:
      sparkline = Array(values.suffix(7))
    case .oneMonth:
      sparkline = Array(values.suffix(30))
    case .oneYear:
      sparkline = values
    }
  }

  enum Period: Int, CaseIterable {
    case oneDay = 0, sevenDays, oneMonth, oneYear
    
    var title: String {
      switch self {
      case .oneDay:   return "1D"
      case .sevenDays:return "7D"
      case .oneMonth: return "1M"
      case .oneYear:  return "1Y"
      }
    }
  }
}

