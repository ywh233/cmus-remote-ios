//
//  EventTarget.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/23/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

class EventTarget<CallbackData> {
  private var _listeners = EventBindingList<CallbackData>()
  private var _errorHandlers = EventBindingList<Error>()

  func addListener(
      _ listener: @escaping (CallbackData)->()) -> EventBindingHolder {
    return _listeners.addBinding(listener)
  }

  func addErrorHandler(
      _ handler: @escaping (Error)->()) -> EventBindingHolder {
    return _errorHandlers.addBinding(handler)
  }

  func trigger(data: CallbackData) {
    _listeners.raise(data: data)
  }

  func reject(error: Error) {
    _errorHandlers.raise(data: error)
  }
}

class EventBindingHolder {
  private(set) var bindingId: UInt64

  private let _remover: ()->()

  init(bindingId: UInt64, remover: @escaping ()->()) {
    self.bindingId = bindingId
    _remover = remover
  }

  deinit {
    _remover()
  }
}

private class EventBindingList<BindingData> {
  private var _bindings = Dictionary<UInt64, (BindingData)->()>()

  func addBinding(
      _ binding: @escaping (BindingData)->()) -> EventBindingHolder {
    assert(Thread.isMainThread)
    let randomKey = getRandomHashKey()
    assert(_bindings[randomKey] == nil)
    _bindings[randomKey] = binding
    return EventBindingHolder(bindingId: randomKey) { [weak self] in
      self?._bindings[randomKey] = nil
    }
  }

  func raise(data: BindingData) {
    assert(Thread.isMainThread)
    for (_, binding) in _bindings {
      binding(data)
    }
  }
}

private func getRandomHashKey() -> UInt64 {
  let key = Date().timeIntervalSince1970.bitPattern
  let randomNumber = UInt64(arc4random())
  return key | (randomNumber << 31)
}
