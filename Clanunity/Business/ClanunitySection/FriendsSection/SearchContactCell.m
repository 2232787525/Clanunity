//
//  SearchContactCell.m
//  Clanunity
//
//  Created by wangyadong on 2018/3/15.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "SearchContactCell.h"

@implementation SearchContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.header = [[MTTAvatarImageView alloc] initWithFrame:CGRectMake(12,10, 50, 50)];
        [self.contentView addSubview:self.header];
        self.header.image = [UIImage imageNamed:CUKey.kPlaceHead];
        self.name = [UILabel labelWithFrame:CGRectMake(self.header.right_sd+10, self.top_sd, KScreenWidth-80, 20) text:@"" font:[UIFont systemFontOfSize:15] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.name];
        self.name.centerY_sd = self.header.centerY_sd;
        
        self.detial = [UILabel labelWithFrame:CGRectMake(self.header.right_sd+10, self.top_sd, KScreenWidth-80, 20) text:@"" font:[UIFont systemFontOfSize:12] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        self.detial.bottom_sd = self.header.bottom_sd;
        self.detial.hidden = YES;
        [self.contentView addSubview:self.detial];
        
    }
    return self;
}

-(void)setModel:(SearchAddFriendModel *)model{
    _model = model;
    [self.header sd_setImageWithURL:[NSURL URLWithString:model.headimg] placeholderImage:[UIImage imageNamed:CUKey.kPlaceHead]];
    self.name.text = model.realname;
    self.detial.text = [NSString stringWithFormat:@"包含:%@",model.include];
    if (model.type == 0) {
        self.detial.hidden = YES;
        self.name.centerY_sd = self.header.centerY_sd;
    }else{
        self.detial.hidden = NO;
        self.name.top_sd = self.header.top_sd;
        self.detial.bottom_sd = self.header.bottom_sd;
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end



@implementation SearchAddFriendModel



@end


@implementation SearchContactKeyView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.header = [[UIImageView alloc] initWithFrame:CGRectMake(12,10, 40, 40)];
        [self addSubview:self.header];
        self.header.image = [UIImage imageNamed:@"searchFrdIcon"];
        
        
        UILabel *searchlb = [UILabel labelWithFrame:CGRectMake(self.header.right_sd+10, self.top_sd, 47, 20) text:@"搜索:" font:[UIFont systemFontOfSize:15] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        [self addSubview:searchlb];
        searchlb.centerY_sd = self.header.centerY_sd;
        
        
        self.name = [UILabel labelWithFrame:CGRectMake(searchlb.right_sd, self.top_sd, KScreenWidth-searchlb.right_sd,40) text:@"喵啊啊" font:[UIFont systemFontOfSize:15] textColor:[UIColor theme] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.name];
        self.name.centerY_sd = self.header.centerY_sd;
        
        self.tapBtn = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:self.tapBtn];
        WeakSelf;
        [self.tapBtn handleEventTouchUpInsideCallback:^{
           
            if (weakSelf.searchClickedBlock&&[weakSelf.name.text trim]) {
                weakSelf.searchClickedBlock([weakSelf.name.text trim]);
            }
        }];
    }
    return self;
}

@end
