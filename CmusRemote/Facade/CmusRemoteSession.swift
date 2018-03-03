//
//  CmusRemoteSession.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/20/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import PromiseKit
import UIKit

private let kStatusPollingInterval = DispatchTimeInterval.milliseconds(500)

class CmusRemoteSession {
  private(set) var statusEventTarget = EventTarget<CmusStatus>()

  private let _core = CmusRemoteSessionCore()
  private let _sessionQueue = DispatchQueue(label: "RemoteSessionQueue")

  private var _statusPollingTimer: DispatchSourceTimer?

  func connect(host: String,
               port: String,
               password: String) -> Promise<Void> {
    return runOnSessionQueue {
        try self._core.connect(toHost: host, port: port, password: password)
      }.done {
        self.startPollingTimer()
    }
  }

  // MARK: - Controls

  func play() -> Promise<Void> {
    return runOnSessionQueue {
      try self._core.play();
    }
  }

  func pause() -> Promise<Void> {
    return runOnSessionQueue {
      try self._core.pause()
    }
  }

  func next() -> Promise<Void> {
    return runOnSessionQueue {
      try self._core.next()
    }
  }

  func previous() -> Promise<Void> {
    return runOnSessionQueue {
      try self._core.previous()
    }
  }

  func getList(view: CmusListSource) -> Promise<Array<CmusMetadata>> {
    return Promise().map(on: _sessionQueue) {
      return try self._core.getListFrom(.library)
    }
  }

  func search(_ str: String) -> Promise<Void> {
    return runOnSessionQueue {
      try self._core.search(str)
    }
  }

  func activate() -> Promise<Void> {
    return runOnSessionQueue {
      try self._core.activate()
    }
  }

  // MARK: - Private

  private func startPollingTimer() {
    _statusPollingTimer = DispatchSource.makeTimerSource(queue: _sessionQueue)
    _statusPollingTimer!.setEventHandler {
      [core = _core, statusEventTarget] in
      do {
        let status = try core.getStatus()
        DispatchQueue.main.async {
          statusEventTarget.trigger(data: status)
        }
      } catch (let error) {
        DispatchQueue.main.async {
          statusEventTarget.reject(error: error)
        }
      }
    }
    _statusPollingTimer!.schedule(
      deadline: .now(), repeating: kStatusPollingInterval)
    _statusPollingTimer!.resume()
  }

  private func runOnSessionQueue(
      _ task: @escaping () throws -> ()) -> Promise<Void> {
    return Promise().done(on: _sessionQueue, task)
  }
}
