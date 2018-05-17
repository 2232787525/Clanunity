//
//  DDDDChatUtilityViewController.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "KBaseClanViewController.h"
@interface ChatUtilityViewController : KBaseClanViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic) NSInteger userId;
-(void)setShakeHidden;
@end
