//
//  FilesCollectionViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/25/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import MaterialComponents.MDCCollectionViewController
import PromiseKit
import UIKit

private let kReusableIdentifierItem = "fileItemCellIdentifier"
private let kProminentNoteIcon = #imageLiteral(resourceName: "ic_music_note_36pt").withRenderingMode(.alwaysTemplate)

class FilesCollectionViewController:
    MDCCollectionViewController,
    RemoteViewTab,
    MiniPlayerViewControllerDelegate {
  private var _files = Array<CmusMetadata>()
  private var _currentPlayingFilename: String?
  private var _statusBindingHolder: EventBindingHolder?
  private weak var _session: CmusRemoteSession?

  // MARK: - RemoteViewTab

  var viewController: UIViewController {
    get { return self }
  }

  let tabTitle = "List"
  let showsMiniPlayer = true

  func onTabSelected() {
    refreshContent()
  }

  // Must be called immediately after the instance is created.
  func registerSession(_ session: CmusRemoteSession) {
    _session = session
    _statusBindingHolder = _session?.statusEventTarget.addListener(onStatus(_:))
  }

  // MARK: - MiniPlayerViewControllerDelegate

  func miniPlayerDidTapTrackName(_ player: MiniPlayerViewController) {
    scrollToCurrentFile()
  }

  // MARK: - MDCCollectionViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView!.register(MDCCollectionViewTextCell.self,
                            forCellWithReuseIdentifier: kReusableIdentifierItem)
  }

  func refreshContent() {
    _ = _session?.getList(view: .library).done { [weak self] files in
      self?._files = files
      self?.collectionView!.reloadData()
    }
  }

  func scrollToCurrentFile() {
    if _currentPlayingFilename == nil || _currentPlayingFilename!.isEmpty {
      return
    }

    let index = _files.index {
      $0.filename == self._currentPlayingFilename
    }
    if index == nil {
      return
    }
    let indexPath = IndexPath(item: index!, section: 0)
    collectionView?.scrollToItem(at: indexPath, at: .centeredVertically,
                                 animated: true);
  }

  override func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
    let file = _files[indexPath.item]
    var searchString = URL(fileURLWithPath: file.filename).lastPathComponent
    if (file.tags.title != nil && !file.tags.title.isEmpty) {
      searchString += " " + file.tags.title
    }
    if (file.tags.artist != nil && !file.tags.artist.isEmpty) {
      searchString += " " + file.tags.artist
    }
    _ = _session?.search(searchString).then { [weak _session] in
      _session == nil ? Promise() : _session!.activate()
    }
  }

  // MARK: - UICollectionViewDataSource

  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return _files.count
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: kReusableIdentifierItem, for: indexPath)
      as! MDCCollectionViewTextCell
    cell.prepareForReuse()
    let metadata = _files[indexPath.item]
    cell.textLabel?.text = metadata.titleOrBasename
    cell.detailTextLabel?.text = metadata.artistOrUnknown

    if _currentPlayingFilename == metadata.filename {
      if cell.accessoryView == nil {
        cell.accessoryView = UIImageView(image: kProminentNoteIcon)
        cell.accessoryView!.tintColor = Theme.controlProminentColor
      }
    } else if cell.accessoryView != nil {
      cell.accessoryView = nil
    }
    return cell
  }

  // MARK: - MDCCollectionViewStylingDelegate

  override func collectionView(_ collectionView: UICollectionView,
                               cellHeightAt indexPath: IndexPath) -> CGFloat {
    return MDCCellDefaultTwoLineHeight
  }

  // MARK: - Private

  private func onStatus(_ status: CmusStatus) {
    let currentPlayingFile = status.status == .playing ? status.filename : nil
    if (currentPlayingFile == _currentPlayingFilename) {
      return
    }

    _currentPlayingFilename = currentPlayingFile
    self.collectionView?.reloadData()
  }
}
