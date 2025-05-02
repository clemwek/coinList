# CoinList iOS App

**CoinList** is a UIKit-based iOS application built with the MVVM pattern and Combine. It fetches live cryptocurrency data from the CoinRanking API, supports infinite scrolling, pull-to-refresh, favorites management, and detailed coin views with performance charts.

---

## Features

* **Home Screen**

  * Displays a paginated list of cryptocurrencies
  * Pull-to-refresh to reload data
  * Infinite scroll via a loading footer
  * Swipe to favorite/unfavorite coins
  * Search bar to filter by name

* **Coin Detail Screen**

  * Shows coin name, current price, and key statistics
  * Interactive performance chart with time filters (1D, 7D, 1M, 1Y)
  * Handles network errors with alerts

* **Favorites Screen**

  * Lists all favorited coins
  * Swipe to remove favorites
  * Tap to view details

* **Networking**

  * Combine-powered API calls with `APIService` abstraction
  * `NetworkMonitor` for offline detection
  * Exponential retry policy and error mapping

* **Image Loading**

  * Asynchronous, cached image loading via `ImageLoader`
  * In-memory + shared in-flight publishers to avoid duplicate loads

---

## Requirements

* Xcode 14.0+
* iOS 15.0+
* Swift 5.5+

---

## Installation

1. Clone this repository:

   ```bash
   git clone git@github.com:clemwek/coinList.git
   ```
2. Open `CoinList.xcodeproj` in Xcode.
3. Build & run on simulator or device.

---

## Architecture

```
┌────────────────────────┐    ┌──────────────────────────────┐
│        View Controllers│    │       View Models            │
│  - HomeVC              │    │  - HomeViewModel             │
│  - DetailVC            │◀──▶│  - CoinDetailViewModel       │
│  - FavoritesVC         │    └──────────────────────────────┘
└────────────────────────┘
            ▲
            │ binding
            ▼
┌─────────────────────────────┐
│      Models & Actions       │
│  - CoinModel                │
│  - CoinDetail               │
│  - CoinRequest/Response     │
│  - CoinActions/DetailActions│
└─────────────────────────────┘
            ▲
            │ APIService
            ▼
┌────────────────────────┐
│  Networking Layer      │
│  - APIRequest          │
│  - DefaultAPIService   │
│  - NetworkMonitor      │
└────────────────────────┘
```

---

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m "Add feature X"`
4. Push to the branch: `git push origin feature/YourFeature`
5. Open a Pull Request

---

## License

This project is open source and available under the MIT License.
