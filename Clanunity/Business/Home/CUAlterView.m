//
//  PLSocialView.m - bex

//  _stateBtn.tag = 0 是待审核，1，通过， 2 未加入
//  model status    0 已申请   1加入    -1 未加入

#import "CUAlterView.h"

@class GoodsCell;

#pragma mark - 寄思先祖贡品弹窗
@interface JisiAlterView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    UICollectionView *mainCollectionView;
    BOOL didAddSperateVerticalLine;
}
@end

@implementation JisiAlterView

-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC dismissAnimation:(id<LewPopupAnimation>)animation{
    self = [super initWithFrame:frame parentVC:parentVC dismissAnimation:animation];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width_sd, 156 * kScreenScale)];//F_I6(place: 156)
        _bgImage.image = [UIImage imageNamed:@"alter_bg"];
        [self addSubview:_bgImage];
        _bgImage.contentMode = UIViewContentModeScaleToFill;
        [self createCollectionView];
        
    }
    return self;
}

-(void)createCollectionView{
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //2.初始化collectionView
    mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, self.width_sd-20, 156 * kScreenScale-20) collectionViewLayout:layout];
    [self addSubview:mainCollectionView];
    mainCollectionView.backgroundColor = [UIColor clearColor];
    //3.注册collectionViewCell
    [mainCollectionView registerClass:[GoodsCell class] forCellWithReuseIdentifier:@"cellId"];
    mainCollectionView.showsHorizontalScrollIndicator = NO;
    mainCollectionView.showsVerticalScrollIndicator = NO;
    
    //4.设置代理
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    
    [mainCollectionView reloadData];
    [mainCollectionView.mj_header endRefreshing];
    [mainCollectionView.mj_footer endRefreshing];
}



#pragma mark - collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.thingsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GoodsCell *cell = (GoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
//    [cell.tipbtn setTitle:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forState:(UIControlStateNormal)];
    [cell.tipbtn setTitle:@"免费" forState:(UIControlStateNormal)];

    cell.imageView.image = [UIImage imageNamed:self.thingsArr[indexPath.row]];
    
    CGSize contentSize = collectionView.contentSize;
    float hei = 0;
    if (self.thingsArr.count <= 6){
        hei = mainCollectionView.height_sd-10;
    }else{
        hei = contentSize.height - 10 ;
    }
    
    if(didAddSperateVerticalLine == NO) {
        UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(contentSize.width/3 - 0.5, 5, 1, hei)];
        verticalLine.backgroundColor = [UIColor lightGrayColor];
        verticalLine.alpha = 0.35;
        [collectionView addSubview:verticalLine];
        
        UIView *verticalLine2 = [[UIView alloc]initWithFrame:CGRectMake(contentSize.width/3*2 - 0.5, 5, 1, hei)];
        verticalLine2.backgroundColor = [UIColor lightGrayColor];
        verticalLine2.alpha = 0.35;
        [collectionView addSubview:verticalLine2];
        
        didAddSperateVerticalLine = YES;
    }
    
    UIView *view = [collectionView viewWithTag:indexPath.row/3-1 + 30];
    if (view){
    }else{
        if (indexPath.row %3 ==0 && indexPath.row>0){
            UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(5,   cell.frame.size.height + (cell.frame.size.height+1) * (indexPath.row/3-1) , contentSize.width-10, 1)];//每一个cell的framee是 17.00, 10.00, 160.00, 160.00  ,
            horizontalLine.backgroundColor = [UIColor lightGrayColor];
            horizontalLine.alpha = 0.35;
            horizontalLine.tag = indexPath.row/3-1 + 30;
            [collectionView addSubview:horizontalLine];
        }
    }
    
    int start = 0;
    
    if (_thingsArr.count/3 < 1){
        start = 0;
    }else if (_thingsArr.count/3 < 2){
        start = 1;
    }
        
    for(int i = start ; i<2; i++){
        UIView *view = [collectionView viewWithTag:i + 30];
        if (view){
        }else{
        UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(5,   cell.frame.size.height + (cell.frame.size.height+1) * i , contentSize.width-10, 1)];//每一个cell的framee是 17.00, 10.00, 160.00, 160.00  ,
        horizontalLine.backgroundColor = [UIColor lightGrayColor];
        horizontalLine.alpha = 0.35;
        horizontalLine.tag = i + 30;
        [collectionView addSubview:horizontalLine];
        }
    }
    
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    float W = (218 * kScreenScale-20-2)/3;
//    float H = (156 * kScreenScale-20-2)/3;
    
    //75 55
    return CGSizeMake(64 * kScreenScale,44 * kScreenScale);
}


//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectedIndexBlock){
        self.selectedIndexBlock(indexPath.row);
    }
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

-(void)setThingsArr:(NSArray *)thingsArr{
    
    _thingsArr = thingsArr;
    [mainCollectionView reloadData];
}

@end



#pragma mark - 寄思先祖 弹窗商品cell
@implementation GoodsCell

- (instancetype )initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _imageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 45 * kScreenScale, 45 * kScreenScale)];
        _imageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        _imageView.image = [UIImage imageNamed:@"jisi_zhu"];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
        
        
        _tipbtn = [[UIButton alloc]initWithFrame:(CGRectMake(frame.size.width - 29 * kScreenScale , frame.size.height - 17 * kScreenScale, 27 * kScreenScale, 15 * kScreenScale))];
        [_tipbtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        _tipbtn.titleLabel.font = [UIFont systemFontOfSize:10];
        _tipbtn.layer.cornerRadius = 5;
        _tipbtn.clipsToBounds = YES;
        _tipbtn.backgroundColor = [UIColor baseColor];
        _tipbtn.userInteractionEnabled = NO;
        [self addSubview:_tipbtn];
        
    }
    
    return self;
}
@end



#pragma mark - 提示框 一个或两个按钮
@interface msgAlterView ()<UITextFieldDelegate>{
    UIView * _line;
}
@end

@implementation msgAlterView

-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC dismissAnimation:(id<LewPopupAnimation>)animation title:(NSString *)str{
    self = [super initWithFrame:frame parentVC:parentVC dismissAnimation:animation];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        WeakSelf
        
        _bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _bgImage.image = [UIImage imageNamed:@"alter_bg2"];
        
        _bgImage.backgroundColor = [UIColor whiteColor];
        _bgImage.layer.cornerRadius = 5;
        _bgImage.clipsToBounds = true;
        
        _infoLab = [[UILabel alloc]initWithFrame:CGRectMake(12, 0,  _bgImage.width_sd-24, frame.size.height - 44 * kScreenScale - 1)];
        _infoLab.text = str;
        _infoLab.textAlignment = NSTextAlignmentCenter;
        _infoLab.textColor = [UIColor textColor2];
        _infoLab.font=[UIFont systemFontOfSize:15];
        
        _btncancle = [[UIButton alloc]initWithFrame:CGRectMake(0, frame.size.height - 44 * kScreenScale , _bgImage.width_sd/2, 44 * kScreenScale)];
        [_btncancle setTitle:@"取消" forState:(UIControlStateNormal)];
        [_btncancle setTitleColor:[UIColor textColor2] forState:(UIControlStateNormal)];
        _btncancle.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btncancle handleEventTouchUpInsideCallback:^{
            [weakSelf dismissClicked];
        }];
        
        _btn = [[UIButton alloc]initWithFrame:CGRectMake(_btncancle.right_sd, _btncancle.top_sd, _bgImage.width_sd/2, 44 * kScreenScale)];
        [_btn setTitle:@"确定" forState:(UIControlStateNormal)];
        [_btn setTitleColor:[UIColor colorWithHexString:@"Df8405"] forState:(UIControlStateNormal)];
        _btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btn handleEventTouchUpInsideCallback:^{
            [weakSelf dismissClicked];
            if (weakSelf.btnClickBlock){
                weakSelf.btnClickBlock();
            }
        }];
        
        _line = [[UIView alloc]initWithFrame:CGRectMake(_btncancle.right_sd, _infoLab.bottom_sd+3, 1, 44 * kScreenScale-6)];
        _line.backgroundColor = [UIColor cutLineColor];
        
        UIView * _line2 = [[UIView alloc]initWithFrame:CGRectMake(0, _infoLab.bottom_sd, frame.size.width, 1)];
        _line2.backgroundColor = [UIColor cutLineColor];
        
        [self addSubview:_bgImage];
        [self addSubview:_infoLab];
        [self addSubview:_btncancle];
        [self addSubview:_btn];
        [self addSubview:_line];
        [self addSubview:_line2];
    }
    return self;
}

-(void)setBtnArr:(NSArray *)btnArr{
    _btnArr = btnArr;
    if (btnArr.count == 2){
        [self.btn setTitle:btnArr[0] forState:UIControlStateNormal];
        [self.btncancle setTitle:btnArr[1] forState:UIControlStateNormal];
        
        _btncancle.frame = CGRectMake(0, _infoLab.bottom_sd+1, _bgImage.width_sd/2, 44 * kScreenScale);
        _btn.frame = CGRectMake(_btncancle.right_sd, _infoLab.bottom_sd+1, _bgImage.width_sd/2, 44 * kScreenScale);
        _line.hidden = NO;
        self.btncancle.hidden = NO;

    }else{
        [self.btn setTitle:btnArr[0] forState:UIControlStateNormal];
        self.btncancle.hidden = YES;
        _btn.frame = CGRectMake(0, _infoLab.bottom_sd+1, _bgImage.width_sd, 44 * kScreenScale);
        _line.hidden = YES;
    }
}

@end


@interface BounceAlter ()
@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)UIButton * gobtn;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBeahvior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@end


@implementation BounceAlter
-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC dismissAnimation:(id<LewPopupAnimation>)animation{
    self = [super initWithFrame:frame parentVC:parentVC dismissAnimation:animation];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 263 * kScreenScale, 326 * kScreenScale)];
        _bgImage.image = [UIImage imageNamed:@"jisi_alter"];
        
        
        WeakSelf
        _btncancle = [[UIButton alloc]initWithFrame:CGRectMake((263 - 41)/2 * kScreenScale, _bgImage.bottom_sd, 41 * kScreenScale, 71 * kScreenScale)];
        [_btncancle setBackgroundImage:[UIImage imageNamed:@"line_close"] forState:UIControlStateNormal];

        [_btncancle handleEventTouchUpInsideCallback:^{
            [weakSelf dismissClicked];
        }];
        
        
        _btn = [[UIButton alloc]initWithFrame:CGRectMake(52 * kScreenScale, 260 * kScreenScale, 159 * kScreenScale, 30  * kScreenScale )];
        [_btn setTitleColor:[UIColor baseColor] forState:(UIControlStateNormal)];
        [_btn setImage:[UIImage imageNamed:@"go_btn"] forState:UIControlStateNormal];
        
        [_btn handleEventTouchUpInsideCallback:^{
            [weakSelf dismissClicked];
            if (weakSelf.btnClickBlock){
                weakSelf.btnClickBlock();
            }
        }];
        
        
        [self addSubview:_bgImage];
        [self addSubview:_btncancle];
        [self addSubview:_btn];
        
    }
    return self;
}
@end


@interface BounceVC ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBeahvior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;

@end

@implementation BounceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapped:)];
    [self.view addGestureRecognizer:gesture];
    [self setUpDownMushroom];
}

- (void)dealloc {
    [self.animator removeAllBehaviors];
}

- (void)setUpDownMushroom {
    // 相当于一个容器，为下面动画提供上下文
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 重力
    self.gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 碰撞
    self.collisionBehavior = [[UICollisionBehavior alloc] init];
    // 碰撞边界为可碰撞边界
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    // 物体属性
    self.itemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.itemBehavior.elasticity = 0.7; // 改变弹性
    self.itemBehavior.friction = 0.5; // 摩擦
    self.itemBehavior.resistance = 0.5; // 阻力
    
    [self.animator addBehavior:self.gravityBeahvior];
    [self.animator addBehavior:self.collisionBehavior];
    [self.animator addBehavior:self.itemBehavior];
}

- (void)tapped:(UITapGestureRecognizer *)gesture {
    
    UIImage *image = [UIImage imageNamed:@"jisi_alter"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    CGPoint tappedPosition = [gesture locationInView:gesture.view];
    imageView.center = tappedPosition;
    
    [self.gravityBeahvior addItem:imageView];
    [self.collisionBehavior addItem:imageView];
    [self.itemBehavior addItem:imageView];
}
@end






#pragma mark - 申请加入弹窗
@interface PLjiaruAlterView ()<UITextFieldDelegate>{
    UILabel *_titlelab;
}
@end

@implementation PLjiaruAlterView

-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC dismissAnimation:(id<LewPopupAnimation>)animation{
    self = [super initWithFrame:frame parentVC:parentVC dismissAnimation:animation];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIView *alterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        alterView.backgroundColor = [UIColor whiteColor];
        alterView.layer.cornerRadius=5;
        alterView.clipsToBounds=YES;
        
        _titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, alterView.width_sd, 45)];
        _titleImage.image = [UIImage imageNamed:@"tiao"];
        
        _titlelab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _titleImage.width_sd, _titleImage.height_sd)];
        _titlelab.font = [UIFont systemFontOfSize:16];
        _titlelab.textColor = [UIColor whiteColor];
        _titlelab.text = @"名称测试";
        [_titlelab setTextAlignment:(NSTextAlignmentCenter)];
        
        _textField=[[UITextField alloc]initWithFrame:CGRectMake(15, 90, alterView.width_sd-30, 60)];
        _textField.textColor=[UIColor textColor2];
        _textField.font=[UIFont systemFontOfSize:14];
        _textField.layer.cornerRadius=5;
        _textField.layer.borderWidth=0.5;
        _textField.layer.borderColor=[UIColor cutLineColor].CGColor;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
        
        _infoLab = [[UILabel alloc]initWithFrame:CGRectMake(_textField.left_sd+5, _textField.top_sd-50, _textField.width_sd, 50)];
        _infoLab.text=@"填写验证信息";
        _infoLab.textColor = [UIColor baseColor];
        _infoLab.font=[UIFont systemFontOfSize:16];
        
        _jiarubtn = [[UIButton alloc]initWithFrame:CGRectMake((alterView.width_sd-180)/2, _textField.bottom_sd+15, 180, 40)];
        [_jiarubtn setBackgroundImage:[UIImage imageNamed:@"anniu"] forState:(UIControlStateNormal)];
        
        WeakSelf
        _closebtn = [[UIButton alloc]initWithFrame:CGRectMake(alterView.width_sd-40, 0, 40, 40)];
        [_closebtn setImage:[UIImage imageNamed:@"guanbI"] forState:(UIControlStateNormal)];
        
        [_closebtn handleEventTouchUpInsideCallback:^{
            [weakSelf dismissClicked];
        }];
        
        
        [self addSubview:alterView];
        [alterView addSubview:_titleImage];
        [alterView addSubview:_titlelab];
        [alterView addSubview:_textField];
        [alterView addSubview:_infoLab];
        [alterView addSubview:_jiarubtn];
        [self addSubview:_closebtn];
    }
    return self;
}

-(void)setName:(NSString *)name{
    _name=name;
    _titlelab.text = name;
}

-(void)setBtnTag:(NSInteger)btnTag{
    if (btnTag==0) {
        [_jiarubtn setTitle:@"再次申请" forState:(UIControlStateNormal)];
    }else{
        [_jiarubtn setTitle:@"申请加入" forState:(UIControlStateNormal)];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end

#pragma mark - 填写邀请码弹窗
@interface PLInvertAlterView ()<UITextFieldDelegate>
@end

@implementation PLInvertAlterView

-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC dismissAnimation:(id<LewPopupAnimation>)animation{
    
    self = [super initWithFrame:frame parentVC:parentVC dismissAnimation:animation];
    if (self) {
        self.textField.center = self.center;
        self.textField.centerY_sd = self.textField.centerY_sd + 10;
        self.textField.textAlignment = NSTextAlignmentCenter;
        self.textField.font = [UIFont boldSystemFontOfSize:20];
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        [self.textField addTarget:self action:@selector(wordlimit:) forControlEvents:(UIControlEventEditingChanged)];
        self.textField.returnKeyType = UIReturnKeyDone;//完成
        self.textField.delegate=self;
        
        self.infoLab.text = @"邀请码提交成功后不可修改";
        self.infoLab.textAlignment = NSTextAlignmentCenter;
        
        self.jiarubtn.frame = CGRectMake(self.textField.left_sd + self.textField.width_sd/2+20, self.jiarubtn.top_sd, self.textField.width_sd/2-20, 44);
        [self.jiarubtn setTitle:@"确定" forState:(UIControlStateNormal)];
        
        self.closebtn.frame = CGRectMake(self.textField.left_sd, self.jiarubtn.top_sd, self.textField.width_sd/2-20,44 );
        [self.closebtn setTitle:@"取消" forState:(UIControlStateNormal)];
        [self.closebtn setBackgroundImage:[UIImage imageNamed:@"anniu_hui"] forState:(UIControlStateNormal)];
        [self.closebtn setImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
        [self.closebtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        WeakSelf
        
        
        [self.closebtn handleEventTouchUpInsideCallback:^{
            weakSelf.textField.text = @"";
            [weakSelf dismissClicked];
        }];
        
    }
    return self;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)wordlimit:(UITextField *)tf{
    if ([tf.text length] > self.numOfWordLimit) {
        tf.text = [tf.text substringToIndex:self.numOfWordLimit];
    }
}
@end




#pragma mark - 左边绿色竖线 右边文字
@implementation PLLineAndLabView : UIView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //左图
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(12, (frame.size.height-20)/2, 5, 20)];
        self.lineView.backgroundColor = [UIColor baseColor];
        [self addSubview:self.lineView];

//        self.titleLab = [UILabel labelFrame:CGRectMake(self.lineView.right_sd+8, 0, 100, frame.size.height) text:@"" PLfont:[UIFont PLFont15] textPLColor:[UIColor PLColor12B06B_Theme] andTextAlignment:NSTextAlignmentLeft];
//        [self addSubview:self.titleLab];
    }
    return self;
}
@end


