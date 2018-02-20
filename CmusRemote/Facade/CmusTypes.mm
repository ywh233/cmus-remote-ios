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

@implementation CmusTags
@synthesize album = _album;
@synthesize artist = _artist;
@synthesize title = _title;

- (instancetype)initWithTags:(const cmusclient::Tags)tags {
  _album = [NSString stringWithUTF8String:tags.album.c_str()];
  _artist = [NSString stringWithUTF8String:tags.artist.c_str()];
  _title = [NSString stringWithUTF8String:tags.title.c_str()];
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
  _filename = [NSString stringWithUTF8String:filename.c_str()];
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

  return self;
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
