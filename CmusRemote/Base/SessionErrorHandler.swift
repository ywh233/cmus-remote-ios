//
//  SessionErrorHandler.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/24/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit
import MaterialComponents.MDCAlertController

func handleSessionError(_ error: Error) {
  let dialog = MDCAlertController(
    title: "Session connection failed",
    message: error.localizedDescription)
  dialog.addAction(MDCAlertAction(title: "OK", handler: nil))
  findTopPresentedVC()?.present(dialog, animated: true, completion: nil)
}

private func findTopPresentedVC() -> UIViewController? {
  var topVC = UIApplication.shared.keyWindow?.rootViewController
  while topVC?.presentedViewController != nil {
    topVC = topVC?.presentedViewController
  }
  return topVC
}
