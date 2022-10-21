//
//  YGGroupBanMemberCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupOperateMemberCell.h"
#import "UserInfoStore.h"
#import "EaseHeaders.h"

@interface YGGroupOperateMemberCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) NSString* userId;

@end


@implementation YGGroupOperateMemberCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.operateButton];
    
}


- (void)placeSubViews {

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(EaseIMKit_AvatarHeight);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0f);
        make.right.equalTo(self.operateButton.mas_left);
    }];
    
    [self.operateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-16.0f);
        make.width.equalTo(@(72.0));
        make.height.equalTo(@(28.0));
    }];

}

- (void)updateWithObj:(id)obj {
    NSString *username = (NSString *)obj;
    self.userId = username;
    
    [self updateCellWithUserId:self.userId];
    
}


- (void)unBanButtonAction {
    if (self.removeMemberBlock) {
        self.removeMemberBlock(self.userId);
    }
}

#pragma mark getter and setter
- (UIButton *)operateButton {
    if (_operateButton == nil) {
        _operateButton = [[UIButton alloc] init];
        
        [_operateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_operateButton setTitle:@"解禁" forState:UIControlStateNormal];
        _operateButton.titleLabel.font = EaseIMKit_NFont(12.0);
        
        
        [_operateButton addTarget:self action:@selector(unBanButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _operateButton.backgroundColor = EaseIMKit_Default_BgBlue_Color;
        _operateButton.layer.cornerRadius = 4.0;
    }
    return _operateButton;
}



@end
