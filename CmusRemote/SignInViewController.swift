//
//  SignInViewController.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 2/19/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields

private let kInputAreaWidth: CGFloat = 400
private let kIconInputMargin: CGFloat = 60
private let kInputXMargin: CGFloat = 25
private let kHostNameInputWidthPercentage: CGFloat = 0.7

class SignInViewController: UIViewController {
  private var _hostNameInputController: MDCTextInputController?
  private var _portInputController: MDCTextInputController?
  private var _passwordInputController: MDCTextInputController?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = Theme.signInBackgroundColor

    let playIconView =
        UIImageView(image: UIImage(named: "play_circle_512"))
    playIconView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(playIconView)

    let hostNameInput = createTextInput(placeholderText: "Host name")
    hostNameInput.keyboardType = .URL
    hostNameInput.translatesAutoresizingMaskIntoConstraints = false
    _hostNameInputController =
         MDCTextInputControllerUnderline(textInput: hostNameInput)
    self.view.addSubview(hostNameInput)

    let portInput = createTextInput(placeholderText: "Port")
    portInput.keyboardType = .numberPad
    portInput.translatesAutoresizingMaskIntoConstraints = false
    _portInputController =
        MDCTextInputControllerUnderline(textInput: portInput)
    self.view.addSubview(portInput)

    let passwordInput = createTextInput(placeholderText: "Password")
    passwordInput.isSecureTextEntry = true
    passwordInput.translatesAutoresizingMaskIntoConstraints = false
    _passwordInputController =
      MDCTextInputControllerUnderline(textInput: passwordInput)
    self.view.addSubview(passwordInput)

    let layoutGuide = UILayoutGuide()
    self.view.addLayoutGuide(layoutGuide)
    let safeArea = self.view.safeAreaLayoutGuide
    let constraints = [
      layoutGuide.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
      layoutGuide.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
      layoutGuide.widthAnchor.constraint(
          lessThanOrEqualToConstant: kInputAreaWidth),
      layoutGuide.widthAnchor.constraint(
          lessThanOrEqualTo: safeArea.widthAnchor,
          constant: -2 * kInputXMargin),

      playIconView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      playIconView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),

      hostNameInput.topAnchor.constraint(
          equalTo: playIconView.bottomAnchor, constant: kIconInputMargin),
      hostNameInput.leadingAnchor.constraint(
          equalTo: layoutGuide.leadingAnchor),
      hostNameInput.widthAnchor.constraint(
          equalTo: layoutGuide.widthAnchor,
          multiplier: kHostNameInputWidthPercentage),

      portInput.topAnchor.constraint(
        equalTo: playIconView.bottomAnchor, constant: kIconInputMargin),
      portInput.leadingAnchor.constraint(
          equalTo: hostNameInput.trailingAnchor, constant: kInputXMargin),
      portInput.trailingAnchor.constraint(
        equalTo: layoutGuide.trailingAnchor),

      passwordInput.topAnchor.constraint(equalTo: hostNameInput.bottomAnchor),
      passwordInput.topAnchor.constraint(equalTo: portInput.bottomAnchor),
      passwordInput.leadingAnchor.constraint(
          equalTo: layoutGuide.leadingAnchor),
      passwordInput.trailingAnchor.constraint(
          equalTo: layoutGuide.trailingAnchor),
      passwordInput.bottomAnchor.constraint(
        equalTo: layoutGuide.bottomAnchor),
    ]
    NSLayoutConstraint.activate(constraints)
    let widthConstraint = layoutGuide.widthAnchor.constraint(
        equalToConstant: kInputAreaWidth)
    widthConstraint.priority = .defaultHigh
    widthConstraint.isActive = true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  private func createTextInput(placeholderText: String) -> MDCTextField {
    let input = MDCTextField()
    input.textColor = Theme.signInInputTextColor
    input.placeholderLabel.textColor =
      Theme.signInInputPlaceholderColor
    input.placeholder = placeholderText
    return input
  }
}

