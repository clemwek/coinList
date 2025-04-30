//
//  HomeViewController.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import UIKit

class HomeViewController: UIViewController {
  
  let search = UISearchController(searchResultsController: nil)
//  search.searchResultsUpdater = self
//

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    navigationItem.searchController = search
  }
}
