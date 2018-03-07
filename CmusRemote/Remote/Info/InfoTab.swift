//
//  InfoTab.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/6/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

class InfoTab: NSObject, RemoteViewTab {
  let tabTitle: String = "Info"
  let showsMiniPlayer: Bool = true
  let showsHeaderShadow: Bool = true

  var viewController: UIViewController {
    get { return _infoViewController }
  }

  private let _infoViewController = InfoViewController()

  func onTabSelected() {
  }

  func registerSession(_ session: CmusRemoteSession) {
    _infoViewController.registerSession(session)
  }
}
