#import <Foundation/Foundation.h>
#import "MTTBaseEntity.h"

enum
{
    GROUP_TYPE_FIXED = 1,       //固定群
    GROUP_TYPE_TEMPORARY,       //临时群
};

typedef enum : NSUInteger {
    CenterGroupItemTypeNormal = 0,
    CenterGroupItemTypeMore = 1,
    CenterGroupItemTypeCreate = 2,
} CenterGroupItemType;

@class GroupInfo;

@interface MTTGroupEntity : MTTBaseEntity

//---------

/**
 0群，1更多，2新增
 */
@property(nonatomic,assign)CenterGroupItemType type;

/**
 公告
 */
@property(nonatomic,copy)NSString * _Nullable notice;
/**
 使用users数组配置成的头像url数组
 */
@property(nonatomic,strong)NSArray<NSString*> *_Nullable imgArray;
/**
 创建，群主的id
 */
@property(nonatomic,assign)NSInteger tuserid;

/**
 我们自己用户id
 */
@property(nonatomic,copy)NSString * _Nullable userid;
/**
 群id 数字
 */
@property(nonatomic,assign)NSInteger id;
@property(nonatomic,strong)NSArray<MTTUserEntity*> * _Nullable users;




//----------
@property(nonatomic,copy) NSString * _Nullable groupCreatorId;        //群创建者ID

/**
 群类型1固定群，2临时群
 */
@property(nonatomic,assign) int groupType;
@property(nonatomic,strong) NSString*_Nullable name;                  //群名称
@property(nonatomic,strong) NSString*_Nullable avatar;                //群头像
@property(nonatomic,strong) NSMutableArray*_Nullable groupUserIds;    //群用户列表ids
@property(nonatomic,readonly)NSMutableArray*_Nullable fixGroupUserIds;//固定的群用户列表IDS，用户生成群头像
@property(strong)NSString *_Nullable lastMsg;
@property(assign)BOOL isShield;
-(void)copyContent:(MTTGroupEntity*_Nonnull)entity;
+(NSInteger)localGroupIDTopb:(NSString *_Nullable)groupID;
+(NSString *_Nullable)pbGroupIdToLocalID:(NSInteger)groupID;
- (void)addFixOrderGroupUserIDS:(NSString*_Nullable)ID;
+(MTTGroupEntity *_Nullable)dicToMTTGroupEntity:(NSDictionary *_Nullable)dic;
+(NSString *_Nullable)getSessionId:(NSString *_Nullable)groupId;
+(MTTGroupEntity *_Nullable)initMTTGroupEntityFromPBData:(GroupInfo *_Nullable)groupInfo;

@end
