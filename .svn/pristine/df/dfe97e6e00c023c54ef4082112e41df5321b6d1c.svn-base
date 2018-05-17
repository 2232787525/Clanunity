//
//  SelectedUserVC.h
//  Clanunity
//
//  Created by wangyadong on 2018/3/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KBaseClanViewController.h"

@interface SelectedUserVC : KBaseClanViewController

/**
 33删除，11新增
 */
@property(nonatomic,assign)NSInteger type;

/**
 原始数据
 */
@property(nonatomic,strong)MTTGroupEntity * _Nullable groupEntity;
@property(nonatomic,strong)NSArray<MTTUserEntity*> *_Nullable groupArray;
@property(nonatomic,copy)NSString * _Nonnull groupid;
@property(nonatomic,copy)void(^ _Nullable resultBlock)(BOOL isadd,NSArray<MTTUserEntity*> * _Nullable members);
@end
