//
//  StringUtils.h
//  CmusRemote
//
//  Created by Yuwei Huang on 2/28/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

#ifndef StringUtils_h
#define StringUtils_h

#include <string>

#import <Foundation/Foundation.h>

extern std::string NSStringToUtf8String(NSString* str);
extern NSString* Utf8StringToNSString(const std::string& str);

#endif /* StringUtils_h */
