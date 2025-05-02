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
  @Published var favoriteUUIDs: Set<String> = []
  @Published var error: APIError?
  @Published var isLoading = false

  private var currentPage = 1
  private let pageSize = 20
  private var cancellables = Set<AnyCancellable>()
  private let api: APIService
  private var hasReachedEnd = false
  private let imageLoader: ImageLoading

  private var isFetching = false
  @Published var hasMorePages: Bool = true

  init(apiService: APIService = DefaultAPIService(),
       imageLoader: ImageLoading = ImageLoader.shared) {
    self.api = apiService
    self.imageLoader = imageLoader

//    fetchNextPage()
  }

  func createViewModels(from coins: [CoinModel]) -> [CoinCellViewModel] {
    coins.map { coin in
      CoinCellViewModel(coin: coin, imageLoader: imageLoader)
    }
  }
  
//  func fetchNextPage() {
//    // Add a check if we've reached the end
//    guard !isFetching && !hasReachedEnd else { return }
//    isFetching = true
//    error = nil
//    
//    api.fetchCoins(page: currentPage, limit: pageSize)
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] completion in
//        self?.isFetching = false
//        if case .failure(let error) = completion {
//          self?.error = error
//        }
//      } receiveValue: { [weak self] coins in
//        guard let self = self else { return }
//
//        if coins.isEmpty {
//          self.hasReachedEnd = true
//          return
//        }
//
//        let newVMs = coins.map { coin in
//          CoinCellViewModel(coin: coin, imageLoader: self.imageLoader)
//        }
//
//        let uniqueNewVMs = newVMs.filter { newVM in
//          !self.allVMs.contains(where: { $0.uuid == newVM.uuid })
//        }
//
//        self.allVMs.append(contentsOf: newVMs)
//        self.displayedVMs = self.allVMs
//        self.currentPage += 1
//      }
//      .store(in: &cancellables)
//  }

  func fetchNextPage() {
    // Prevent multiple simultaneous requests
    guard !isLoading && !hasReachedEnd else { return }
    
    isLoading = true
    error = nil  // Clear previous errors
    
    api.fetchCoins(page: currentPage, limit: pageSize)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        self?.isLoading = false
        
        if case .failure(let error) = completion {
          self?.error = error
        }
      } receiveValue: { [weak self] coins in
        guard let self = self else { return }

        if coins.isEmpty {
          self.hasReachedEnd = true
          return
        }

        let newVMs = coins.map { coin in
          CoinCellViewModel(coin: coin, imageLoader: self.imageLoader)
        }

        let uniqueNewVMs = newVMs.filter { newVM in
          !self.allVMs.contains(where: { $0.uuid == newVM.uuid })
        }

        self.allVMs.append(contentsOf: uniqueNewVMs)
        self.displayedVMs = self.allVMs
        self.currentPage += 1
      }
      .store(in: &cancellables)
  }
  
  func retryLastFetch() {
    // Reset error state and try again
    error = nil
    hasReachedEnd = false
    fetchNextPage()
  }
  
  func refreshAllData() {
    // Reset all state and start fresh
    cancellables.removeAll()
    currentPage = 1
    hasReachedEnd = false
    allVMs.removeAll()
    displayedVMs.removeAll()
    error = nil
    fetchNextPage()
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
