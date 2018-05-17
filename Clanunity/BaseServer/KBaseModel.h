//
//  KBaseModel.h
//  Clanunity
//
//  Created by wangyadong on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBaseModel : NSObject

@property(nonatomic,strong)NSDictionary * _Nullable replacePropertys;

-(instancetype _Nonnull )initWithDic:(NSDictionary*_Nullable)dic;

-(void)setValue:(id _Nullable )value forUndefinedKey:(NSString *_Nullable)key;


@end



@interface KFriendModel : KBaseModel

/**
 名称
 */
@property(nonatomic,copy)NSString * _Nullable nickname;

@property(nonatomic,copy)NSString *_Nullable username;

/**
 头像
 */
@property(nonatomic,copy)NSString * _Nullable headimg;

/**
 用户id
 */
@property(nonatomic,copy)NSString * _Nonnull user_id;

/**
 性别 0女，1男
 */
@property(nonatomic,assign)NSInteger gender;

@end;
