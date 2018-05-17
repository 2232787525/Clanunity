//
//  ChinaCityModel.h
//  Clanunity
//
//  Created by wangyadong on 2018/2/2.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDBManager.h"

@interface ChinaCityModel : NSObject

@property(nonatomic,assign)NSInteger  id;
@property(nonatomic,copy)NSString * _Nonnull areaname;
@property(nonatomic,assign)NSInteger level;
@property(nonatomic,assign)NSInteger parentid;

+(ChinaCityModel*_Nonnull)preventemptyPropertyForModel:(ChinaCityModel*_Nonnull)model;

+(NSArray<ChinaCityModel*>*_Nullable)searchDataWhere:(NSDictionary<NSString*,id>*_Nullable)infoDictionary;
+(BOOL)insertWithModels:(NSArray<ChinaCityModel*>*_Nonnull)models;
+(BOOL)insertModel:(ChinaCityModel*_Nullable)model;

@end



//{
//    aps =     {
//        alert = bbbbbb;
//    };
//    d = umsncwf152265496319200;
//    id = 111;
//    p = 0;
//    type = 1;系统消息  2 动态消息
//}

@interface NoticeModel : NSObject

@property(nonatomic,copy)NSString * d;
@property(nonatomic,copy)NSString * id;
@property(nonatomic,copy)NSString * alert;
@property(nonatomic,copy)NSString * username;
@property(nonatomic,assign)NSInteger type;   // 1 系统消息  2 动态消息
@property(nonatomic,copy)NSString * date;   // 1 系统消息  2 动态消息


//@property(nonatomic,assign)NSInteger parentid;

+(NoticeModel*_Nonnull)preventemptyPropertyForModel:(NoticeModel*_Nonnull)model;

//获取表中所有的数据
+(NSArray<NoticeModel *> *)getData;


+(NSArray<NoticeModel*>*_Nullable)searchDataWhere:(NSDictionary<NSString*,id>*_Nullable)infoDictionary;

//TODO:按条件搜索
+(NSArray<NoticeModel*>*_Nullable)searchDataOrWhere:(NSDictionary<NSString*,id>*_Nullable)infoDictionary;


+(BOOL)insertWithModels:(NSArray<NoticeModel*>*_Nonnull)models;
+(BOOL)insertModel:(NoticeModel*_Nullable)model;

//根据主键删除这条数据
+(BOOL)deleteTableWithDB:(FMDatabase*)db primaryKeyId:(NSString *)date;

@end
