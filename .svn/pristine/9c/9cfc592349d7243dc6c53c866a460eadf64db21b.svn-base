//
//  ChinaCityModel.m
//  Clanunity
//
//  Created by wangyadong on 2018/2/2.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "ChinaCityModel.h"
@implementation ChinaCityModel

+(NSString*)tableName{
    return @"ChinaCityModel";
}



+(ChinaCityModel *)preventemptyPropertyForModel:(ChinaCityModel *)model{
    model.areaname = [ChinaCityModel preventEmpty:model.areaname];
    return model;
}
+(NSString*)preventEmpty:(NSString*)par{
    if (par == nil||par.length==0) {
        return @"";
    }else{
        return par;
    }
}


#pragma mark - 数据库操作

+(NSArray<ChinaCityModel *> *)searchDataWithTable:(NSString *)tableName{
    
    __block NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    
    [ [KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from %@",tableName]];
        while ([resultSet next]) {
            ChinaCityModel *model = [[ChinaCityModel alloc] init];
            model.id = [resultSet intForColumn:@"id"];
            model.parentid = [resultSet intForColumn:@"parentid"];
            model.level = [resultSet intForColumn:@"level"];
            model.areaname = [resultSet stringForColumn:@"areaname"];
            [cacheModels addObject:model];
        }
    }];
    return cacheModels;
}
+(NSArray<ChinaCityModel*>*)searchDataWhere:(NSDictionary*)infoDictionary{
    
    NSString *resultSql = @"";
    NSMutableString *sqlString = [NSMutableString string];
    NSArray *proNamesArray = infoDictionary.allKeys;
    
    //查找全部
    if (!infoDictionary) {
        resultSql = [NSString stringWithFormat:@"SELECT * FROM %@",[ChinaCityModel tableName]];
    }else{
        //条件查询
        for (int i = 0; i<proNamesArray.count; i++) {
            NSString *proname = proNamesArray[i];
            id provalue = infoDictionary[proname];
            if ([[provalue class] isSubclassOfClass:[NSString class]]) {
                [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@='%@'",[ChinaCityModel tableName], proname,provalue];
            }else{
                [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@=%@",[ChinaCityModel tableName], proname,provalue];
            }
            if(i+1 != proNamesArray.count)
            {
                [sqlString appendString:@","];
            }
        }
        resultSql = sqlString;
    }
    NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *resultSet = [db executeQuery:resultSql];
        while ([resultSet next]) {
            ChinaCityModel *model = [[ChinaCityModel alloc] init];
            model.id = [resultSet intForColumn:@"id"];
            model.parentid = [resultSet intForColumn:@"parentid"];
            model.level = [resultSet intForColumn:@"level"];
            model.areaname = [resultSet stringForColumn:@"areaname"];
            [cacheModels addObject:model];
        }
    }];
    return cacheModels;
}


+(BOOL)insertWithModels:(NSArray<ChinaCityModel*>*)models{
    __block NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    for (ChinaCityModel *model in models) {
        [cacheModels addObject:[ChinaCityModel preventemptyPropertyForModel:model]];
    }
    //判断表是否存在
    if (![[KDBManager shareManager] judgeExistTable:[ChinaCityModel tableName]]) {
        //不存在创建表
        if(![[KDBManager shareManager] createTable:[ChinaCityModel tableName] withArguments:@"id INTEGER primary key,parentid INTEGER,level INTEGER,areaname TEXT"]){
            //创建表失败，插入失败
            return NO;
        }
    };
    __block BOOL res = NO;
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if ([db open]) {
            //先清除这个表中的数据
            if ([[KDBManager shareManager] clearDateWithDB:db table:[ChinaCityModel tableName]]) {
                for (ChinaCityModel *model in cacheModels) {
                    [ChinaCityModel insertTableWithDB:db model:model];
                }
                res = YES;
            };
        }
    }];
    return res;
}
+(BOOL)insertModel:(ChinaCityModel*)model{
    model = [ChinaCityModel preventemptyPropertyForModel:model];
    //判断表是否存在
    if (![[KDBManager shareManager] judgeExistTable:[ChinaCityModel tableName]]) {
        //不存在穿件表
        if(![[KDBManager shareManager] createTable:[ChinaCityModel tableName] withArguments:@"id INTEGER primary key,parentid INTEGER,level INTEGER,areaname TEXT"]){
            //创建表失败，插入失败
            return NO;
        }
    };
    __block BOOL res = NO;
    
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if ([db open]) {
            //不存在就insert
            BOOL canInsert = YES;
            if ([ChinaCityModel isExistWithDB:db primaryKeyId: model.id]) {
                //存在这条数据，那么删除
                canInsert = NO;
                if ([ChinaCityModel deleteTableWithDB:db primaryKeyId:model.id]) {
                    NSLog(@"存在 --> 删除成功");
                    canInsert = YES;
                }
            }
            if (canInsert) {
                res = [ChinaCityModel insertTableWithDB:db model:model];
            }
        }
    }];
    return res;
}
//判断是否这条数据是否已经存在
+(BOOL)isExistWithDB:(FMDatabase*)db primaryKeyId:(NSInteger)primaryid{
    __block BOOL exist = NO;
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where id = ?",[ChinaCityModel tableName]],@(primaryid)];
    while ([resultSet next]) {
        NSInteger departID = [resultSet intForColumn:@"id"];
        if (departID == primaryid) {
            exist = YES;
        }
    }
    return exist;
}
//根据主键删除这条数据
+(BOOL)deleteTableWithDB:(FMDatabase*)db primaryKeyId:(NSInteger)primaryid{
    return [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where id = ?",[ChinaCityModel tableName]],@(primaryid)];
}
//插入数据
+(BOOL)insertTableWithDB:(FMDatabase*)db model:(ChinaCityModel*)model{
    return [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (id,areaname,level,parentid) values (?,?,?,?)",[ChinaCityModel tableName]],@(model.id),model.areaname,@(model.level),@(model.parentid)];
}
@end






@implementation NoticeModel

+(NSString*)tableName{
    return @"NoticeModel";
}

+(NoticeModel *)preventemptyPropertyForModel:(NoticeModel *)model{
//    model.alert = [NoticeModel preventEmpty:model.alert];
//    model.date = [NoticeModel preventEmpty:model.date];

    return model;
}

+(NSString*)preventEmpty:(NSString*)par{
    if (par == nil||par.length==0) {
        return @"";
    }else{
        return par;
    }
}


#pragma mark - 数据库操作

//TODO:获取表中所有数据
+(NSArray<NoticeModel *> *)getData{
    
    NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    
    [ [KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from %@",[NoticeModel tableName]]];
        while ([resultSet next]) {
            NoticeModel *model = [[NoticeModel alloc] init];
            model.d = [resultSet stringForColumn:@"d"];
            model.id = [resultSet stringForColumn:@"id"];
            model.alert = [resultSet stringForColumn:@"alert"];
            model.date = [resultSet stringForColumn:@"date"];

            model.type = [resultSet intForColumn:@"type"];
            [cacheModels addObject:model];
        }
    }];
    return cacheModels;
}

//TODO:按条件搜索
+(NSArray<NoticeModel*>*)searchDataWhere:(NSDictionary*)infoDictionary{
    
    NSString *resultSql = @"";
    NSMutableString *sqlString = [NSMutableString string];
    NSArray *proNamesArray = infoDictionary.allKeys;
    
    //查找全部
    if (!infoDictionary) {
        resultSql = [NSString stringWithFormat:@"SELECT * FROM %@",[NoticeModel tableName]];
    }else{
        //条件查询
        for (int i = 0; i<proNamesArray.count; i++) {
            NSString *proname = proNamesArray[i];
            id provalue = infoDictionary[proname];
            if ([[provalue class] isSubclassOfClass:[NSString class]]) {
                [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@='%@'",[NoticeModel tableName], proname,provalue];
            }else{
                [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@=%@",[NoticeModel tableName], proname,provalue];
            }
            if(i+1 != proNamesArray.count)
            {
                [sqlString appendString:@","];
            }
        }
        resultSql = sqlString;
    }
    NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *resultSet = [db executeQuery:resultSql];
        while ([resultSet next]) {
            NoticeModel *model = [[NoticeModel alloc] init];
            model.d = [resultSet stringForColumn:@"d"];
            model.id = [resultSet stringForColumn:@"id"];
            model.alert = [resultSet stringForColumn:@"alert"];
            model.date = [resultSet stringForColumn:@"date"];
            model.type = [resultSet intForColumn:@"type"];
            [cacheModels addObject:model];
        }
    }];
    return cacheModels;
}

//TODO:按条件搜索
+(NSArray<NoticeModel*>*)searchDataOrWhere:(NSDictionary*)infoDictionary{
    
    NSString *resultSql = @"";
    NSMutableString *sqlString = [NSMutableString string];
    NSArray *proNamesArray = infoDictionary.allKeys;
    
    //查找全部
    if (!infoDictionary) {
        resultSql = [NSString stringWithFormat:@"SELECT * FROM %@",[NoticeModel tableName]];
    }else{
        //条件查询
        for (int i = 0; i<proNamesArray.count; i++) {
            NSString *proname = proNamesArray[i];
            id provalue = infoDictionary[proname];
            if ([[provalue class] isSubclassOfClass:[NSString class]]) {
                if (i == 0){
                    [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@='%@'",[NoticeModel tableName], proname,provalue];
                }else{
                    [sqlString appendFormat:@" or %@='%@'", proname,provalue];
                }
                
            }else{
                if (i == 0){
                    [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@=%@",[NoticeModel tableName], proname,provalue];
                }else{
                    [sqlString appendFormat:@" or %@=%@", proname,provalue];
                }
            }
            if(i+1 != proNamesArray.count)
            {
                [sqlString appendString:@""];
            }
        }
        resultSql = sqlString;
    }
    NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *resultSet = [db executeQuery:resultSql];
        while ([resultSet next]) {
            NoticeModel *model = [[NoticeModel alloc] init];
            model.d = [resultSet stringForColumn:@"d"];
            model.id = [resultSet stringForColumn:@"id"];
            model.alert = [resultSet stringForColumn:@"alert"];
            model.date = [resultSet stringForColumn:@"date"];
            model.type = [resultSet intForColumn:@"type"];
            [cacheModels addObject:model];
        }
    }];
    return cacheModels;
}

//TODO:插入多条数据
+(BOOL)insertWithModels:(NSArray<NoticeModel*>*)models{
    NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    for (NoticeModel *model in models) {
        [cacheModels addObject:[NoticeModel preventemptyPropertyForModel:model]];
    }
    //判断表是否存在
    if (![[KDBManager shareManager] judgeExistTable:[NoticeModel tableName]]) {
        //不存在创建表
        if(![[KDBManager shareManager] createTable:[NoticeModel tableName] withArguments:@"d TEXT primary key,date TEXT,id TEXT,type TEXT,alert TEXT , username TEXT"]){
            //创建表失败，插入失败
            return NO;
        }
    };
    __block BOOL res = NO;
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if ([db open]) {
            //先清除这个表中的数据
            if ([[KDBManager shareManager] clearDateWithDB:db table:[NoticeModel tableName]]) {
                for (NoticeModel *model in cacheModels) {
                    [NoticeModel insertTableWithDB:db model:model];
                }
                res = YES;
            };
        }
    }];
    return res;
}

//TODO:插入一条数据
+(BOOL)insertModel:(NoticeModel*)model{
    model = [NoticeModel preventemptyPropertyForModel:model];
    //判断表是否存在
    if (![[KDBManager shareManager] judgeExistTable:[NoticeModel tableName]]) {
        //不存在穿件表
        if(![[KDBManager shareManager] createTable:[NoticeModel tableName] withArguments:@"d TEXT primary key,date TEXT,id TEXT,type INT,alert TEXT,username TEXT"]){
            //创建表失败，插入失败
            return NO;
        }
    };
    __block BOOL res = NO;
    
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if ([db open]) {
            //不存在就insert
            BOOL canInsert = YES;
            if ([NoticeModel isExistWithDB:db primaryKeyId: model.d]) {
                //存在这条数据，那么删除
                canInsert = NO;
                if ([NoticeModel deleteTableWithDB:db primaryKeyId:model.d]) {
                    NSLog(@"存在 --> 删除成功");
                    canInsert = YES;
                }
            }
            if (canInsert) {
                res = [NoticeModel insertTableWithDB:db model:model];
            }
        }
    }];
    return res;
}

//TODO:判断是否这条数据是否已经存在
+(BOOL)isExistWithDB:(FMDatabase*)db primaryKeyId:(NSString *)d{
    BOOL exist = NO;
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where d = ?",[NoticeModel tableName]],d];
    while ([resultSet next]) {
        NSString * departID = [resultSet stringForColumn:@"d"];
        if ([departID isEqualToString:d]) {
            exist = YES;
        }
    }
    return exist;
}

//TODO:根据主键删除这条数据
+(BOOL)deleteTableWithDB:(FMDatabase*)db primaryKeyId:(NSString *)d{
    return [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where d = ?",[NoticeModel tableName]],d];
}

//插入数据
+(BOOL)insertTableWithDB:(FMDatabase*)db model:(NoticeModel*)model{
    return [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (d,date,id,type,alert,username) values (?,?,?,?,?,?)",[NoticeModel tableName]],model.d,model.date,model.id,@(model.type),model.alert,model.username];
}
@end
