//
//  KDBManager.h
//  Clanunity
//
//  Created by wangyadong on 2018/2/2.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface KDBManager : NSObject

@property(nonatomic,strong) FMDatabaseQueue *queue;

+(instancetype)shareManager;



// 删除表
- (BOOL) deleteTable:(NSString *)tableName withDB:(FMDatabase*)db;
// 创建表
- (BOOL) createTable:(NSString *)tableName withArguments:(NSString *)arguments;
// 清除表数据
- (BOOL) clearDateWithDB:(FMDatabase*)db table:(NSString *)tableName;
/** 判断表是否存在 */
-(BOOL)judgeExistTable:(NSString*)tabname;



@end
