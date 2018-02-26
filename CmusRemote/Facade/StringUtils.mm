//
//  StringUtils.m
//  CmusRemote
//
//  Created by Yuwei Huang on 2/28/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

#import "StringUtils.h"

std::string NSStringToUtf8String(NSString* str) {
  const char* utf8_str = [str UTF8String];
  return utf8_str ? utf8_str : "";
}

NSString* Utf8StringToNSString(const std::string& str) {
  NSString* ns_str = [NSString stringWithUTF8String:str.c_str()];
  return ns_str ? ns_str : @"";
}
