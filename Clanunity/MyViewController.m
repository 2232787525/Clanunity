//
//  MyViewController.m
//  Clanunity
//
//  Created by wangyadong on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "MyViewController.h"
#import <SCLAlertView_Objective_C/SCLAlertView.h>
//#import "LoginModule.h"
//#import "SendPushTokenAPI.h"
//#import "MTTRootViewController.h"
//#import "RecentUsersViewController.h"
@interface MyViewController ()

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.knavigationBar.title = @"我的";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.knavigationBar.title = @"好的";
    });
    
    self.knavigationBar.rightBarBtnItem = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(0, 0, 44, 44) title:@"关闭" hander:^(id _Nonnull sender) {
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
