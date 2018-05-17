//
//  SelectContactCell.m
//  Clanunity
//
//  Created by wangyadong on 2018/3/13.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "SelectContactCell.h"

@implementation SelectContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.header = [[UIImageView alloc] initWithFrame:CGRectMake(12,10, 35, 35)];
        [self.contentView addSubview:self.header];
        self.header.image = [UIImage imageNamed:CUKey.kPlaceHead];
        self.name = [UILabel labelWithFrame:CGRectMake(self.header.right_sd+10, self.top_sd, KScreenWidth-80, 35) text:@"" font:[UIFont systemFontOfSize:15] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.name];
        self.name.centerY_sd = self.header.centerY_sd;
        self.statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(12,10, 18, 18)];
        [self.contentView addSubview:self.statusImg];
        self.statusImg.image = [UIImage imageNamed:@"nullcircle"];
        self.statusImg.right_sd = KScreenWidth-12;
        self.statusImg.centerY_sd = self.header.centerY_sd;
        
    }
    return self;
}
-(void)setModel:(MTTUserEntity *)model{
    _model = model;
    [self.header sd_setImageWithURL:[NSURL URLWithString:model.headimg] placeholderImage:[UIImage imageNamed:CUKey.kPlaceHead]];
    self.name.text = model.realname;
    if (model.selected == 1) {
        self.statusImg.image = [UIImage imageNamed:@"nonullcircle"];
    }else if (model.selected == 0){
        self.statusImg.image = [UIImage imageNamed:@"nullcircle"];
    }else{
        self.statusImg.image = [UIImage imageNamed:@"unableSelect"];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

