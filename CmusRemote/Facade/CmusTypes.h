//
//  CmusStatus.h
//  CmusRemote
//
//  Created by Yuwei Huang on 2/21/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CmusPlayerStatus) {
  CmusPlayerStatusStopped,
  CmusPlayerStatusPlaying,
  CmusPlayerStatusPaused
};

typedef NS_ENUM(NSInteger, CmusViewType) {
  CmusViewTypeLibrary,
  CmusViewTypeFilteredLibrary,
  CmusViewTypePlaylist,
  CmusViewTypeQueue,
};

@interface CmusTags : NSObject
@property (nonatomic, readonly) NSString* album;
@property (nonatomic, readonly) NSString* artist;
@property (nonatomic, readonly) NSString* title;
@end

@interface CmusBasicMetadata: NSObject
@property (nonatomic, readonly) NSString* filename;
@property (nonatomic, readonly) NSInteger duration;
@property (nonatomic, readonly) CmusTags* tags;

@property (nonatomic, readonly) NSString* titleOrBasename;
@property (nonatomic, readonly) NSString* artistOrUnknown;
@end

@interface CmusStatus : CmusBasicMetadata
@property (nonatomic, readonly) enum CmusPlayerStatus status;
@property (nonatomic, readonly) NSInteger position;
@end

@interface CmusMetadata: CmusBasicMetadata
@end
