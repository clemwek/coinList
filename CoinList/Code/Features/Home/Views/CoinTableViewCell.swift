//
//  CoinTableViewCell.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//
//
//  CoinTableViewCell.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import UIKit
import Combine

class CoinTableViewCell: UITableViewCell {

  static let reuseID = "CoinCell"

  private var subscriptions = Set<AnyCancellable>()
  private var viewModel: CoinCellViewModel?

  private let iconView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.layer.cornerRadius = 20
    iv.clipsToBounds = true
    return iv
  }()

  private let nameLabel: UILabel = {
    let lbl = UILabel()
    lbl.font = .systemFont(ofSize: 16, weight: .medium)
    return lbl
  }()

  private let priceLabel: UILabel = {
    let lbl = UILabel()
    lbl.font = .systemFont(ofSize: 14, weight: .regular)
    return lbl
  }()

  private let changeLabel: UILabel = {
    let lbl = UILabel()
    lbl.font = .systemFont(ofSize: 14, weight: .regular)
    lbl.textAlignment = .right
    return lbl
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    [iconView, nameLabel, priceLabel, changeLabel].forEach {
      contentView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    setupConstraints()
  }

  required init?(coder: NSCoder) { fatalError() }

  override func prepareForReuse() {
    super.prepareForReuse()

    subscriptions.forEach { $0.cancel() }
    subscriptions.removeAll()
    iconView.image = nil
  }

  func configure(with vm: CoinCellViewModel) {
    subscriptions.forEach { $0.cancel() }
    subscriptions.removeAll()
    iconView.image = nil

    nameLabel.text   = vm.name
    priceLabel.text  = vm.priceText
    changeLabel.text = vm.changeText
    changeLabel.textColor = vm.changeValue >= 0 ? .systemGreen : .systemRed

    if let img = vm.iconImage {
      iconView.image = img
    }

    vm.$iconImage
      .receive(on: DispatchQueue.main)
      .prepend(vm.iconImage)
      .compactMap { $0 }
      .sink { [weak self] img in
        self?.iconView.image = img
      }
      .store(in: &subscriptions)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 40),
      iconView.heightAnchor.constraint(equalToConstant: 40),

      nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
      nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

      priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
      priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

      changeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      changeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      changeLabel.widthAnchor.constraint(equalToConstant: 80)
    ])
  }
}
