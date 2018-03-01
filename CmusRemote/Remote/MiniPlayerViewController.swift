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
  private var _playButton: PlayButton!

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

    _fastRewindButton = addButton(image: #imageLiteral(resourceName: "ic_fast_rewind_36pt"))
    _fastForwardButton = addButton(image: #imageLiteral(resourceName: "ic_fast_forward_36pt"))

    _playButton = PlayButton()
    setupButton(_playButton)

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
    _playButton.playing = (status.status == .playing)
  }

  // MARK: - Events

  @objc private func onTapTrackName(gesture: UITapGestureRecognizer) {
    if gesture.state == .ended {
      delegate?.miniPlayerDidTapTrackName(self)
    }
  }

  @objc private func onPlay(button: PlayButton) {
    if button.playing {
      _ = _session?.pause()
    } else {
      _ = _session?.play()
    }
  }

  @objc private func onPrevious(button: UIButton) {
    _ = _session?.previous()
  }

  @objc private func onNext(button: UIButton) {
    _ = _session?.next()
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
    button.sizeToFit()
    button.contentEdgeInsets = kButtonContentInsets
    button.setContentCompressionResistancePriority(
      .defaultLow, for: .horizontal)
    button.setContentHuggingPriority(.required, for: .horizontal)
    view.addSubview(button)
    button.heightAnchor.constraint(equalToConstant: kIntrinsicHeight)
      .isActive = true
    button.widthAnchor.constraint(equalToConstant: kButtonWidth).isActive = true
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
    _fastRewindButton.addTarget(self, action: #selector(onPrevious(button:)),
                                for: .touchUpInside)
    _fastForwardButton.addTarget(self, action: #selector(onNext(button:)),
                                 for: .touchUpInside)
    _playButton.addTarget(self, action: #selector(onPlay(button:)),
                          for: .touchUpInside)

    _titleTapDetectionView.isUserInteractionEnabled = true
    let titleLabelTapRecognizer = UITapGestureRecognizer(
        target: self, action: #selector(onTapTrackName(gesture:)))
    titleLabelTapRecognizer.numberOfTapsRequired = 1
    titleLabelTapRecognizer.numberOfTouchesRequired = 1
    _titleTapDetectionView.addGestureRecognizer(titleLabelTapRecognizer)
  }
}

private class PlayButton : MDCFlatButton {
  private var _playing = false

  override init(frame: CGRect) {
    super.init(frame: frame)
    updateButtonState()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    updateButtonState()
  }

  var playing: Bool {
    get {
      return _playing
    }
    set (val) {
      if val == _playing {
        return
      }
      _playing = val
      updateButtonState()
    }
  }

  private func updateButtonState() {
    let image = _playing ? #imageLiteral(resourceName: "ic_pause_36pt") : #imageLiteral(resourceName: "ic_play_arrow_36pt")
    self.setImage(image, for: .normal)
  }
}
