//
//  InfoViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/6/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import MaterialComponents.MaterialDialogs
import MaterialComponents.MDCTypography
import MaterialComponents.MaterialCollections
import UIKit

private let kReusableIdentifierItem = "infoItemCellIdentifier"
private let kContentInset: CGFloat = 16
private let kKeyLabelTrailingPadding: CGFloat = 8
private let kBetweenLinesPadding: CGFloat = 8

class InfoViewController: MDCCollectionViewController, SessionRegistrar {
  private var _statusUpdateHolder: EventBindingHolder?

  private var _currentFileName: String?

  private var _infoPairs: [(String, String)]?  // key, value

  override func viewDidLoad() {
    collectionView!.backgroundColor = Theme.controlBackgroundColor
    collectionView!.register(
        MDCCollectionViewTextCell.self,
        forCellWithReuseIdentifier: kReusableIdentifierItem)
  }

  func registerSession(_ session: CmusRemoteSession) {
    _statusUpdateHolder = session.statusEventTarget.addListener(onStatus(_:))
  }

  // MARK: - Collection View

  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    if _infoPairs == nil {
      return 0
    }

    return _infoPairs!.count
  }

  override func collectionView(_ collectionView: UICollectionView,
                               cellHeightAt indexPath: IndexPath) -> CGFloat {
    return MDCCellDefaultOneLineHeight
  }

  override func collectionView(
      _ collectionView: UICollectionView,
      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: kReusableIdentifierItem, for: indexPath)
            as! MDCCollectionViewTextCell
    cell.prepareForReuse()
    let pair = _infoPairs![indexPath.item]

    let str = NSMutableAttributedString(string: pair.0 + ": " + pair.1)
    str.setAttributes([.foregroundColor: Theme.controlProminentColor],
                      range: NSMakeRange(0, pair.0.count + 1))
    cell.textLabel?.attributedText = str
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
    if _infoPairs == nil || _infoPairs!.count <= indexPath.item {
      return
    }
    let pair = _infoPairs![indexPath.item]
    let alert = MDCAlertController(title: pair.0, message: pair.1)
    alert.addAction(MDCAlertAction(title: "OK", handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  // MARK: - Private

  private func onStatus(_ status: CmusStatus) {
    if status.filename == _currentFileName {
      return
    }
    _currentFileName = status.filename

    _infoPairs = []
    addPairIfNotEmpty(key: "File", value: status.filename,
                      array: &_infoPairs!)
    if status.duration > 0 {
      addPairIfNotEmpty(key: "Duration",
                        value: secondsToString(status.duration),
                        array: &_infoPairs!)
    }
    addPairIfNotEmpty(key: "Title", value: status.tags.title,
                      array: &_infoPairs!)
    addPairIfNotEmpty(key: "Artist", value: status.tags.artist,
                      array: &_infoPairs!)
    addPairIfNotEmpty(key: "Album", value: status.tags.artist,
                      array: &_infoPairs!)
    addPairIfNotEmpty(key: "Date", value: status.tags.date,
                      array: &_infoPairs!)
    addPairIfNotEmpty(key: "Track No.", value: status.tags.tracknumber,
                      array: &_infoPairs!)
    addPairIfNotEmpty(key: "Genre", value: status.tags.genre,
                      array: &_infoPairs!)
    addPairIfNotEmpty(key: "Comment", value: status.tags.comment,
                      array: &_infoPairs!)

    collectionView?.reloadData()
  }
}

private func addPairIfNotEmpty(key: String,
                               value: String,
                               array: inout [(String, String)]) {
  if value.isEmpty {
    return
  }
  array.append((key, value))
}
