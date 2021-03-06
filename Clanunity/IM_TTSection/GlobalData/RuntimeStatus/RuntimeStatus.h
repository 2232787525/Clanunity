//
//  RuntimeStatus.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-31.
//  Copyright (c) 2014 dujia. All rights reserved.
//


#import <Foundation/Foundation.h>

#define TheRuntime [RuntimeStatus instance]

@class MTTUserEntity;

@interface RuntimeStatus : NSObject
@property(nonatomic,assign)BOOL loginSuccess;
@property(nonatomic,strong)MTTUserEntity *user;
@property(nonatomic,copy)NSString *token;
@property(nonatomic,copy)NSString *userID;

@property(nonatomic,copy)NSString *pushToken;

+ (instancetype)instance;

/**
 更新各个模块，登录成功后操作
 */
-(void)updateData;

@end
