//
//  SessionConsumer.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/25/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

protocol SessionRegistrar {
  // This method might be called multiple times. Implementation should only
  // store a weak reference to the session.
  func registerSession(_ session: CmusRemoteSession)
}
