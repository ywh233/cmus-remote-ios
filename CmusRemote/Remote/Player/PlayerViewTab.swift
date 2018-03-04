//
//  PlayerViewTab.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/3/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

class PlayerViewTab: NSObject, RemoteViewTab {
  let tabTitle: String = "Player"
  let showsMiniPlayer: Bool = false
  let showsHeaderShadow: Bool = false
  let viewController: UIViewController

  override init() {
    viewController = UIViewController()
  }

  // MARK: - RemoteViewTab

  func onTabSelected() {

  }

  func registerSession(_ session: CmusRemoteSession) {

  }
}
