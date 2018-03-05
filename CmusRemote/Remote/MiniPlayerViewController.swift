//
//  MiniPlayerViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/22/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit
import MaterialComponents.MDCButton
import MaterialComponents.MDCTypography

private let kIntrinsicHeight: CGFloat = 60
private let kButtonWidth: CGFloat = 60
private let kXInset: CGFloat = 10
private let kButtonContentInsets = UIEdgeInsetsMake(8, 12, 8, 12)

protocol MiniPlayerViewControllerDelegate : class {
  func miniPlayerDidTapTrackName(_ player: MiniPlayerViewController);
}

class MiniPlayerViewController: UIViewController, SessionRegistrar {
  weak var delegate: MiniPlayerViewControllerDelegate?

  private var _titleLabel: UILabel!
  private var _titleTapDetectionView: UIView!
  private var _fastRewindButton: MDCFlatButton!
  private var _fastForwardButton: MDCFlatButton!
  private var _playButton: MDCFlatButton!

  private var _playButtonController: PlayButtonController!
  private var _fastRewindButtonController: ProgressButtonController!
  private var _fastForwardButtonController: ProgressButtonController!

  private var _statusListenerHolder: EventBindingHolder?

  private weak var _session: CmusRemoteSession?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Theme.controlBackgroundColor
    Theme.addFlatShadow(toLayer: view.layer)
    view.translatesAutoresizingMaskIntoConstraints = false

    _titleTapDetectionView = UIView()
    _titleTapDetectionView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_titleTapDetectionView)

    _titleLabel = UILabel()
    _titleLabel.font = MDCTypography.subheadFont()
    _titleLabel.translatesAutoresizingMaskIntoConstraints = false
    _titleTapDetectionView.addSubview(_titleLabel)

    _fastRewindButton = addButton(image: #imageLiteral(resourceName: "ic_fast_rewind_48pt"))
    _fastForwardButton = addButton(image: #imageLiteral(resourceName: "ic_fast_forward_48pt"))

    _fastRewindButtonController =
      ProgressButtonController(button: _fastRewindButton, direction: .rewind,
                               session: _session!)

    _fastForwardButtonController =
      ProgressButtonController(button: _fastForwardButton, direction: .forward,
                               session: _session!)

    _playButton = MDCFlatButton()
    setupButton(_playButton)
    _playButtonController = PlayButtonController(button: _playButton,
                                                 session: _session!)

    layoutViews()
    setupEvents()
  }

  // MARK: - SessionRegistrar

  func registerSession(_ weakSession: CmusRemoteSession) {
    _statusListenerHolder = weakSession.statusEventTarget.addListener {
      [weak self] (status) in
      self?.updateStatus(status)
    }
    _session = weakSession
  }

  // MARK: - Public

  func updateStatus(_ status: CmusStatus) {
    _titleLabel.text = status.titleOrBasename
    _playButtonController.playing = (status.status == .playing)
  }

  // MARK: - Events

  @objc private func onTapTrackName(gesture: UITapGestureRecognizer) {
    if gesture.state == .ended {
      delegate?.miniPlayerDidTapTrackName(self)
    }
  }

  // MARK: - Private

  private func addButton(image: UIImage) -> MDCFlatButton {
    let button = MDCFlatButton()
    button.setImage(image, for: .normal)
    setupButton(button)
    return button
  }

  private func setupButton(_ button: UIButton) {
    button.translatesAutoresizingMaskIntoConstraints = false
    button.contentEdgeInsets = kButtonContentInsets
    button.imageView?.contentMode = .scaleAspectFit
    forceIntrinsicSize(button, for: .horizontal)
    view.addSubview(button)

    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalToConstant: kIntrinsicHeight),
      button.widthAnchor.constraint(equalToConstant: kButtonWidth),
    ])
  }

  private func layoutViews() {
    let safeAreaGuide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      view.heightAnchor.constraint(equalToConstant: kIntrinsicHeight),

      _playButton.centerYAnchor.constraint(
        equalTo: safeAreaGuide.centerYAnchor),
      _playButton.leadingAnchor.constraint(
        equalTo: safeAreaGuide.leadingAnchor),

      _titleTapDetectionView.topAnchor.constraint(equalTo: view.topAnchor),
      _titleTapDetectionView.bottomAnchor.constraint(
        equalTo: view.bottomAnchor),
      _titleTapDetectionView.leadingAnchor.constraint(
        equalTo: _playButton.trailingAnchor),

      _titleLabel.centerYAnchor.constraint(
        equalTo: _titleTapDetectionView.centerYAnchor),
      _titleLabel.leadingAnchor.constraint(
        equalTo: _titleTapDetectionView.leadingAnchor,
        constant: kXInset),
      _titleLabel.trailingAnchor.constraint(
        equalTo: _titleTapDetectionView.trailingAnchor,
        constant: -kXInset),

      _fastRewindButton.centerYAnchor.constraint(
        equalTo: safeAreaGuide.centerYAnchor),
      _fastRewindButton.leadingAnchor.constraint(
        equalTo: _titleTapDetectionView.trailingAnchor),

      _fastForwardButton.centerYAnchor.constraint(
        equalTo: safeAreaGuide.centerYAnchor),
      _fastForwardButton.leadingAnchor.constraint(
        equalTo: _fastRewindButton.trailingAnchor),
      _fastForwardButton.trailingAnchor.constraint(
        equalTo: safeAreaGuide.trailingAnchor),
      ])
  }

  private func setupEvents() {
    _titleTapDetectionView.isUserInteractionEnabled = true
    let titleLabelTapRecognizer = UITapGestureRecognizer(
        target: self, action: #selector(onTapTrackName(gesture:)))
    titleLabelTapRecognizer.numberOfTapsRequired = 1
    titleLabelTapRecognizer.numberOfTouchesRequired = 1
    _titleTapDetectionView.addGestureRecognizer(titleLabelTapRecognizer)
  }
}
