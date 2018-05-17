//
//  KBaseModel.m
//  Clanunity
//
//  Created by wangyadong on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KBaseModel.h"

@implementation KBaseModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    self =[super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    
    return self;
    
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
-(void)setNilValueForKey:(NSString *)key{
    NSLog(@"%@",key);
}
@end


@implementation KFriendModel

@end;
