//
//  HomeViewModel.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {

  @Published private(set) var allVMs: [CoinCellViewModel] = []
  @Published private(set) var displayedVMs: [CoinCellViewModel] = []
  @Published var hasMorePages: Bool = true
  @Published var favoriteUUIDs: Set<String> = []
  @Published var error: APIError?

  private var currentPage = 1
  private let pageSize = 20
  private var cancellables = Set<AnyCancellable>()
  private let api: APIService
  private var isFetching = false
  private var hasReachedEnd = false

  init(apiService: APIService = DefaultAPIService()) {
    self.api = apiService
    fetchNextPage()
  }

  func fetchNextPage() {
    guard !isFetching && !hasReachedEnd else { return }
    isFetching = true

    api.fetchCoins(page: currentPage, limit: pageSize)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        self?.isFetching = false
        if case .failure(let error) = completion {
          self?.error = error
        }
      } receiveValue: { [weak self] coins in
        guard let self = self else { return }

        if coins.isEmpty {
          self.hasReachedEnd = true
          return
        }

        let newVMs = coins.map(CoinCellViewModel.init)
        self.allVMs.append(contentsOf: newVMs)
        self.displayedVMs = self.allVMs
        self.currentPage += 1
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
