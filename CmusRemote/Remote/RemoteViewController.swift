//
//  RemoteViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/19/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import MaterialComponents.MDCTabBar
import PromiseKit.PMKUIKit
import UIKit

class RemoteViewController: UIViewController, MDCTabBarDelegate {
  private var _session: CmusRemoteSession!
  private var _errorHandlerBinding: EventBindingHolder!
  private var _scrollingContentVC: ScrollingContentViewController!

  private var _tabBarShadowView: UIView!
  private var _miniPlayer: MiniPlayerViewController!

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
    _tabBarShadowView = UIView()
    _tabBarShadowView.backgroundColor = Theme.controlBackgroundColor
    _tabBarShadowView.translatesAutoresizingMaskIntoConstraints = false
    Theme.addFlatShadow(toLayer: _tabBarShadowView.layer)
    view.insertSubview(_tabBarShadowView, belowSubview: tabBar)
    NSLayoutConstraint.activate([
      _tabBarShadowView.topAnchor.constraint(equalTo: view.topAnchor),
      _tabBarShadowView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
      _tabBarShadowView.trailingAnchor.constraint(
          equalTo: tabBar.trailingAnchor),
      _tabBarShadowView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor),
      ])

    _miniPlayer = MiniPlayerViewController()
    _miniPlayer.delegate = _scrollingContentVC
    addChildViewController(_miniPlayer)
    self.view.addSubview(_miniPlayer.view)
    NSLayoutConstraint.activate([
      _miniPlayer.view.leadingAnchor.constraint(
        equalTo: view.leadingAnchor),
      _miniPlayer.view.trailingAnchor.constraint(
        equalTo: view.trailingAnchor),

      _miniPlayer.view.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
    ])
    let playerBottomConstraint =
        _miniPlayer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    playerBottomConstraint.priority = .defaultLow
    playerBottomConstraint.isActive = true
    _miniPlayer.didMove(toParentViewController: self)
    _miniPlayer.registerSession(_session)

    updateViewState(animated: false)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  // MARK: - MDCTabBarDelegate
  func tabBar(_ tabBar: MDCTabBar, didSelect item: UITabBarItem) {
    _scrollingContentVC.currentContentIndex = item.tag
    updateViewState(animated: true)
  }

  // MARK: - Private

  private func updateViewState(animated: Bool) {
    setTabBarShadowVisible(!_scrollingContentVC.hasExtraHeader,
                           animated: animated)
    setMiniPlayerVisible(_scrollingContentVC.showsMiniPlayer,
                         animated: animated)
  }

  private func setTabBarShadowVisible(_ visible: Bool, animated: Bool) {
    _tabBarShadowView.isHidden = !visible

    if animated {
      UIView.animate(withDuration: Theme.shortAnimationDurationSec,
                     animations: view.layoutIfNeeded)
    } else {
      view.layoutIfNeeded()
    }
  }

  private func setMiniPlayerVisible(_ visible: Bool, animated: Bool) {
    _miniPlayer.view.isHidden = false

    if visible {
      _hidePlayerConstraint?.isActive = false
      _hidePlayerConstraint = nil
    } else if _hidePlayerConstraint == nil {
      _hidePlayerConstraint =
          _miniPlayer.view.topAnchor.constraint(equalTo: view.bottomAnchor)
      _hidePlayerConstraint?.isActive = true
    }

    let promise = animated ?
        UIView.animate(.promise, duration: Theme.shortAnimationDurationSec,
                       animations: view.layoutIfNeeded).asVoid()
        : Promise().done(view.layoutIfNeeded)

    _ = promise.done {
      self._miniPlayer.view.isHidden = !visible
    }
  }
}
