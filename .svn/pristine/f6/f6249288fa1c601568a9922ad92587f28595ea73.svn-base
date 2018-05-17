//
//  SelectContactVC.h
//  Clanunity
//
//  Created by wangyadong on 2018/3/13.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KBaseClanViewController.h"
@class ContactFriendModel,SearchTF;
@interface SelectContactVC : KBaseClanViewController

@property(nonatomic,copy)void(^createGroupSuccess)(BOOL success);
@property(nonatomic,copy)void(^singleChat)(MTTUserEntity * user);
@end


@interface SelectContactVC_SelectedView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UIImageView *searchIcon;
@property(nonatomic,strong)UICollectionView *usersView;
@property(nonatomic,strong)SearchTF *searchTf;

//选中的model数据
@property(nonatomic,strong)NSMutableArray *dataArray;

//选中的字典数据
@property(nonatomic,strong)NSMutableDictionary *dataMap;

//搜索列表
@property(nonatomic,strong)UITableView *searchTable;
//搜索结果数据
@property(nonatomic,strong)NSMutableArray *searchData;
//原始总数据
@property(nonatomic,strong)NSArray *contactArray;

@property(nonatomic,strong)UIImageView * emptyImg;
@property(nonatomic,strong)UILabel *emptylb;

/**
 数据改变

 @param add 1新增。0删除
 @param model 数据
 */
-(void)dataChangeStatusAdd:(NSInteger)add forModel:(MTTUserEntity*)model;
@property(nonatomic,copy)void(^collectionItemChanged)(MTTUserEntity*model);
@property(nonatomic,copy)void(^searchTFBeginEditBlock)(void);

@property(nonatomic,copy)void(^searchResultBlock)(MTTUserEntity*model);

@end;





@interface SelectedCollectionCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView *header;
@property(nonatomic,strong)MTTUserEntity *model;
@end;



@interface SearchTF : UITextField

@property(nonatomic,copy)void(^deleteBackwardBlock)(void);

@end;
