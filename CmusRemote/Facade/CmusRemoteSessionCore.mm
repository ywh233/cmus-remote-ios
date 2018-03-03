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
#import "StringUtils.h"

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
    _client.reset(new cmusclient::CmusClient(
        NSStringToUtf8String(hostName),
        NSStringToUtf8String(port),
        NSStringToUtf8String(password)));
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

- (BOOL)goToView:(CmusView)view withError:(NSError**)error {
  cmusclient::CmusClient::View client_view =
      cmusclient::CmusClient::View::LIBRARY;
  switch (view) {
    case CmusViewLibrary:
      client_view = cmusclient::CmusClient::View::LIBRARY;
      break;
    case CmusViewSortedLibrary:
      client_view = cmusclient::CmusClient::View::SORTED_LIBRARY;
      break;
    case CmusViewPlaylist:
      client_view = cmusclient::CmusClient::View::PLAYLIST;
      break;
    case CmusViewPlayQueue:
      client_view = cmusclient::CmusClient::View::PLAY_QUEUE;
      break;
    case CmusViewFilters:
      client_view = cmusclient::CmusClient::View::FILTERS;
      break;
    case CmusViewBrowser:
      client_view = cmusclient::CmusClient::View::BROWSER;
      break;
    case CmusViewSettings:
      client_view = cmusclient::CmusClient::View::SETTINGS;
      break;
    default:
      assert(false);
      break;
  }
  return TryBlock(^{
    _client->GoToView(client_view);
  }, error);
}

- (NSArray<CmusMetadata*>*)getListFromSource:(CmusListSource)source
                                       error:(NSError**)error {
  cmusclient::CmusClient::MetadataListSource client_source =
      cmusclient::CmusClient::MetadataListSource::LIBRARY;
  switch (source) {
    case CmusListSourceLibrary:
      client_source = cmusclient::CmusClient::MetadataListSource::LIBRARY;
      break;
    case CmusListSourceFilteredLibrary:
      client_source = cmusclient::CmusClient::MetadataListSource::FILTERED_LIBRARY;
      break;
    case CmusListSourcePlaylist:
      client_source = cmusclient::CmusClient::MetadataListSource::PLAYLIST;
      break;
    case CmusListSourceQueue:
      client_source = cmusclient::CmusClient::MetadataListSource::QUEUE;
      break;
    default:
      assert(false);
  }

  try {
    auto result = _client->GetMetadataList(client_source);
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
    _client->Search(NSStringToUtf8String(str));
  }, error);
}

- (BOOL)activateWithError:(NSError**)error {
  return TryBlock(^{
    _client->Activate();
  }, error);
}

@end
