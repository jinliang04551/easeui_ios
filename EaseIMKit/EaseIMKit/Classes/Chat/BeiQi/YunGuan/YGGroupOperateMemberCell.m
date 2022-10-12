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
@property (nonatomic, strong) UIButton* unBanButton;
@property (nonatomic, strong) NSString* userId;

@end


@implementation YGGroupOperateMemberCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.unBanButton];
    
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
        make.right.equalTo(self.unBanButton.mas_left);
    }];
    
    [self.unBanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-16.0f);
        make.width.equalTo(@(58.0));
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
- (UIButton *)unBanButton {
    if (_unBanButton == nil) {
        _unBanButton = [[UIButton alloc] init];

        [_unBanButton setImage:[UIImage easeUIImageNamed:@"yg_unMute"] forState:UIControlStateNormal];
        [_unBanButton addTarget:self action:@selector(unBanButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _unBanButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
        _unBanButton.layer.cornerRadius = 4.0;
    }
    return _unBanButton;
}



@end
