import Foundation

struct CoinDetailResponse: Decodable {

  let status: String
  let data: CoinDetailData
}

struct CoinDetailData: Decodable {

  let coin: CoinDetail
}

struct CoinDetail: Decodable {

  let uuid: String
  let symbol: String
  let name: String
  let description: String
  let color: String
  let iconUrl: URL
  let websiteUrl: URL
  let links: [Link]
  let supply: Supply

  let volume24h: String
  let marketCap: String
  let fullyDilutedMarketCap: String
  let price: String
  let btcPrice: String
  let priceAt: Int
  let change: String
  let rank: Int

  let numberOfMarkets: Int
  let numberOfExchanges: Int
  let sparkline: [String]
  let allTimeHigh: AllTimeHigh

  let tier: Int?
  let coinrankingUrl: URL
  let lowVolume: Bool
  let listedAt: Int
  let notices: [Notice]?
  let hasContent: Bool?
  let contractAddresses: [String]
  let tags: [String]

  private enum CodingKeys: String, CodingKey {
    case uuid, symbol, name, description, color, iconUrl, websiteUrl, links, supply
    case volume24h            = "24hVolume"
    case marketCap
    case fullyDilutedMarketCap
    case price, btcPrice, priceAt, change, rank
    case numberOfMarkets, numberOfExchanges, sparkline, allTimeHigh
    case coinrankingUrl, lowVolume, listedAt, notices, contractAddresses, tags
    case tier, hasContent
  }
}

struct Link: Decodable {

  let name: String
  let url: URL
  let type: String
}

struct Supply: Decodable {

  let confirmed: Bool
  let supplyAt: Int
  let circulating: String
  let total: String
  let max: String?
}

struct AllTimeHigh: Decodable {

  let price: String
  let timestamp: Int
}

struct Notice: Decodable {

  let type: String
  let value: String
}
