//
//  SignInViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/19/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialTextFields

private let kInputAreaWidth: CGFloat = 400
private let kIconInputMargin: CGFloat = 25
private let kInputXMargin: CGFloat = 25
private let kHostNameInputWidthPercentage: CGFloat = 0.7
private let kConnectButtonHeight: CGFloat = 50

class SignInViewController: UIViewController {
  private var _hostNameInput: MDCTextField!
  private var _portInput: MDCTextField!
  private var _passwordInput: MDCTextField!
  private var _connectButton: MDCFlatButton!

  private var _hostNameInputController: MDCTextInputController!
  private var _portInputController: MDCTextInputController!
  private var _passwordInputController: MDCTextInputController!

  private var _keyboardHeightConstraint: NSLayoutConstraint!
  private var _layoutGuide: UILayoutGuide!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = Theme.controlBackgroundColor

    let playIconView = UIImageView(image: #imageLiteral(resourceName: "large_play_icon"))
    playIconView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(playIconView)

    _hostNameInput = createTextInput(
        placeholderText: "Host name", controller: &_hostNameInputController)
    _hostNameInput.keyboardType = .URL
    view.addSubview(_hostNameInput)

    _portInput = createTextInput(
        placeholderText: "Port", controller: &_portInputController)
    _portInput.keyboardType = .numberPad
    view.addSubview(_portInput)

    _passwordInput = createTextInput(
        placeholderText: "Password", controller: &_passwordInputController)
    _passwordInput.isSecureTextEntry = true
    view.addSubview(_passwordInput)

    _connectButton = MDCFlatButton()
    _connectButton.setTitleColor(Theme.controlMainColor, for: .normal)
    setButtonEnabled(true)
    _connectButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_connectButton)
    _connectButton.addTarget(
        self, action: #selector(onConnect), for: UIControlEvents.touchUpInside)


    // Layout
    _layoutGuide = UILayoutGuide()
    view.addLayoutGuide(_layoutGuide)
    let safeArea = view.safeAreaLayoutGuide
    let constraints = [
      _layoutGuide.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
      _layoutGuide.widthAnchor.constraint(
          lessThanOrEqualToConstant: kInputAreaWidth),
      _layoutGuide.widthAnchor.constraint(
          lessThanOrEqualTo: safeArea.widthAnchor,
          constant: -2 * kInputXMargin),

      playIconView.topAnchor.constraint(equalTo: _layoutGuide.topAnchor),
      playIconView.centerXAnchor.constraint(
          equalTo: _layoutGuide.centerXAnchor),

      _hostNameInput.topAnchor.constraint(
          equalTo: playIconView.bottomAnchor, constant: kIconInputMargin),
      _hostNameInput.leadingAnchor.constraint(
          equalTo: _layoutGuide.leadingAnchor),
      _hostNameInput.widthAnchor.constraint(
          equalTo: _layoutGuide.widthAnchor,
          multiplier: kHostNameInputWidthPercentage),

      _portInput.topAnchor.constraint(
        equalTo: playIconView.bottomAnchor, constant: kIconInputMargin),
      _portInput.leadingAnchor.constraint(
          equalTo: _hostNameInput.trailingAnchor, constant: kInputXMargin),
      _portInput.trailingAnchor.constraint(
        equalTo: _layoutGuide.trailingAnchor),

      _passwordInput.topAnchor.constraint(equalTo: _hostNameInput.bottomAnchor),
      _passwordInput.topAnchor.constraint(equalTo: _portInput.bottomAnchor),
      _passwordInput.leadingAnchor.constraint(
          equalTo: _layoutGuide.leadingAnchor),
      _passwordInput.trailingAnchor.constraint(
          equalTo: _layoutGuide.trailingAnchor),

      _connectButton.topAnchor.constraint(
          equalTo: _passwordInput.bottomAnchor),
      _connectButton.leadingAnchor.constraint(
          equalTo: _layoutGuide.leadingAnchor),
      _connectButton.trailingAnchor.constraint(
          equalTo: _layoutGuide.trailingAnchor),
      _connectButton.heightAnchor.constraint(
          equalToConstant: kConnectButtonHeight),
      _connectButton.bottomAnchor.constraint(
          equalTo: _layoutGuide.bottomAnchor),
    ]
    NSLayoutConstraint.activate(constraints)

    // Other constraints.
    let centerYConstraint =
        _layoutGuide.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
    centerYConstraint.priority = .defaultHigh
    centerYConstraint.isActive = true
    let widthConstraint = _layoutGuide.widthAnchor.constraint(
        equalToConstant: kInputAreaWidth)
    widthConstraint.priority = .defaultHigh
    widthConstraint.isActive = true

    // Register events.
    NotificationCenter.default.addObserver(
        self, selector: #selector(onKeyboardWillShow(notification:)),
        name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onKeyboardWillHide(notification:)),
      name: .UIKeyboardWillHide, object: nil)

    // Recognizer
    let swipeDownRecognizer = UISwipeGestureRecognizer(
      target: self, action: #selector(onSwipeDown(gesture:)))
    view.isUserInteractionEnabled = true
    swipeDownRecognizer.direction = .down
    swipeDownRecognizer.numberOfTouchesRequired = 1
    view.addGestureRecognizer(swipeDownRecognizer)

    // Restore saved data.
    _hostNameInput.text = Persistence.hostName
    _portInput.text = Persistence.port
    _passwordInput.text = Persistence.password
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: Private

  @objc private func onSwipeDown(gesture: UISwipeGestureRecognizer) {
    if (gesture.state == .ended) {
      view.endEditing(true)
    }
  }

  @objc private func onConnect() {
    setButtonEnabled(false)
    let session = CmusRemoteSession()
    session.connect(host: _hostNameInput!.text!,
                    port: _portInput!.text!,
                    password: _passwordInput!.text!).done {
          [hostName = _hostNameInput.text,
           port = _portInput.text,
           password = _passwordInput.text] in
        // Store entered data.
        Persistence.hostName = hostName
        Persistence.port = port
        Persistence.password = password

        let remoteVc = RemoteViewController()
        remoteVc.setSession(session: session)
        self.navigationController!.pushViewController(remoteVc, animated: true)
      }.catch { error in
        handleSessionError(error)
      }.finally {
        self.setButtonEnabled(true)
    }
  }

  @objc private func onKeyboardWillShow(notification: NSNotification) {
    let endFrame =
        notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
    setKeyboardHeight(endFrame.size.height)
  }

  @objc private func onKeyboardWillHide(notification: NSNotification) {
    setKeyboardHeight(0)
  }

  private func setButtonEnabled(_ enabled: Bool) {
    _connectButton?.setEnabled(enabled, animated: true)
    _connectButton?.setTitle(enabled ? "Connect" : "Connecting", for: .normal)
  }

  private func setKeyboardHeight(_ height: CGFloat) {
    if (_keyboardHeightConstraint != nil) {
      _keyboardHeightConstraint?.isActive = false
      _keyboardHeightConstraint = nil
    }
    if (height > 0) {
      _keyboardHeightConstraint = _layoutGuide?.bottomAnchor.constraint(
          lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
          constant: -height)
      _keyboardHeightConstraint?.isActive = true
    }
    view.layoutIfNeeded()
  }
}

private func createTextInput(
  placeholderText: String,
  controller: inout MDCTextInputController!) -> MDCTextField {
  let input = MDCTextField()
  input.textColor = Theme.controlMainColor
  input.placeholderLabel.textColor = Theme.controlSecondaryColor
  input.placeholder = placeholderText
  input.autocapitalizationType = .none
  input.autocorrectionType = .no
  input.translatesAutoresizingMaskIntoConstraints = false
  controller = MDCTextInputControllerUnderline(textInput: input)
  controller?.activeColor = Theme.controlMainColor
  return input
}
