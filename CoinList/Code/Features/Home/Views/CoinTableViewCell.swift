//
//  CoinTableViewCell.swift
//  CoinList
//
//  Created by Clement  Wekesa on 5/1/25.
//

import UIKit

class CoinTableViewCell: UITableViewCell {
  
  static let reuseID = "CoinCell"
  
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
    contentView.addSubview(iconView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(priceLabel)
    contentView.addSubview(changeLabel)
    setupConstraints()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  private func setupConstraints() {
    [iconView, nameLabel, priceLabel, changeLabel].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    NSLayoutConstraint.activate([
      // icon
      iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 40),
      iconView.heightAnchor.constraint(equalToConstant: 40),
      
      // name
      nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
      nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      
      // price
      priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
      priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
      
      // change
      changeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      changeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      changeLabel.widthAnchor.constraint(equalToConstant: 80)
    ])
  }
  
  func configure(with vm: CoinCellViewModel) {
    nameLabel.text   = vm.name
    priceLabel.text  = vm.priceText
    changeLabel.text = vm.changeText
    changeLabel.textColor = vm.changeValue >= 0 ? .systemGreen : .systemRed
    
    // simple async image load
    URLSession.shared.dataTask(with: vm.iconURL) { data, _, _ in
      guard let d = data, let img = UIImage(data: d) else { return }
      DispatchQueue.main.async { self.iconView.image = img }
    }.resume()
  }
}
