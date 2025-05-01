//
//  HomeViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
  // MARK: – Published outputs
  @Published private(set) var allVMs: [CoinCellViewModel] = []
  @Published private(set) var displayedVMs: [CoinCellViewModel] = []
  @Published var favoriteUUIDs: Set<String> = []
  @Published var error: APIError?

  // MARK: – Internals
  private var currentPage = 1
  private let pageSize = 20
  private var cancellables = Set<AnyCancellable>()
  private let api: APIService

  init(apiService: APIService = DefaultAPIService()) {
    self.api = apiService
    fetchNextPage()
  }

  // MARK: – Paging
  func fetchNextPage() {
    api.fetchCoins(page: currentPage, limit: pageSize)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        if case let .failure(err) = completion {
          self?.error = err
        }
      } receiveValue: { [weak self] coins in
        guard let self = self else { return }
        let newVMs = coins.map(CoinCellViewModel.init)

        let filtered = newVMs.filter { new in
          !self.allVMs.contains(where: { $0.uuid == new.uuid })
        }

        self.allVMs += filtered
        self.displayedVMs = self.allVMs
        self.currentPage += 1
      }
      .store(in: &cancellables)
  }

  func loadMoreIfNeeded(at index: Int) {
    let threshold = allVMs.count - 10
    if index >= threshold {
      fetchNextPage()
    }
  }

  // MARK: – Search Filtering
  func filter(by searchText: String) {
    guard !searchText.isEmpty else {
      displayedVMs = allVMs
      return
    }
    displayedVMs = allVMs.filter {
      $0.name.lowercased().contains(searchText.lowercased())
    }
  }

  // MARK: – Favorites
  func toggleFavorite(uuid: String) {
    if favoriteUUIDs.contains(uuid) {
      favoriteUUIDs.remove(uuid)
    } else {
      favoriteUUIDs.insert(uuid)
    }
  }
}

extension HomeViewModel {

  func fetchCoins() {
    currentPage = 1
    allVMs.removeAll()
    displayedVMs.removeAll()
    fetchNextPage()
  }
}
