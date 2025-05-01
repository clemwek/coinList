//
//  HomeViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
  
  @Published var coins: [CoinModel] = []
  @Published var error: APIError?
  
  private var cancellables = Set<AnyCancellable>()
  
  func fetchCoins() {
    CoinActions.publisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        if case let .failure(err) = completion {
          self?.error = err
        }
      } receiveValue: { [weak self] response in
        self?.error = nil
        self?.coins = response.data.coins
      }
      .store(in: &cancellables)
  }
}
