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

private let kViewTitle = "All Tracks"
private let kReusableIdentifierItem = "fileItemCellIdentifier"
private let kProminentNoteIcon = #imageLiteral(resourceName: "ic_music_note_36pt").withRenderingMode(.alwaysTemplate)

class LibraryCollectionViewController:
    MDCCollectionViewController,
    MiniPlayerViewControllerDelegate,
    SearchHeaderViewDelegate {
  private var _files = Array<CmusMetadata>()
  private var _isKeyboardShowing: Bool = false
  // Exists only if in search mode.
  private var _filteredFiles: Array<CmusMetadata>?
  private var _currentStatus: CmusStatus?
  private var _statusBindingHolder: EventBindingHolder?
  private weak var _session: CmusRemoteSession?

  private var _isSearchMode: Bool {
    return (parent as! NavigationBarContainerViewController)
        .headerView?.isKind(of: SearchHeaderView.self) ?? false
  }

  private var _filesToShow: Array<CmusMetadata> {
    get { return _filteredFiles ?? _files }
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

    title = kViewTitle

    navigationItem.rightBarButtonItem =
        UIBarButtonItem(image: #imageLiteral(resourceName: "ic_search").withRenderingMode(.alwaysTemplate),
                        style: .plain, target: self,
                        action: #selector(onSearch))
    navigationItem.rightBarButtonItem?.tintColor = Theme.controlProminentColor
  }

  override func viewWillAppear(_ animated: Bool) {
    NotificationCenter.default.addObserver(
        self, selector: #selector(keyboardDidShow(notification:)),
        name: .UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(
        self, selector: #selector(keyboardDidHide(notification:)),
        name: .UIKeyboardDidHide, object: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }

  func refreshContent() {
    _ = _session?.getList(view: .library).done { [weak self] files in
      self?._files = files
      self?.exitSearchMode()
      self?.collectionView!.reloadData()
    }
  }

  func scrollToCurrentFile() {
    if _currentStatus?.filename == nil {
      return
    }

    let index = _filesToShow.index {
      $0.filename == self._currentStatus!.filename
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
    let file = _filesToShow[indexPath.item]
    var searchString = URL(fileURLWithPath: file.filename).lastPathComponent
    if (!file.tags.title.isEmpty) {
      searchString += " " + file.tags.title
    }
    if (!file.tags.artist.isEmpty) {
      searchString += " " + file.tags.artist
    }
    _ = _session?.search(searchString).then { [weak _session] in
      _session == nil ? Promise() : _session!.activate()
    }
  }

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if _isKeyboardShowing {
      parent?.view.endEditing(true)
    }
  }

  // MARK: - UICollectionViewDataSource

  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return _filesToShow.count
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: kReusableIdentifierItem, for: indexPath)
      as! MDCCollectionViewTextCell
    cell.prepareForReuse()
    let metadata = _filesToShow[indexPath.item]
    cell.textLabel?.text = metadata.titleOrBasename
    cell.detailTextLabel?.text = metadata.artistOrUnknown

    if _currentStatus?.status == .playing &&
        _currentStatus?.filename == metadata.filename {
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

  // MARK: - SearchHeaderViewDelegate

  func searchHeaderViewDidCancel(_ headerView: SearchHeaderView) {
    exitSearchMode()
  }

  func searchHeaderView(_ headerView: SearchHeaderView,
                        didEditText text: String) {
    if text.isEmpty {
      if _filteredFiles == nil {
        return
      }
      _filteredFiles = nil
    } else {
      _filteredFiles = _files.filter {
        let lowerCaseText = text.lowercased()
        return $0.filename.lowercased().contains(lowerCaseText) ||
          $0.artistOrUnknown.lowercased().contains(lowerCaseText) ||
          $0.tags.album.lowercased().contains(lowerCaseText) ||
          $0.tags.title.lowercased().contains(lowerCaseText)
      }
    }
    collectionView?.reloadData()
  }

  func searchHeaderViewTextDidBeginEditing(_ headerView: SearchHeaderView) {
    collectionView?.setContentOffset(.zero, animated: false)
  }

  // MARK: - Event

  @objc private func onSearch() {
    let headerView = SearchHeaderView()
    headerView.delegate = self
    (parent as! NavigationBarContainerViewController).headerView = headerView
  }

  @objc private func keyboardDidShow(notification: Notification) {
    _isKeyboardShowing = true
  }

  @objc private func keyboardDidHide(notification: Notification) {
    _isKeyboardShowing = false
  }

  // MARK: - Private

  private func onStatus(_ status: CmusStatus) {
    if (!doesStatusNeedReload(status)) {
      return
    }

    _currentStatus = status
    self.collectionView?.reloadData()
  }

  private func exitSearchMode() {
    (parent as! NavigationBarContainerViewController).headerView = nil
    if _filteredFiles == nil {
      return
    }
    _filteredFiles = nil
    self.collectionView?.reloadData()
  }

  private func doesStatusNeedReload(_ status: CmusStatus) -> Bool {
    return (_currentStatus == nil ||
      _currentStatus!.filename != status.filename ||
      _currentStatus!.status != status.status)
  }
}
