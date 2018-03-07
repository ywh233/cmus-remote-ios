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
  var viewController: UIViewController {
    get { return _playerViewController }
  }

  let _playerViewController = PlayerViewController()

  // MARK: - RemoteViewTab

  func onTabSelected() {

  }

  func registerSession(_ session: CmusRemoteSession) {
    _playerViewController.registerSession(session)
  }
}
