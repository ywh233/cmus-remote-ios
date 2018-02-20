//
//  CmusRemoteSession.m
//  CmusRemote
//
//  Created by Yuwei Huang on 2/19/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "CmusRemoteSessionCore.h"

#include <memory>

#include "../../deps/cmus-client-cpp/lib/cmus_client.h"

#import "CmusTypes+ObjCpp.h"

static void ConvertError(const std::runtime_error& err, NSError** out_err) {
  if (!out_err) {
    return;
  }
  NSDictionary* userInfo = @{
                             NSLocalizedDescriptionKey: [NSString stringWithUTF8String:err.what()]
                             };
  *out_err = [NSError errorWithDomain:NSCocoaErrorDomain
                                 code:-1
                             userInfo:userInfo];
  NSLog(@"Failed to connect: %s", err.what());
}

static bool TryBlock(void(^block)(), NSError** error) {
  try {
    block();
  } catch (const std::runtime_error& err) {
    ConvertError(err, error);
  }
  return !(*error);
}


@implementation CmusRemoteSessionCore {
  std::unique_ptr<cmusclient::CmusClient> _client;
}

- (BOOL)connectToHost:(NSString *)hostName
                 port:(NSString *)port
             password:(NSString *)password
                error:(NSError**)error {
  return TryBlock(^{
    _client.reset(new cmusclient::CmusClient([hostName UTF8String],
                                             [port UTF8String],
                                             [password UTF8String]));
  }, error);
}

- (CmusStatus*)getStatusWithError:(NSError**)error {
  assert(_client);
  try {
    return [[CmusStatus alloc] initWithStatus:_client->GetStatus()];
  } catch (const std::runtime_error& err) {
    ConvertError(err, error);
  }
  return nil;
}

- (NSArray<CmusMetadata*>*)getListForView:(CmusViewType)viewType
                                    error:(NSError**)error {
  cmusclient::CmusClient::View view = cmusclient::CmusClient::View::LIBRARY;
  switch (viewType) {
    case CmusViewTypeLibrary:
      view = cmusclient::CmusClient::View::LIBRARY;
      break;
    case CmusViewTypeFilteredLibrary:
      view = cmusclient::CmusClient::View::FILTERED_LIBRARY;
      break;
    case CmusViewTypePlaylist:
      view = cmusclient::CmusClient::View::PLAYLIST;
      break;
    case CmusViewTypeQueue:
      view = cmusclient::CmusClient::View::QUEUE;
      break;
    default:
      assert(false);
  }

  try {
    auto result = _client->GetList(view);
    return [CmusMetadata convertFromMetadataList:result];
  } catch (const std::runtime_error& err) {
    ConvertError(err, error);
  }
  return nil;
}

- (BOOL)playWithError:(NSError**)error {
  return TryBlock(^{
    _client->Play();
  }, error);
}
- (BOOL)pauseWithError:(NSError**)error {
  return TryBlock(^{
    _client->Pause();
  }, error);
}

- (BOOL)previousWithError:(NSError**)error {
  return TryBlock(^{
    _client->Previous();
  }, error);
}

- (BOOL)nextWithError:(NSError**)error {
  return TryBlock(^{
    _client->Next();
  }, error);
}

- (BOOL)search:(NSString*)str error:(NSError**)error {
  if (!str || !str.length) {
    return false;
  }

  return TryBlock(^{
    _client->Search([str UTF8String]);
  }, error);
}

- (BOOL)activateWithError:(NSError**)error {
  return TryBlock(^{
    _client->Activate();
  }, error);
}

@end
