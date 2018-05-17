//
//  ResourcesModel.m
//  PalmLive
//
//  Created by wangyadong on 2018/1/12.
//  Copyright © 2018年 zfy_srf. All rights reserved.
//

#import "ResourcesModel.h"
#import "KDBManager.h"
NSString *const ResureTableNameKey = @"ResureTable";

@implementation ResourcesModel

+(ResourcesModel *)preventemptyPropertyForModel:(ResourcesModel *)model{
    model.img_title = [ResourcesModel preventEmpty:model.img_title];
    model.created = [ResourcesModel preventEmpty:model.created];
    model.img_go = [ResourcesModel preventEmpty:model.img_go];
    model.img_app = [ResourcesModel preventEmpty:model.img_app];
    model.img_url = [ResourcesModel preventEmpty:model.img_url];
    model.img_type = [ResourcesModel preventEmpty:model.img_type];
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

+(NSArray<ResourcesModel *> *)searchDataWithTable:(NSString *)tableName{
    
    NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
   
    [ [KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from %@",tableName]];
        while ([resultSet next]) {
            ResourcesModel *model = [[ResourcesModel alloc] init];
            model.id = [resultSet intForColumn:@"id"];
            model.img_version = [resultSet intForColumn:@"img_version"];
            model.created = [resultSet stringForColumn:@"created"];
            model.img_app = [resultSet stringForColumn:@"img_app"];
            model.img_go = [resultSet stringForColumn:@"img_go"];
            model.img_title = [resultSet stringForColumn:@"img_title"];
            model.img_url = [resultSet stringForColumn:@"img_url"];
            model.img_type = [resultSet stringForColumn:@"img_type"];
            [cacheModels addObject:model];
        }
    }];
    return cacheModels;
}
+(NSArray<ResourcesModel*>*)searchDataWhere:(NSDictionary*)infoDictionary{
    
    NSString *resultSql = @"";
    NSMutableString *sqlString = [NSMutableString string];
    NSArray *proNamesArray = infoDictionary.allKeys;
    
    //查找全部
    if (!infoDictionary) {
        resultSql = [NSString stringWithFormat:@"SELECT * FROM %@",ResureTableNameKey];
    }else{
        //条件查询
        for (int i = 0; i<proNamesArray.count; i++) {
            NSString *proname = proNamesArray[i];
            id provalue = infoDictionary[proname];
            if ([[provalue class] isSubclassOfClass:[NSString class]]) {
                [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@='%@'",ResureTableNameKey, proname,provalue];
            }else{
                [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@=%@",ResureTableNameKey, proname,provalue];
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
            ResourcesModel *model = [[ResourcesModel alloc] init];
            model.id = [resultSet intForColumn:@"id"];
            model.img_version = [resultSet intForColumn:@"img_version"];
            model.created = [resultSet stringForColumn:@"created"];
            model.img_app = [resultSet stringForColumn:@"img_app"];
            model.img_go = [resultSet stringForColumn:@"img_go"];
            model.img_title = [resultSet stringForColumn:@"img_title"];
            model.img_url = [resultSet stringForColumn:@"img_url"];
            model.img_type = [resultSet stringForColumn:@"img_type"];
            [cacheModels addObject:model];
        }
    }];
    return cacheModels;
}


+(BOOL)insertWithModels:(NSArray<ResourcesModel*>*)models{
    NSMutableArray *cacheModels = [NSMutableArray arrayWithCapacity:0];
    for (ResourcesModel *model in models) {
        [cacheModels addObject:[ResourcesModel preventemptyPropertyForModel:model]];
    }
    //判断表是否存在
    if (![[KDBManager shareManager] judgeExistTable:ResureTableNameKey]) {
        //不存在穿件表
        if(![[KDBManager shareManager] createTable:ResureTableNameKey withArguments:@"id INTEGER primary key,img_title TEXT,img_version INTEGER,img_app TEXT,img_url TEXT,img_go TEXT,created TEXT,img_type TEXT"]){
            //创建表失败，插入失败
            return NO;
        }
    };
    __block BOOL res = NO;
    __weak typeof(self) weakSelf = self;
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if ([db open]) {
            //先清除这个表中的数据
            if ([[KDBManager shareManager] clearDateWithDB:db table:ResureTableNameKey]) {
                for (ResourcesModel *model in cacheModels) {
                    [weakSelf insertTableWithDB:db model:model];
                }
                res = YES;
            };
        }
    }];
    return res;
}
+(BOOL)insertModel:(ResourcesModel*)model{
    model = [ResourcesModel preventemptyPropertyForModel:model];
    //判断表是否存在
    if (![[KDBManager shareManager] judgeExistTable:ResureTableNameKey]) {
        //不存在穿件表
        if(![[KDBManager shareManager] createTable:ResureTableNameKey withArguments:@"id INTEGER primary key,img_title TEXT,img_version INTEGER,img_app TEXT,img_url TEXT,img_go TEXT,created TEXT,img_type TEXT"]){
            //创建表失败，插入失败
            return NO;
        }
    };
    __block BOOL res = NO;
    __weak typeof(self) weakSelf = self;
    
    [[KDBManager shareManager].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if ([db open]) {
            //不存在就insert
            BOOL canInsert = YES;
            if ([ResourcesModel isExistWithDB:db primaryKeyId: model.id]) {
                //存在这条数据，那么删除
                canInsert = NO;
                if ([ResourcesModel deleteTableWithDB:db primaryKeyId:model.id]) {
                    NSLog(@"存在 --> 删除成功");
                    canInsert = YES;
                }
            }
            if (canInsert) {
                res = [weakSelf insertTableWithDB:db model:model];
            }
        }
    }];
    return res;
}
//判断是否这条数据是否已经存在
+(BOOL)isExistWithDB:(FMDatabase*)db primaryKeyId:(NSInteger)primaryid{
    BOOL exist = NO;
    FMResultSet *resultSet = [db executeQuery:@"select * from ResureTable where id = ?",@(primaryid)];
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
    return [db executeUpdate:@"delete from ResureTable where id = ?",@(primaryid)];
}
//插入数据
-(BOOL)insertTableWithDB:(FMDatabase*)db model:(ResourcesModel*)model{
    return [db executeUpdate:@"insert into ResureTable (id,img_title,img_version,img_app,img_url,img_go,created,img_type) values (?,?,?,?,?,?,?,?)",@(model.id),model.img_title,@(model.img_version),model.img_app,model.img_url,model.img_go,model.created,model.img_type];
}




@end
