//
//  TouchCapturingView.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/4/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

protocol TouchCapturingViewDelegate: class {
  func touchCapturingView(_ view: TouchCapturingView,
                          didBeginTouches: Set<UITouch>);
  func touchCapturingView(_ view: TouchCapturingView,
                          didEndTouches: Set<UITouch>);
  func touchCapturingView(_ view: TouchCapturingView,
                          didCancelTouches: Set<UITouch>);
}

class TouchCapturingView: UIView {
  weak var delegate: TouchCapturingViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    delegate?.touchCapturingView(self, didBeginTouches: touches)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    delegate?.touchCapturingView(self, didEndTouches: touches)
  }

  override func touchesCancelled(_ touches: Set<UITouch>,
                                 with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)

    delegate?.touchCapturingView(self, didCancelTouches: touches)
  }
}
