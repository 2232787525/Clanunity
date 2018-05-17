//
//  KDBManager.m
//  Clanunity
//
//  Created by wangyadong on 2018/2/2.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KDBManager.h"


static KDBManager *manager = nil;

@implementation KDBManager


+(instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KDBManager alloc] init];
    });
    return manager;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        //创建队列
        self.queue = [FMDatabaseQueue databaseQueueWithPath:[self dbPathByString:nil]];
    }
    return self;
}



/** 判断表存在的sql语句 */
- (NSString *)judgeTableHaveSQL{
    NSString *sqlString = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?"];
    return sqlString;
}
/** 判断表是否存在 */
-(BOOL)judgeExistTable:(NSString*)tabname{
    __block BOOL res = YES;
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *tableName = tabname;
        //不包含则 更新表 或者 创建表
        NSString *tableHaveSQLString = [self judgeTableHaveSQL];
        FMResultSet *rs = [db executeQuery:tableHaveSQLString,tableName];
        BOOL isCreate = NO;
        while ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            if (count != 0) isCreate = YES;
        }
        res = isCreate;
    }];
    return res;
}

// 删除表
- (BOOL) deleteTable:(NSString *)tableName withDB:(FMDatabase*)db
{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    BOOL res = YES;
    if (![db executeUpdate:sqlstr]) {
        res = NO;
    }
    return res;
}
// 创建表
- (BOOL) createTable:(NSString *)tableName withArguments:(NSString *)arguments
{
    __block BOOL res = YES;
    NSString *sqlstr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@)", tableName, arguments];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        if (![db executeUpdate:sqlstr]) {
            NSLog(@"创建表失败");
            res = NO;
        }
    }];
    return res;
    
}

// 清除表数据
- (BOOL) clearDateWithDB:(FMDatabase*)db table:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    BOOL res = YES;
    if (![db executeUpdate:sqlstr]) {
        res = NO;//清除数据失败
    }
    return res;
}

/**
 * dbPathByString 根据名称生成数据库的路径
 * tableNameByModelClass 根据class生成表名
 */
- (NSString *)dbPathByString:(NSString *)sqlLibraryName{
    NSString *pathString = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接document
    NSFileManager *filemanage = [NSFileManager defaultManager];
    pathString = [pathString stringByAppendingPathComponent:@"DBFolder"];//用公司名比较好
    BOOL isDir;
    BOOL exit =[filemanage fileExistsAtPath:pathString isDirectory:&isDir];
    BOOL success = false;
    if (!exit || !isDir) {
        success = [filemanage createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbpath = nil;
    if (sqlLibraryName == nil || sqlLibraryName.length == 0) {
        dbpath = [pathString stringByAppendingPathComponent:@"fmdb.sqlite"];
    } else {
        dbpath = [pathString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",sqlLibraryName]];
    }
    return dbpath;
}




@end
