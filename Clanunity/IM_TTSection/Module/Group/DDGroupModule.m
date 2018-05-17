//
//  DDGroupModule.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-11.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDGroupModule.h"
#import "RuntimeStatus.h"
#import "GetGroupInfoAPi.h"
#import "DDReceiveGroupAddMemberAPI.h"
#import "MTTDatabaseUtil.h"
#import "MTTNotification.h"
#import "NSDictionary+Safe.h"
@implementation DDGroupModule
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allGroups = [NSMutableDictionary new];
        [[MTTDatabaseUtil instance] loadGroupsCompletion:^(NSArray *contacts, NSError *error) {
            //获取到数据库中缓存的 所有我的群组
            [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MTTGroupEntity *group = (MTTGroupEntity *)obj;
                if(group.objID)
                {
                    [self addGroup:group];//保存到磁盘
                    
                    //请求群组详细信息
                    GetGroupInfoAPI* request = [[GetGroupInfoAPI alloc] init];
                    NSLog(@"%@==>%@",group.objID,request);//group.objectVersion
                    [request requestWithObject:@[@([MTTUtil changeIDToOriginal:group.objID]),@(0)] Completion:^(id response, NSError *error) {
                        if (!error)
                        {
                            
                            if ([(NSArray*)response count]) {
                                MTTGroupEntity* group = (MTTGroupEntity*)response[0];
                                if (group)
                                {
                                    
                                    [self addGroup:group];
                                    //更新数据库中的信息
                                    NSLog(@"DDGroupModule init : name%@,type:%u,ID:%@",group.name,group.groupType,group.objID);
                                    [[MTTDatabaseUtil instance] updateRecentGroup:group completion:^(NSError *error) {
                                        DDLog(@"insert group to database error.");
                                    }];
                                }
                            }
                            
                        }
                    }];
                }
            }];
        }];
        [self registerAPI];
    }
    return self;
}

+ (instancetype)instance
{
    static DDGroupModule* group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = [[DDGroupModule alloc] init];
        
    });
    return group;
}
-(void)getGroupFromDB
{
    
}

/**
 在字典中缓存 _allGroups ；key：group_id ,value:group对象

 @param newGroup 群组对象
 */
-(void)addGroup:(MTTGroupEntity*)newGroup
{
    if (!newGroup)
    {
        return;
    }
    MTTGroupEntity* group = newGroup;
    [_allGroups setObject:group forKey:group.objID];
    newGroup = nil;
}
-(NSArray*)getAllGroups
{
    return [_allGroups allValues];
}
-(MTTGroupEntity*)getGroupByGId:(NSString*)gId
{
    
    MTTGroupEntity *entity= [_allGroups safeObjectForKey:gId];
  
    return entity;
}

- (void)getGroupInfogroupID:(NSString*)groupID completion:(GetGroupInfoCompletion)completion
{
    
    MTTGroupEntity *group = [self getGroupByGId:groupID];
    if (group) {
        completion(group);
    }else{
        GetGroupInfoAPI* request = [[GetGroupInfoAPI alloc] init];
        NSLog(@"%@==>%@",groupID,request);
        [request requestWithObject:@[@([MTTUtil changeIDToOriginal:groupID]),@(group.objectVersion)] Completion:^(id response, NSError *error) {
            if (!error){
                if ([(NSArray*)response count]) {
                    MTTGroupEntity* group = (MTTGroupEntity*)response[0];
                    if (group){
                        [self addGroup:group];
                        [[MTTDatabaseUtil instance] updateRecentGroup:group completion:^(NSError *error) {
                            DDLog(@"insert group to database error.");
                        }];
                    }
                    completion(group);
                }
                
            }
        }];
    }
    
}

-(BOOL)isContainGroup:(NSString*)gId
{
    return ([_allGroups valueForKey:gId] != nil);
}

- (void)registerAPI
{
    
    DDReceiveGroupAddMemberAPI* addmemberAPI = [[DDReceiveGroupAddMemberAPI alloc] init];
    [addmemberAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        if (!error)
        {
            
            MTTGroupEntity* groupEntity = (MTTGroupEntity*)object;
            if (!groupEntity)
            {
                return;
            }
            if ([self getGroupByGId:groupEntity.objID])
            {
                //自己本身就在组中
                
            }
            else
            {
                //自己被添加进组中
                
                groupEntity.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
                [[DDGroupModule instance] addGroup:groupEntity];
//                [self addGroup:MTTGroupEntity];
//                DDSessionModule* sessionModule = getDDSessionModule();
//                [sessionModule createGroupSession:MTTGroupEntity.groupId type:GROUP_TYPE_TEMPORARY];
                [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationRecentContactsUpdate object:nil];
            }
        }
        else
        {
            DDLog(@"error:%@",[error domain]);
        }
    }];
    
//    DDReceiveGroupDeleteMemberAPI* deleteMemberAPI = [[DDReceiveGroupDeleteMemberAPI alloc] init];
//    [deleteMemberAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
//        if (!error)
//        {
//            MTTGroupEntity* MTTGroupEntity = (MTTGroupEntity*)object;
//            if (!MTTGroupEntity)
//            {
//                return;
//            }
//            DDUserlistModule* userModule = getDDUserlistModule();
//            if ([MTTGroupEntity.groupUserIds containsObject:userModule.myUserId])
//            {
//                //别人被踢了
//                [[DDMainWindowController instance] updateCurrentChattingViewController];
//            }
//            else
//            {
//                //自己被踢了
//                [self.recentlyGroupIds removeObject:MTTGroupEntity.groupId];
//                DDSessionModule* sessionModule = getDDSessionModule();
//                [sessionModule.recentlySessionIds removeObject:MTTGroupEntity.groupId];
//                DDMessageModule* messageModule = getDDMessageModule();
//                [messageModule popArrayMessage:MTTGroupEntity.groupId];
//                [NotificationHelp postNotification:notificationReloadTheRecentContacts userInfo:nil object:nil];
//            }
//        }
//    }];
}


@end
