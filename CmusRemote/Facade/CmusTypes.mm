//
//  CmusStatus.m
//  CmusRemote
//
//  Created by Yuwei Huang on 2/21/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

#import "CmusTypes.h"

#include "../../deps/cmus-client-cpp/lib/metadata.h"
#include "../../deps/cmus-client-cpp/lib/status.h"
#include "../../deps/cmus-client-cpp/lib/tags.h"

#import "StringUtils.h"

@implementation CmusTags
@synthesize album = _album;
@synthesize artist = _artist;
@synthesize title = _title;

- (instancetype)initWithTags:(const cmusclient::Tags&)tags {
  _album = Utf8StringToNSString(tags.album);
  _artist = Utf8StringToNSString(tags.artist);
  _title = Utf8StringToNSString(tags.title);
  return self;
}
@end

@implementation CmusBasicMetadata
@synthesize filename = _filename;
@synthesize duration = _duration;
@synthesize tags = _tags;

- (instancetype)initWithFilename:(const std::string&)filename
                        duration:(NSInteger)duration
                            tags:(const cmusclient::Tags&)tags {
  _filename = Utf8StringToNSString(filename);
  _duration = duration;
  _tags = [[CmusTags alloc] initWithTags:tags];

  return self;
}

- (NSString*)titleOrBasename {
  if (_tags.title.length) {
    return _tags.title;
  }
  return [_filename lastPathComponent];
}

- (NSString*)artistOrUnknown {
  if (_tags.artist.length) {
    return _tags.artist;
  }
  return @"Unknown artist";
}

@end

@implementation CmusStatus
@synthesize status = _status;
@synthesize position = _position;
@synthesize leftVolume = _leftVolume;
@synthesize rightVolume = _rightVolume;
@synthesize settings = _settings;

- (instancetype)initWithStatus:(const cmusclient::Status&)status {
  self = [super initWithFilename:status.filename
                        duration:status.duration
                            tags:status.tags];

  switch (status.status) {
    case cmusclient::Status::PlayerStatus::STOPPED:
      _status = CmusPlayerStatusStopped;
      break;
    case cmusclient::Status::PlayerStatus::PLAYING:
      _status = CmusPlayerStatusPlaying;
      break;
    case cmusclient::Status::PlayerStatus::PAUSED:
      _status = CmusPlayerStatusPaused;
      break;
  }
  _position = status.position;

  _leftVolume = status.GetLeftVolume();
  _rightVolume = status.GetRightVolume();

  // Settings.
  NSMutableDictionary* mutableSettings =
      [[NSMutableDictionary alloc] initWithCapacity:status.settings.size()];
  for (const auto& pair : status.settings) {
    [mutableSettings setObject:Utf8StringToNSString(pair.second)
                        forKey:Utf8StringToNSString(pair.first)];
  }
  _settings = mutableSettings;
  return self;
}

+ (NSUInteger)maxVolume {
  return cmusclient::Status::kMaxVolume;
}

@end

@implementation CmusMetadata

- (instancetype)initWithMetadata:(const cmusclient::Metadata&)metadata {
  return [super initWithFilename:metadata.filename
                        duration:metadata.duration
                            tags:metadata.tags];
}


+ (NSArray<CmusMetadata*>*)convertFromMetadataList:
    (const std::vector<cmusclient::Metadata>&)list {
  NSMutableArray<CmusMetadata*>* array =
      [[NSMutableArray alloc] initWithCapacity:list.size()];
  for (const auto& metadata : list) {
    [array addObject:[[CmusMetadata alloc] initWithMetadata:metadata]];
  }
  return array;
}

@end
