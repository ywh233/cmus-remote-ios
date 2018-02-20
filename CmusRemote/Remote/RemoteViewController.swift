//
//  RemoteViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/19/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import MaterialComponents.MDCTabBar
import UIKit

class RemoteViewController: UIViewController, MDCTabBarDelegate {
  private var _session: CmusRemoteSession!
  private var _errorHandlerBinding: EventBindingHolder!
  private var _scrollingContentVC: ScrollingContentViewController!

  private var _miniPlayer: MiniPlayerViewController?

  private var _hidePlayerConstraint: NSLayoutConstraint?

  // MARK: - Public

  func setSession(session: CmusRemoteSession) {
    _session = session
    _errorHandlerBinding = _session.statusEventTarget.addErrorHandler {
      [weak self] error in
      self?._session = nil
      self?.navigationController?.popToRootViewController(animated: true)
      handleSessionError(error)
    }
  }

  // MARK: - ViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = Theme.controlBackgroundColor

    let layoutGuide = view.safeAreaLayoutGuide

    _scrollingContentVC = ScrollingContentViewController()
    _scrollingContentVC.registerSession(_session)
    addChildViewController(_scrollingContentVC)
    let scrollView = _scrollingContentVC.scrollView
    self.view.addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(
          equalTo: layoutGuide.trailingAnchor),
    ])
    _scrollingContentVC.didMove(toParentViewController: self)

    let tabBar = MDCTabBar(frame: view.frame)
    tabBar.items = _scrollingContentVC.scrollingContents.enumerated().map {
        (index, element) in
      UITabBarItem(title: element.tabTitle, image: nil, tag: index)
    }
    tabBar.delegate = self

    tabBar.itemAppearance = .titles
    tabBar.tintColor = Theme.controlProminentColor
    tabBar.selectedItemTintColor = Theme.controlProminentColor
    tabBar.unselectedItemTintColor = Theme.controlSecondaryColor
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    tabBar.alignment = .center
    view.addSubview(tabBar)
    NSLayoutConstraint.activate([
      tabBar.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      tabBar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),

      tabBar.bottomAnchor.constraint(equalTo: scrollView.topAnchor),
      ])

    // Tab bar doesn't cover the status bar.
    let tabBarShadowView = UIView()
    tabBarShadowView.backgroundColor = Theme.controlBackgroundColor
    tabBarShadowView.translatesAutoresizingMaskIntoConstraints = false
    Theme.addFlatShadow(toLayer: tabBarShadowView.layer)
    view.insertSubview(tabBarShadowView, belowSubview: tabBar)
    NSLayoutConstraint.activate([
      tabBarShadowView.topAnchor.constraint(equalTo: view.topAnchor),
      tabBarShadowView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
      tabBarShadowView.trailingAnchor.constraint(
          equalTo: tabBar.trailingAnchor),
      tabBarShadowView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor),
      ])

    _miniPlayer = MiniPlayerViewController()
    _miniPlayer?.delegate = _scrollingContentVC
    addChildViewController(_miniPlayer!)
    self.view.addSubview(_miniPlayer!.view)
    NSLayoutConstraint.activate([
      _miniPlayer!.view.leadingAnchor.constraint(
        equalTo: view.leadingAnchor),
      _miniPlayer!.view.trailingAnchor.constraint(
        equalTo: view.trailingAnchor),

      _miniPlayer!.view.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
    ])
    let playerBottomConstraint =
        _miniPlayer!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    playerBottomConstraint.priority = .defaultLow
    playerBottomConstraint.isActive = true
    _miniPlayer!.didMove(toParentViewController: self)
    _miniPlayer!.registerSession(_session)

    setMiniPlayerVisible(_scrollingContentVC.showsMiniPlayer, animated: false)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  // MARK: - MDCTabBarDelegate
  func tabBar(_ tabBar: MDCTabBar, didSelect item: UITabBarItem) {
    _scrollingContentVC.currentContentIndex = item.tag
    setMiniPlayerVisible(_scrollingContentVC.showsMiniPlayer, animated: true)
  }

  // MARK: - Private

  private func setMiniPlayerVisible(_ visible: Bool, animated: Bool) {
    _miniPlayer?.view.isHidden = false

    if visible {
      _hidePlayerConstraint?.isActive = false
      _hidePlayerConstraint = nil
    } else if _hidePlayerConstraint == nil {
      _hidePlayerConstraint =
          _miniPlayer?.view.topAnchor.constraint(equalTo: view.bottomAnchor)
      _hidePlayerConstraint?.isActive = true
    }

    if animated {
      UIView.animate(withDuration: Theme.miniPlayerAnimationIntervalSec,
                     animations: {
        self.view.layoutIfNeeded()
      }, completion: { _ in
        self._miniPlayer?.view.isHidden = !visible
      })
    } else {
      view.layoutIfNeeded()
      _miniPlayer?.view.isHidden = !visible
    }
  }
}
