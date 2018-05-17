//
//  DDBaseEntity.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-16.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "KBaseModel.h"
@interface MTTBaseEntity : KBaseModel
@property(assign)long lastUpdateTime;

/**
 格式就是 user_12/group_group_11
 */
@property(copy)NSString *objID;
@property(assign)NSInteger objectVersion;
-(NSUInteger)getOriginalID;
@end
