//
//  DDChatImageCell.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-06-09.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDChatBaseCell.h"
#import "MWPhotoBrowser.h"

typedef void(^DDPreview)(void);
typedef void(^DDTapPreview)(void);
@interface DDChatImageCell : DDChatBaseCell<DDChatCellProtocol>
@property(nonatomic,strong)UIImageView *msgImgView;
@property(nonatomic,strong)NSMutableArray *photos;
@property(nonatomic,strong)DDPreview preview;
-(void)showPreview:(NSMutableArray*)photos index:(NSInteger)index;
- (void)sendImageAgain:(MTTMessageEntity*)message;
@end
