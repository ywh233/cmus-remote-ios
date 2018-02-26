//
//  NavigationContainerViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/25/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialNavigationBar

private let kHeaderViewHeight: CGFloat = 64

class NavigationBarContainerViewController: UIViewController {
  private var _headerContainerView: UIView
  private var _navBar: MDCNavigationBar
  private var _childViewController: UIViewController?
  private var _headerView: UIView?

  var headerView: UIView? {
    get {
      return _headerView
    }

    set (val) {
      if _headerView == val {
        return
      }
      let viewToRemove = _headerView == nil ? _navBar : _headerView!
      _headerView = val

      var viewToAdd: UIView!
      if _headerView == nil {
        _navBar.alpha = 0
        addNavBarToContainerView()
        viewToAdd = _navBar
      } else {
        _headerView!.alpha = 0
        _headerContainerView.addSubview(_headerView!)
        _headerView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          _headerView!.topAnchor.constraint(
              equalTo: _headerContainerView.topAnchor),
          _headerView!.bottomAnchor.constraint(
            equalTo: _headerContainerView.bottomAnchor),
          _headerView!.leadingAnchor.constraint(
            equalTo: _headerContainerView.leadingAnchor),
          _headerView!.trailingAnchor.constraint(
            equalTo: _headerContainerView.trailingAnchor)
        ])
        viewToAdd = _headerView
      }
      UIView.animate(.promise, duration: Theme.shortAnimationDurationSec) {
        viewToRemove.alpha = 0
        viewToAdd.alpha = 1
      }.asVoid().done(viewToRemove.removeFromSuperview)
    }
  }

  init() {
    _headerContainerView = UIView()
    _navBar = MDCNavigationBar()

    super.init(nibName: nil, bundle: nil)

    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    _headerContainerView.translatesAutoresizingMaskIntoConstraints = false
    _headerContainerView.backgroundColor = Theme.controlBackgroundColor
    Theme.addFlatShadow(toLayer: _headerContainerView.layer)
    view.addSubview(_headerContainerView)
    NSLayoutConstraint.activate([
      _headerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
      _headerContainerView.leadingAnchor.constraint(
        equalTo: view.leadingAnchor),
      _headerContainerView.trailingAnchor.constraint(
        equalTo: view.trailingAnchor),
      _headerContainerView.heightAnchor.constraint(
        equalToConstant: kHeaderViewHeight)
      ])

    let backIcon =
      MDCIcons.imageFor_ic_arrow_back()?.withRenderingMode(.alwaysTemplate)
    navigationItem.backBarButtonItem =
      UIBarButtonItem(image: backIcon, style: .plain, target: nil,
                      action: nil)
    _navBar.observe(navigationItem)
    _navBar.backgroundColor = Theme.controlBackgroundColor
    _navBar.tintColor = Theme.controlProminentColor
    _navBar.titleView?.tintColor = Theme.controlMainColor
    _navBar.translatesAutoresizingMaskIntoConstraints = false
    addNavBarToContainerView()
  }

  var childViewController: UIViewController? {
    get { return _childViewController }

    set (val) {
      if val == _childViewController {
        return
      }
      if _childViewController != nil {
        _childViewController!.view.removeFromSuperview()
        _childViewController!.removeFromParentViewController()
      }
      _childViewController = val
      if _childViewController == nil {
        return
      }
      addChildViewController(_childViewController!)
      view.insertSubview(_childViewController!.view, belowSubview: _headerContainerView)
      title = _childViewController!.title
      navigationItem.leftBarButtonItem =
        _childViewController!.navigationItem.leftBarButtonItem
      navigationItem.rightBarButtonItem =
        _childViewController!.navigationItem.rightBarButtonItem
      setupConstraintsForChildView()
      _childViewController!.didMove(toParentViewController: self)
    }

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupConstraintsForChildView() {
    if _childViewController == nil {
      return
    }
    _childViewController!.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      _childViewController!.view.topAnchor.constraint(
          equalTo: _headerContainerView.bottomAnchor),
      _childViewController!.view.bottomAnchor.constraint(
          equalTo: view.bottomAnchor),
      _childViewController!.view.leadingAnchor.constraint(
        equalTo: view.leadingAnchor),
      _childViewController!.view.trailingAnchor.constraint(
        equalTo: view.trailingAnchor),
    ])
  }

  private func addNavBarToContainerView() {
    _headerContainerView.addSubview(_navBar)
    NSLayoutConstraint.activate([
      _navBar.bottomAnchor.constraint(
          equalTo: _headerContainerView.bottomAnchor),
      _navBar.leftAnchor.constraint(
          equalTo: _headerContainerView.leftAnchor),
      _navBar.rightAnchor.constraint(
          equalTo: _headerContainerView.rightAnchor),
      ])
  }
}
