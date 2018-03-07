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

typedef NS_ENUM(NSInteger, CmusView) {
  CmusViewLibrary,
  CmusViewSortedLibrary,
  CmusViewPlaylist,
  CmusViewPlayQueue,
  CmusViewBrowser,
  CmusViewFilters,
  CmusViewSettings,
};

typedef NS_ENUM(NSInteger, CmusListSource) {
  CmusListSourceLibrary,
  CmusListSourceFilteredLibrary,
  CmusListSourcePlaylist,
  CmusListSourceQueue,
};

@interface CmusTags : NSObject
@property (nonatomic, readonly) NSString* _Nonnull album;
@property (nonatomic, readonly) NSString* _Nonnull artist;
@property (nonatomic, readonly) NSString* _Nonnull comment;
@property (nonatomic, readonly) NSString* _Nonnull date;
@property (nonatomic, readonly) NSString* _Nonnull genre;
@property (nonatomic, readonly) NSString* _Nonnull title;
@property (nonatomic, readonly) NSString* _Nonnull tracknumber;
@end

@interface CmusBasicMetadata: NSObject
@property (nonatomic, readonly) NSString* _Nonnull filename;
@property (nonatomic, readonly) NSUInteger duration;
@property (nonatomic, readonly) CmusTags* _Nonnull tags;

@property (nonatomic, readonly) NSString* _Nonnull titleOrBasename;
@property (nonatomic, readonly) NSString* _Nonnull artistOrUnknown;
@end

@interface CmusStatus : CmusBasicMetadata
@property (nonatomic, readonly) enum CmusPlayerStatus status;
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) NSUInteger leftVolume;
@property (nonatomic, readonly) NSUInteger rightVolume;
@property (nonatomic, readonly)
NSDictionary<NSString*, NSString*>* _Nonnull settings;

@property (nonatomic, class, readonly) NSUInteger maxVolume;
@end

@interface CmusMetadata: CmusBasicMetadata
@end
