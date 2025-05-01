//
//  Button.swift
//  CoinList
//
//  Created by Clement  Wekesa on 4/30/25.
//

import UIKit

class Button: UIButton {

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(backgroundColor: UIColor, title: String) {
    super.init(frame: .zero)

    self.backgroundColor = backgroundColor
    self.setTitle(title, for: .normal)
  }

  private func setup() {
    layer.cornerRadius = 8
    titleLabel?.textColor = .white
    titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)

    translatesAutoresizingMaskIntoConstraints = false
  }
}
