//
//  Theme.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/19/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

class Theme {
  static let controlBackgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
  static let controlProminentColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
  static let controlMainColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
  static let controlSecondaryColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)

  static let shortAnimationDurationSec = 0.2

  static let flatShadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
  static let flatShadowRadius: CGFloat = 16
  static let flatShadowOpacity: Float = 0.08

  static func addFlatShadow(toLayer layer: CALayer) {
    layer.shadowColor = flatShadowColor
    layer.shadowRadius = flatShadowRadius
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowOpacity = flatShadowOpacity
  }
}
