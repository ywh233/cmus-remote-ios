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
@property (nonatomic, readonly) NSString* _Nonnull album;
@property (nonatomic, readonly) NSString* _Nonnull artist;
@property (nonatomic, readonly) NSString* _Nonnull title;
@end

@interface CmusBasicMetadata: NSObject
@property (nonatomic, readonly)  NSString* _Nonnull filename;
@property (nonatomic, readonly) NSInteger duration;
@property (nonatomic, readonly)  CmusTags* _Nonnull tags;

@property (nonatomic, readonly)  NSString* _Nonnull titleOrBasename;
@property (nonatomic, readonly)  NSString* _Nonnull artistOrUnknown;
@end

@interface CmusStatus : CmusBasicMetadata
@property (nonatomic, readonly) enum CmusPlayerStatus status;
@property (nonatomic, readonly) NSInteger position;
@end

@interface CmusMetadata: CmusBasicMetadata
@end
