//
//  SearchHeaderView.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/26/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import MaterialComponents.MDCButton
import MaterialComponents.MaterialTextFields
import UIKit

private let kSearchBoxMarginLeft: CGFloat = 16
private let kSearchBoxMarginRight: CGFloat = 8
private let kButtonMarginRight: CGFloat = 4
private let kSearchBoxDownAdjustment: CGFloat = 8

protocol SearchHeaderViewDelegate: class {
  func searchHeaderViewDidCancel(_ headerView: SearchHeaderView)
  func searchHeaderViewTextDidBeginEditing(_ headerView: SearchHeaderView)
  func searchHeaderView(_ headerView: SearchHeaderView,
                        didEditText text: String)
}

class SearchHeaderView: UIView {
  weak var delegate: SearchHeaderViewDelegate?

  private var _searchBox: MDCTextField
  private var _cancelButton: MDCFlatButton
  private var _searchBoxController: MDCTextInputControllerBase

  init() {
    _searchBox = MDCTextField()
    _cancelButton = MDCFlatButton()
    _searchBoxController =
        MDCTextInputControllerUnderline(textInput: _searchBox)

    super.init(frame: .zero)
    let searchIconView =
        UIImageView(image: #imageLiteral(resourceName: "ic_search_18pt").withRenderingMode(.alwaysTemplate))
    searchIconView.tintColor = Theme.controlProminentColor
    _searchBox.leadingView = searchIconView
    _searchBox.leadingViewMode = .always
    NotificationCenter.default.addObserver(
        self, selector: #selector(onTextChanged(notification:)),
        name: .UITextFieldTextDidChange, object: nil)
    NotificationCenter.default.addObserver(
        self, selector: #selector(onTextBeganEditing(notification:)),
        name: .UITextFieldTextDidBeginEditing, object: nil)

    _searchBoxController.isFloatingEnabled = false
    _searchBoxController.activeColor = Theme.controlMainColor

    _cancelButton.addTarget(self, action: #selector(onCancel),
                            for: .touchUpInside)

    _cancelButton.setTitle("Cancel", for: .normal)
    _cancelButton.setTitleColor(Theme.controlProminentColor, for: .normal)

    _searchBox.translatesAutoresizingMaskIntoConstraints = false
    _cancelButton.translatesAutoresizingMaskIntoConstraints = false

    self.addSubview(_searchBox)
    self.addSubview(_cancelButton)

    NSLayoutConstraint.activate([
      _searchBox.centerYAnchor.constraint(equalTo: self.centerYAnchor,
                                          constant: kSearchBoxDownAdjustment),
      _searchBox.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                          constant: kSearchBoxMarginLeft),
      _cancelButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      _cancelButton.leadingAnchor.constraint(
        equalTo: _searchBox.trailingAnchor, constant: kSearchBoxMarginRight),
      _cancelButton.trailingAnchor.constraint(
        equalTo: self.trailingAnchor, constant: -kButtonMarginRight),
    ])
    forceIntrinsicSize(_cancelButton, for: .horizontal)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToSuperview() {
    _searchBox.becomeFirstResponder()
  }

  // MARK: - Events

  @objc private func onCancel() {
    delegate?.searchHeaderViewDidCancel(self)
  }

  @objc private func onTextBeganEditing(notification: Notification) {
    let textField = notification.object as? MDCTextField
    if textField == nil || textField != _searchBox {
      return
    }
    delegate?.searchHeaderViewTextDidBeginEditing(self)
  }

  @objc private func onTextChanged(notification: Notification) {
    let textField = notification.object as? MDCTextField
    if textField == nil || textField != _searchBox {
      return
    }
    delegate?.searchHeaderView(self, didEditText: _searchBox.text ?? "")
  }
}
