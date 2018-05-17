//
//  MyChatViewController.h
//  Clanunity
//
//  Created by wangyadong on 2018/4/18.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KBaseClanViewController.h"
@class MyChatInput;
@interface MyChatViewController : KBaseClanViewController

@end



@interface MyChatInput : UIView<UITextFieldDelegate>
@property(nonatomic,strong)UITextField *textfild;
@property(nonatomic,copy)void(^textReturn)(NSString*text);
+(MyChatInput*)showInoutView;
@end
