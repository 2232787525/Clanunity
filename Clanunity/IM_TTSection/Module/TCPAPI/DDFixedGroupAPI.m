//
//  DDFixedGroupAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-6.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import "DDFixedGroupAPI.h"
#import "MTTGroupEntity.h"
#import "IMGroup.pb.h"
@implementation DDFixedGroupAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return TimeOutTimeInterval;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return SID_GROUP;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return SID_GROUP;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return IM_NORMAL_GROUP_LIST_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return IM_NORMAL_GROUP_LIST_RES;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* object)
    {
     
        IMNormalGroupListRsp *imNormalRsp = [IMNormalGroupListRsp parseFromData:object];
        NSMutableArray *array = [NSMutableArray new];
        for (GroupVersionInfo *info in [imNormalRsp groupVersionList]) {
            NSDictionary *dic = @{@"groupid":@(info.groupId),@"version":@(info.version)};
            [array addObject:dic];
        }
        return  array;

    };
    return analysis;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        IMNormalGroupListReqBuilder *imnormal = [IMNormalGroupListReq builder];
        [imnormal setUserId:0];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_GROUP
                                    cId:IM_NORMAL_GROUP_LIST_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:imnormal.build.data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}
@end
