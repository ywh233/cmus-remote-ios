//
//  Math.swift
//  CmusRemote
//
//  Created by Yuwei Huang on 3/4/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

import UIKit

let kDoubleMaxVolume = Double(CmusStatus.maxVolume)
let kEMinusOne = M_E - 1

func rawVolumeToLog(_ rawVol: Double) -> Double {
  assert(rawVol >= 0 && rawVol <= kDoubleMaxVolume)
  let normalRawVol = rawVol / kDoubleMaxVolume
  let normalLogVol = (pow(M_E, normalRawVol) - 1) / kEMinusOne
  return normalLogVol * kDoubleMaxVolume
}

func logVolumeToRaw(_ logVol: Double) -> Double {
  assert(logVol >= 0 && logVol <= kDoubleMaxVolume)
  let normalLogVol = logVol / kDoubleMaxVolume
  let normalRawVol = log(kEMinusOne * normalLogVol + 1)
  return normalRawVol * kDoubleMaxVolume
}

func secondsToString(_ seconds: UInt) -> String {
  let minutes = seconds / 60
  let seconds_remainder = seconds % 60
  return String(format: "%02u:%02u", minutes, seconds_remainder)
}
