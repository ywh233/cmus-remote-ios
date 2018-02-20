//
//  RemoteViewTab.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/25/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

protocol RemoteViewTab: SessionRegistrar {
  var viewController: UIViewController { get }
  var tabTitle: String { get }
  var showsMiniPlayer: Bool { get }

  func onTabSelected()
}
