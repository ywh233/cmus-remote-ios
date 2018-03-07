//
//  PlayerViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/3/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit
import MaterialComponents.MDCButton
import MaterialComponents.MDCSlider
import MaterialComponents.MDCTypography

private let kContentInset: CGFloat = 24
private let kProgressLabelInset: CGFloat = 8
private let kButtonTopPadding: CGFloat = 16
private let kButtonSize: CGSize = CGSize(width: 90, height: 60)
private let kVolumeTopPadding: CGFloat = 16
private let kVolumeSliderInset: CGFloat = 8

class PlayerViewController: UIViewController, SessionRegistrar {
  private var _trackImageView: TrackImageView!
  private var _progressSlider: MDCSlider!
  private var _positiveProgressLabel: UILabel!
  private var _negativeProgressLabel: UILabel!
  private var _titleLabel: UILabel!
  private var _artistLabel: UILabel!
  private var _previousButton: MDCFlatButton!
  private var _playButton: MDCFlatButton!
  private var _nextButton: MDCFlatButton!
  private var _volumeSlider: MDCSlider!

  private var _playButtonController: PlayButtonController!
  private var _previousButtonController: ProgressButtonController!
  private var _nextButtonController: ProgressButtonController!

  // Used to throttle calls to get log volume.
  private var _currentRawVolume = -1 as Double

  private weak var _session: CmusRemoteSession!
  private var _statusHolder: EventBindingHolder?
  private var _isStatusUpdateEnabled = true

  override func viewDidLoad() {
    super.viewDidLoad()

    _trackImageView = TrackImageView()
    _trackImageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_trackImageView)

    _progressSlider = MDCSlider()
    _progressSlider.translatesAutoresizingMaskIntoConstraints = false
    _progressSlider.color = Theme.controlProminentColor
    _progressSlider.isThumbHollowAtStart = false
    _progressSlider.minimumValue = 0
    view.addSubview(_progressSlider)
    addDisableStatusUpdateListeners(control: _progressSlider)
    // Note that listening to .valueChanged will flood the pipe and crash the
    // server.
    addTouchUpTarget(self, action: #selector(onProgressChanged),
                     for: _progressSlider)

    _positiveProgressLabel = createProgressLabel()
    _negativeProgressLabel = createProgressLabel()

    _titleLabel = UILabel()
    _titleLabel.font = MDCTypography.headlineFont()
    _titleLabel.textColor = Theme.controlMainColor
    _titleLabel.textAlignment = .center
    _titleLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_titleLabel)

    _artistLabel = UILabel()
    _artistLabel.font = MDCTypography.titleFont()
    _artistLabel.textColor = Theme.controlProminentColor
    _artistLabel.textAlignment = .center
    _artistLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_artistLabel)

    _previousButton = createButton()
    _previousButton.setImage(#imageLiteral(resourceName: "ic_fast_rewind_48pt"), for: .normal)
    _previousButtonController =
        ProgressButtonController(button: _previousButton, direction: .rewind,
                                 session: _session!)

    _playButton = createButton()
    _playButtonController = PlayButtonController(button: _playButton,
                                                 session: _session!)

    _nextButton = createButton()
    _nextButton.setImage(#imageLiteral(resourceName: "ic_fast_forward_48pt"), for: .normal)
    _nextButtonController =
      ProgressButtonController(button: _nextButton, direction: .forward,
                               session: _session!)

    let volumeMuteView = createVolumeView(image: #imageLiteral(resourceName: "ic_volume_mute_18pt"))
    let volumeUpView = createVolumeView(image: #imageLiteral(resourceName: "ic_volume_up_18pt"))

    _volumeSlider = MDCSlider()
    _volumeSlider.minimumValue = 0
    _volumeSlider.maximumValue = CGFloat(CmusStatus.maxVolume)
    _volumeSlider.color = Theme.controlSecondaryColor
    _volumeSlider.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_volumeSlider)
    addDisableStatusUpdateListeners(control: _volumeSlider)
    addTouchUpTarget(self, action: #selector(onVolumeChanged),
                     for: _volumeSlider)

    setupConstraints(volumeMuteView: volumeMuteView, volumeUpView: volumeUpView)
  }

  // MARK: - SessionRegistrar

  func registerSession(_ session: CmusRemoteSession) {
    _session = session
    _statusHolder = _session.statusEventTarget.addListener(onStatus(_:))
  }

  // MARK: - Events

  @objc private func onTouchDown(control: UIControl) {
    _isStatusUpdateEnabled = false
  }

  @objc private func onTouchUp(control: UIControl) {
    _isStatusUpdateEnabled = true
  }

  @objc private func onTouchCancelled(control: UIControl) {
    _isStatusUpdateEnabled = true
  }

  @objc private func onProgressChanged() {
    _ = _session
        .seek(command: String(format: "%d", UInt(_progressSlider.value)))
  }

  @objc private func onVolumeChanged() {
    let rawVol = logVolumeToRaw(Double(_volumeSlider.value))
    _ = _session
        .setVolume(command: String(format: "%d%", UInt(rawVol)))
  }

  // MARK: - Private

  private func onStatus(_ status: CmusStatus) {
    if !_isStatusUpdateEnabled {
      return
    }
    _progressSlider.maximumValue = CGFloat(status.duration)
    _progressSlider.value = CGFloat(status.position)
    _positiveProgressLabel.text = secondsToString(status.position)
    _negativeProgressLabel.text =
        "-" + secondsToString(status.duration - status.position)
    if (status.status == .stopped) {
      _titleLabel.text = "Not playing"
      _artistLabel.text = ""
    } else {
      _titleLabel.text = status.titleOrBasename
      _artistLabel.text = status.artistOrUnknown
    }
    _playButtonController.playing = (status.status == .playing)
    // TODO: Allow toggling log transformation on settings view.
    let rawVol = Double(status.leftVolume + status.rightVolume) / 2
    if rawVol != _currentRawVolume {
      _volumeSlider.value = CGFloat(rawVolumeToLog(rawVol))
      _currentRawVolume = rawVol
    }
  }

  private func createProgressLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Theme.controlSecondaryColor
    label.font = MDCTypography.captionFont()
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    return label
  }

  private func createButton() -> MDCFlatButton {
    let button = MDCFlatButton()
    button.inkMaxRippleRadius = kButtonSize.height / 2
    button.translatesAutoresizingMaskIntoConstraints = false
    button.imageView?.contentMode = .scaleAspectFit
    view.addSubview(button)
    return button
  }

  private func createVolumeView(image: UIImage) -> UIImageView {
    let volView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
    volView.contentMode = .scaleAspectFit
    volView.tintColor = Theme.controlSecondaryColor
    volView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(volView)
    return volView
  }

  private func addDisableStatusUpdateListeners(control: UIControl) {
    control.addTarget(self, action: #selector(onTouchDown(control:)),
                      for: .touchDown)
    control.addTarget(self, action: #selector(onTouchUp(control:)),
                      for: .touchUpInside)
    control.addTarget(self, action: #selector(onTouchUp(control:)),
                      for: .touchUpOutside)
    control.addTarget(self, action: #selector(onTouchCancelled(control:)),
                      for: .touchCancel)
  }

  private func setupConstraints(volumeMuteView: UIView, volumeUpView: UIView) {
    let safeAreaGuide = view.safeAreaLayoutGuide
    let contentGuide = UILayoutGuide()
    view.addLayoutGuide(contentGuide)
    let progressGuide = UILayoutGuide()
    view.addLayoutGuide(progressGuide)
    let buttonGuide = UILayoutGuide()
    view.addLayoutGuide(buttonGuide)
    let volumeGuide = UILayoutGuide()
    view.addLayoutGuide(volumeGuide)

    let buttons = [_previousButton!, _playButton!, _nextButton!]
    setupHorizontalConstraints(views: buttons, with: buttonGuide)
    buttons.forEach {
      $0.widthAnchor.constraint(equalToConstant: kButtonSize.width)
          .isActive = true
      $0.heightAnchor.constraint(equalToConstant: kButtonSize.height)
        .isActive = true
    }

    forceIntrinsicSize(volumeMuteView, for: .horizontal)
    forceIntrinsicSize(volumeUpView, for: .horizontal)
    setupHorizontalConstraints(
        configs: [
          FlowItemConfig(item: volumeMuteView),
          FlowItemConfig(item: _volumeSlider!,
                         paddingBefore: kVolumeSliderInset,
                         paddingAfter: kVolumeSliderInset),
          FlowItemConfig(item: volumeUpView),
        ],
        with: volumeGuide)

    // More important to make sure everything below the track image is shown
    // compared to centralizing the content.
    let centerYContentConstraint = contentGuide.centerYAnchor.constraint(
        equalTo: safeAreaGuide.centerYAnchor)
    centerYContentConstraint.priority = .defaultHigh
    centerYContentConstraint.isActive = true

    NSLayoutConstraint.activate([
      contentGuide.leadingAnchor.constraint(
        equalTo: safeAreaGuide.leadingAnchor, constant: kContentInset),
      contentGuide.trailingAnchor.constraint(
        equalTo: safeAreaGuide.trailingAnchor, constant: -kContentInset),
      contentGuide.bottomAnchor.constraint(
        lessThanOrEqualTo: safeAreaGuide.bottomAnchor),

      _trackImageView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
      _trackImageView.centerXAnchor.constraint(
        equalTo: contentGuide.centerXAnchor),

      _progressSlider.topAnchor.constraint(
        equalTo: _trackImageView.bottomAnchor),
      _progressSlider.leadingAnchor.constraint(
        equalTo: contentGuide.leadingAnchor),
      _progressSlider.trailingAnchor.constraint(
        equalTo: contentGuide.trailingAnchor),

      progressGuide.topAnchor.constraint(equalTo: _progressSlider.bottomAnchor),
      progressGuide.leadingAnchor.constraint(
        equalTo: contentGuide.leadingAnchor, constant: kProgressLabelInset),
      progressGuide.trailingAnchor.constraint(
        equalTo: contentGuide.trailingAnchor, constant: -kProgressLabelInset),

      _positiveProgressLabel.leadingAnchor.constraint(
        equalTo: progressGuide.leadingAnchor),
      _positiveProgressLabel.topAnchor.constraint(
        equalTo: progressGuide.topAnchor),
      _positiveProgressLabel.bottomAnchor.constraint(
        equalTo: progressGuide.bottomAnchor),

      _negativeProgressLabel.trailingAnchor.constraint(
        equalTo: progressGuide.trailingAnchor),
      _negativeProgressLabel.topAnchor.constraint(
        equalTo: progressGuide.topAnchor),
      _negativeProgressLabel.bottomAnchor.constraint(
        equalTo: progressGuide.bottomAnchor),

      _titleLabel.topAnchor.constraint(equalTo: progressGuide.bottomAnchor),
      _titleLabel.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
      _titleLabel.trailingAnchor.constraint(
        equalTo: contentGuide.trailingAnchor),

      _artistLabel.topAnchor.constraint(equalTo: _titleLabel.bottomAnchor),
      _artistLabel.leadingAnchor.constraint(
        equalTo: contentGuide.leadingAnchor),
      _artistLabel.trailingAnchor.constraint(
        equalTo: contentGuide.trailingAnchor),

      buttonGuide.topAnchor.constraint(equalTo: _artistLabel.bottomAnchor,
                                       constant: kButtonTopPadding),
      buttonGuide.centerXAnchor.constraint(equalTo: contentGuide.centerXAnchor),

      volumeGuide.topAnchor.constraint(equalTo: buttonGuide.bottomAnchor,
                                       constant: kVolumeTopPadding),
      volumeGuide.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
      volumeGuide.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
      volumeGuide.trailingAnchor.constraint(
          equalTo: contentGuide.trailingAnchor),
    ])
  }
}

private func addTouchUpTarget(_ target: Any?,
                              action: Selector,
                              for control: UIControl) {
  control.addTarget(target, action: action, for: .touchUpInside)
  control.addTarget(target, action: action, for: .touchUpOutside)
}
