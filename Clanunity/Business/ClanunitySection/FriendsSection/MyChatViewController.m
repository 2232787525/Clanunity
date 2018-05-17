//
//  MyChatViewController.m
//  Clanunity
//
//  Created by wangyadong on 2018/4/18.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "MyChatViewController.h"

@interface MyChatViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,strong)MyChatInput *input;
@end

@implementation MyChatViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (NSInteger i = 0; i < 15; i++) {
        [self.dataArray addObject:[NSString stringWithFormat:@"测试cell%@",@(i)]];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [self makeTableView];
    [self.view addSubview:self.input];
    // Do any additional setup after loading the view.
}
- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    CGRect keyboardRect;
    keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"Hide-1>%@",NSStringFromCGRect(keyboardRect));
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    NSLog(@"Hide-2>%@",NSStringFromCGRect(keyboardRect));

    [UIView animateWithDuration:0.25 animations:^{
        self.input.bottom_sd = keyboardRect.origin.y;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0,44, 0);
        
        
    } completion:^(BOOL finished) {
        if (finished) {
            NSInteger rows = [self.tableView numberOfRowsInSection:0];
            if(rows > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }];
    
    
    
}
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    CGRect keyboardRect;
    keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"Show-1>%@",NSStringFromCGRect(keyboardRect));
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    NSLog(@"Show-2>%@",NSStringFromCGRect(keyboardRect));
    [UIView animateWithDuration:0.25 animations:^{
        self.input.bottom_sd = keyboardRect.origin.y;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0,keyboardRect.size.height+44, 0);
        NSInteger rows = [self.tableView numberOfRowsInSection:0];
        if(rows > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

-(MyChatInput *)input{
    if (_input == nil) {
        MyChatInput * inputV = [MyChatInput showInoutView];
        inputV.bottom_sd = KScreenHeight;
        _input = inputV;
        WeakSelf;
        [_input setTextReturn:^(NSString *text) {
            if (text.length > 0) {
                [weakSelf.dataArray addObject:text];
                [weakSelf.tableView reloadData];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSInteger rows = [weakSelf.tableView numberOfRowsInSection:0];
                    if(rows > 0) {
                        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];                        
                    }
                });
                
                
            }
            
            
            
        }];
        
        
    }
    return _input;
}

-(void)makeTableView{

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopHeight,KScreenWidth,KScreenHeight-KTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView setSeparatorColor:[UIColor textColor1]];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //ios8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:self.tableView];
//    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
//    footer.layer.borderColor = [UIColor redColor].CGColor;
//    footer.layer.borderWidth = 0.5;
//    self.tableView.tableFooterView = footer;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier =@"ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
    
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(NSMutableArray*)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
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




@implementation MyChatInput

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.textfild = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, self.width_sd-100, self.height_sd-16)];
        self.textfild.backgroundColor = [UIColor bgColor5];
        self.textfild.centerY_sd = self.height_sd/2.0;
        self.textfild.delegate = self;
        self.textfild.returnKeyType = UIReturnKeySend;
        [self addSubview:self.textfild];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.textfild.right_sd+10, 0,60, self.textfild.height_sd)];
        btn.centerY_sd = self.textfild.centerY_sd;
        [btn setTitle:@"Cancel" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor theme] forState:UIControlStateNormal];
        [self addSubview:btn];
        [btn handleEventTouchUpInsideCallback:^{
            [self.textfild resignFirstResponder];
        }];
    }
    return self;
}
+(MyChatInput *)showInoutView{
    MyChatInput *input = [[MyChatInput alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    return input;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.textReturn) {
        self.textReturn(textField.text);
    }
    textField.text = nil;
    return YES;
}


@end
