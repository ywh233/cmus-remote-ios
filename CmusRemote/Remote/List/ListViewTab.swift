//
//  ListViewTab.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/25/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

class ListViewTab: NSObject, RemoteViewTab, MiniPlayerViewControllerDelegate {

  // MARK: - RemoteViewTab

  let tabTitle: String = "List"
  let showsMiniPlayer: Bool = true
  let showsHeaderShadow: Bool = false
  var viewController: UIViewController {
    get { return _navController }
  }

  private let _navController: UINavigationController
  private let _libraryVC: LibraryCollectionViewController

  override init() {
    let navBarController = NavigationBarContainerViewController()
    _libraryVC = LibraryCollectionViewController()
    navBarController.childViewController = _libraryVC
    _navController =
        UINavigationController(rootViewController: navBarController)
    _navController.isNavigationBarHidden = true
  }

  func onTabSelected() {
    _libraryVC.refreshContent()
  }

  func registerSession(_ session: CmusRemoteSession) {
    _libraryVC.registerSession(session)
  }

  // MARK: - MiniPlayerViewControllerDelegate

  func miniPlayerDidTapTrackName(_ player: MiniPlayerViewController) {
    _libraryVC.miniPlayerDidTapTrackName(player)
  }
}
