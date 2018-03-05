//
//  ViewUtils.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/3/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

func setupHorizontalConstraints<ViewType: UIView>(views: [ViewType],
                                                  with guide: UILayoutGuide) {
  let configs = views.map {
    FlowItemConfig(item: $0, paddingBefore: 0, paddingAfter: 0)
  }
  setupHorizontalConstraints(configs: configs, with: guide)
}

struct FlowItemConfig {
  var item: UIView
  var paddingBefore: CGFloat
  var paddingAfter: CGFloat

  init(item: UIView) {
    self.init(item: item, paddingBefore: 0, paddingAfter: 0)
  }

  init(item: UIView, paddingBefore: CGFloat, paddingAfter: CGFloat) {
    self.item = item
    self.paddingBefore = paddingBefore
    self.paddingAfter = paddingAfter
  }
}

func setupHorizontalConstraints(configs: [FlowItemConfig],
                                with guide: UILayoutGuide) {
  var previousTrailing = guide.leadingAnchor
  for i in 0...(configs.count - 1) {
    let config = configs[i]
    let view = config.item
    var totalPaddingBefore = config.paddingBefore
    if i > 0 {
      totalPaddingBefore += configs[i - 1].paddingAfter
    }
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: guide.topAnchor),
      view.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
      view.leadingAnchor.constraint(equalTo: previousTrailing,
                                    constant: totalPaddingBefore),
      ])
    if i == (configs.count - 1) {
      view.trailingAnchor.constraint(equalTo: guide.trailingAnchor,
                                     constant: -config.paddingAfter)
        .isActive = true
    }
    previousTrailing = view.trailingAnchor
  }
}

func forceIntrinsicSize(_ view: UIView, for axis: UILayoutConstraintAxis) {
  view.setContentCompressionResistancePriority(.defaultLow, for: axis)
  view.setContentHuggingPriority(.required, for: axis)
}
