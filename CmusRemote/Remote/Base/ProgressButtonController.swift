//
//  ProgressButtonController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/4/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import Dispatch
import UIKit

let kProgressControlDelay = DispatchTimeInterval.milliseconds(150)
let kProgressUpdateInterval = DispatchTimeInterval.milliseconds(500)
let kProgressSeekSpeed = 3

class ProgressButtonController {
  enum Direction {
    case forward
    case rewind
  }

  private let _direction: Direction
  private weak var _session: CmusRemoteSession?
  private var _progressUpdateTimer: DispatchSourceTimer?
  private var _isUpdateTimerStarted = false

  init(button: UIButton, direction: Direction, session: CmusRemoteSession) {
    _direction = direction

    button.addTarget(self, action: #selector(onTouchDown), for: .touchDown)
    button.addTarget(self, action: #selector(onTouchUpInside),
                     for: .touchUpInside)
    button.addTarget(self, action: #selector(onTouchUpOutside),
                     for: .touchUpOutside)

    _session = session
  }

  @objc private func onTouchDown() {
    _isUpdateTimerStarted = false
    _progressUpdateTimer = DispatchSource.makeTimerSource()
    _progressUpdateTimer!.setEventHandler { [unowned self] in
      self._isUpdateTimerStarted = true
      let sign = (self._direction == .forward) ? "+" : "-"
      let command = sign + String(kProgressSeekSpeed)
      _ = self._session?.seek(command: command)
    }
    _progressUpdateTimer!.schedule(deadline: .now() + kProgressControlDelay,
                                   repeating: kProgressUpdateInterval)
    _progressUpdateTimer!.resume()
  }

  @objc private func onTouchUpInside() {
    if _progressUpdateTimer != nil {
      _progressUpdateTimer = nil
      if _isUpdateTimerStarted {
        _isUpdateTimerStarted = false
        return
      }
    }

    if _direction == .forward {
      _ = _session?.next()
    } else if _direction == .rewind {
      _ = _session?.previous()
    } else {
      assert(false)
    }
  }

  @objc private func onTouchUpOutside() {
    _isUpdateTimerStarted = false
    _progressUpdateTimer = nil
  }
}
