//
//  YGGroupAddBanCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupAddUserCell.h"
#import "EaseHeaders.h"

@interface YGGroupAddUserCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@end


@implementation YGGroupAddUserCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    
    self.iconImageView.image = [UIImage easeUIImageNamed:@"yg_add_mute"];
    self.nameLabel.text = @"添加禁言人员";
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
}


- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(@(20.0));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0f);

    }];
    
}


@end
