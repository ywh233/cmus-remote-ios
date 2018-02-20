//
//  Persistence.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/22/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

private let kUserDefaultsHostNameKey = "SignInHostName"
private let kUserDefaultsPortKey = "SignInPort"
private let kKeychainPasswordSecService = "CmusRemotePassword"

class Persistence {
  static var hostName: String? {
    get {
      return UserDefaults.standard.string(forKey: kUserDefaultsHostNameKey)
    }
    set (val) {
      UserDefaults.standard.set(val, forKey: kUserDefaultsHostNameKey)
    }
  }

  static var port: String? {
    get {
      return UserDefaults.standard.string(forKey: kUserDefaultsPortKey)
    }

    set (val) {
      UserDefaults.standard.set(val, forKey: kUserDefaultsPortKey)
    }
  }

  static var password: String? {
    get {
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: kKeychainPasswordSecService,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: kCFBooleanTrue
      ]
      var data: AnyObject?
      let status: OSStatus = withUnsafeMutablePointer(to: &data) {
        SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
      }
      if (status == errSecSuccess) {
        return String(data:data as! Data, encoding:.utf8)
      }
      if (status != errSecItemNotFound) {
        print("Failed to get password: \(status)")
      }
      return nil
    }

    set (val) {
      let deleteQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: kKeychainPasswordSecService
      ]
      let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
      if (deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound) {
        print("Failed to delete old password: \(deleteStatus)")
        return
      }
      if (val == nil) {
        return
      }
      let addQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: kKeychainPasswordSecService,
        kSecValueData as String: val!.data(using: .utf8)!
      ]
      let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
      if (addStatus != errSecSuccess) {
        print("Failed to add new password: \(addStatus)")
      }
    }
  }
}
