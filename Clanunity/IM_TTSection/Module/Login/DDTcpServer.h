//
//  DDTcpServer.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ClientSuccess)(void);
typedef void(^ClientFailure)(NSError* error);

@interface DDTcpServer : NSObject

- (void)loginTcpServerIP:(NSString*)ip port:(NSInteger)point Success:(ClientSuccess)success failure:(ClientFailure)failure;

@end
