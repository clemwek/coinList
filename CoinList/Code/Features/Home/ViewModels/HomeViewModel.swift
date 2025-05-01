//
//  HomeViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {

  @Published private(set) var allVMs: [CoinCellViewModel] = []
  @Published var displayedVMs: [CoinCellViewModel] = []
  @Published var favoriteUUIDs: Set<String> = []
  @Published var error: APIError?

  private var cancellables = Set<AnyCancellable>()

  func toggleFavorite(uuid: String) {
    if favoriteUUIDs.contains(uuid) {
      favoriteUUIDs.remove(uuid)
    } else {
      favoriteUUIDs.insert(uuid)
    }
  }

  func fetchCoins() {
    let req = CoinRequest(page: 1, limit: 100)
    CoinActions.publisher(request: req)
      .map { $0.data.coins.map(CoinCellViewModel.init) }
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case let .failure(e) = completion { self.error = e }
      } receiveValue: { vms in
        self.allVMs       = vms
        self.displayedVMs = vms
      }
      .store(in: &cancellables)
  }

  func filter(by searchText: String) {
    guard !searchText.isEmpty else {
      displayedVMs = allVMs
      return
    }
    displayedVMs = allVMs.filter {
      $0.name.lowercased().contains(searchText.lowercased())
    }
  }
}
