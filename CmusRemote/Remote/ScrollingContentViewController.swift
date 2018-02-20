//
//  ScrollingContentViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/24/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

class ScrollingContentViewController:
UIViewController, SessionRegistrar, MiniPlayerViewControllerDelegate {

  var scrollingContents: [RemoteViewTab]! {
    get {
      if _scrollingContents == nil {
        _scrollingContents = [
          FakeVC(title: "Player", showsMiniPlayer: false),
          FakeVC(title: "Info", showsMiniPlayer: true),
          FakeVC(title: "Lyrics", showsMiniPlayer: true),
          FilesCollectionViewController(),
          FakeVC(title: "Settings", showsMiniPlayer: true),
        ]
      }
      return _scrollingContents
    }
  }

  private var _scrollingContents: [RemoteViewTab]?
  private var _currentContentIndex = 0

  // MARK: SessionRegistrar

  func registerSession(_ session: CmusRemoteSession) {
    for content in scrollingContents {
      if let sessionRegistrar = content.viewController as? SessionRegistrar {
        sessionRegistrar.registerSession(session)
      }
    }
  }

  // MARK: - MiniPlayerViewControllerDelegate

  func miniPlayerDidTapTrackName(_ player: MiniPlayerViewController) {
    let currentContent = scrollingContents[_currentContentIndex]
    if let currentContentDelegate = currentContent
        as? MiniPlayerViewControllerDelegate {
      currentContentDelegate.miniPlayerDidTapTrackName(player)
    }
  }

  // MARK: - Public
  var scrollView: UIScrollView {
    get {
      return view as! UIScrollView
    }
  }

  var currentContentIndex: Int {
    get {
      return _currentContentIndex
    }
    set(val) {
      if val < 0 || val >= scrollingContents.count {
        return
      }
      _currentContentIndex = val

      scrollingContents[_currentContentIndex].onTabSelected()

      let offset = CGPoint(
          x: CGFloat(_currentContentIndex) * scrollView.bounds.width, y: 0)
      scrollView.setContentOffset(offset, animated: true)
    }
  }

  var showsMiniPlayer: Bool {
    get {
      return scrollingContents[currentContentIndex].showsMiniPlayer
    }
  }

  // MARK: UIViewController
  override func loadView() {
    view = UIScrollView(frame: .zero)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    scrollView.isPagingEnabled = true
    scrollView.isScrollEnabled = false


    let contentGuide = scrollView.contentLayoutGuide
    var lastTrailingAnchor = contentGuide.leadingAnchor
    for scrollingContent in scrollingContents {
      let contentView = scrollingContent.viewController.view!
      contentView.translatesAutoresizingMaskIntoConstraints = false

      addChildViewController(scrollingContent.viewController)
      scrollView.addSubview(contentView)

      NSLayoutConstraint.activate([
        contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
        contentView.bottomAnchor.constraint(
            equalTo: contentGuide.bottomAnchor),
        contentView.leadingAnchor.constraint(equalTo: lastTrailingAnchor),

        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
      ])
      lastTrailingAnchor = contentView.trailingAnchor

      scrollingContent.viewController.didMove(toParentViewController: self)
    }
    scrollingContents.last!.viewController.view.trailingAnchor
        .constraint(equalTo: contentGuide.trailingAnchor).isActive = true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

class FakeVC: UIViewController, RemoteViewTab {
  var viewController: UIViewController {
    get { return self }
  }
  let tabTitle: String
  let showsMiniPlayer: Bool

  init(title: String, showsMiniPlayer: Bool) {
    self.tabTitle = title
    self.showsMiniPlayer = showsMiniPlayer
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func onTabSelected() {
    print("Tab " + tabTitle + " selected.")
  }

  func registerSession(_ session: CmusRemoteSession) {
    // Do nothing.
  }
}
