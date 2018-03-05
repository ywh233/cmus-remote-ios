//
//  PlayButton.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/3/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

class PlayButtonController {
  private let _button: UIButton
  private var _playing = false
  private weak var _session: CmusRemoteSession?

  init(button: UIButton, session: CmusRemoteSession) {
    _button = button
    updateButtonState()

    _session = session
    _button.addTarget(self, action: #selector(onButtonTapped),
                      for: .touchUpInside)
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
    let image = _playing ? #imageLiteral(resourceName: "ic_pause_48pt") : #imageLiteral(resourceName: "ic_play_arrow_48pt")
    _button.setImage(image, for: .normal)
  }

  // MARK: - Events

  @objc private func onButtonTapped() {
    _ = playing ? _session?.pause() : _session?.play()
  }
}
