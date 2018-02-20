//
//  CmusStatus+ObjCpp.h
//  CmusRemote
//
//  Created by Yuwei Huang on 2/21/18.
//  Copyright © 2018 Yuwei Huang. All rights reserved.
//

@interface CmusStatus(ObjCpp)
-(instancetype)initWithStatus:(const cmusclient::Status&)status;
@end

@interface CmusMetadata(ObjCpp)

- (instancetype)initWithMetadata:(const cmusclient::Metadata&)metadata;

+ (NSArray<CmusMetadata*>*)convertFromMetadataList:
    (const std::vector<cmusclient::Metadata>&)list;

@end
