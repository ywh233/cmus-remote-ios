//
//  TrackImageView.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/3/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

let kIntrinsicSize = CGSize(width: 350, height: 350)
let kMusicNoteImage = #imageLiteral(resourceName: "music_note_512").withRenderingMode(.alwaysTemplate)
let kMusicNoteSize = CGSize(width: 256, height: 256)

class TrackImageView: UIView {
  private let _musicNoteImageView: UIImageView

  override var intrinsicContentSize: CGSize {
    get { return kIntrinsicSize }
  }

  override init(frame: CGRect) {
    _musicNoteImageView = UIImageView()

    super.init(frame: frame)

    _musicNoteImageView.tintColor = Theme.controlSecondaryColor
    _musicNoteImageView.image = kMusicNoteImage
    _musicNoteImageView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(_musicNoteImageView)

    NSLayoutConstraint.activate([
      _musicNoteImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      _musicNoteImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      _musicNoteImageView.widthAnchor.constraint(
          equalToConstant: kMusicNoteSize.width),
      _musicNoteImageView.heightAnchor.constraint(
        equalToConstant: kMusicNoteSize.height),
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
