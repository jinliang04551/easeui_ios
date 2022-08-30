//
//  YGGroupApplyApprovalCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupApplyApprovalCell.h"
#import "BQAvatarTitleRoleCell.h"
#import "BQTitleAvatarCell.h"
#import "UserInfoStore.h"
#import "EaseHeaders.h"
#import "EaseKitUtil.h"
#import "BQGroupApplyApprovalModel.h"

@interface YGGroupApplyApprovalCell ()

@property (nonatomic, strong) UILabel *inviteLabel;
@property (nonatomic, strong) UILabel *applyLabel;
@property (nonatomic, strong) UILabel *groupNameLabel;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *declineButton;
@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong) BQGroupApplyApprovalModel *model;

@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;

@end


@implementation YGGroupApplyApprovalCell

- (void)prepare {
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(accessAction)];
    [self.contentView addGestureRecognizer:self.tapGesture];
    
    [self.contentView addSubview:self.applyLabel];
    [self.contentView addSubview:self.groupNameLabel];
    [self.contentView addSubview:self.inviteLabel];
    [self.contentView addSubview:self.declineButton];
    [self.contentView addSubview:self.agreeButton];
    [self.contentView addSubview:self.resultLabel];

}


- (void)placeSubViews {
    [self.applyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.groupNameLabel.mas_top).offset(-4.0);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.right.equalTo(self.contentView).offset(-16.0);
    }];
    
    [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.declineButton);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.right.equalTo(self.declineButton.mas_left);
    }];

    [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupNameLabel.mas_bottom).offset(4.0);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.right.equalTo(self.declineButton.mas_left);
    }];

    [self.declineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.agreeButton);
        make.right.equalTo(self.agreeButton.mas_left).offset(-16.0);
        make.size.equalTo(self.agreeButton);
    }];

    
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(36.0);
        make.right.equalTo(self.contentView).offset(-16.0);
        make.width.equalTo(@(60.0));
        make.height.equalTo(@(28.0));
    }];
    
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(36.0);
        make.right.equalTo(self.contentView).offset(-16.0);
        make.width.equalTo(@(60.0));
        make.height.equalTo(@(28.0));
    }];
    
   

}


- (void)accessAction {
    if (self.accessBlock) {
        self.accessBlock(self.model);
    }
}



//fail是拒绝 success 是同意 wait是邀请加入的初始状态
- (void)updateWithObj:(id)obj {
    
    self.model = (BQGroupApplyApprovalModel *)obj;
    
    NSString *state = self.model.state;
    if ([state isEqualToString:@"wait"]) {
        [self updateResultLabelWithIsHidden:YES];
    }else {
        [self updateResultLabelWithIsHidden:NO];

        if([state isEqualToString:@"success"]) {
            self.resultLabel.text = @"已同意";
        }else {
            self.resultLabel.text = @"已拒绝";
        }
    }
    
    self.applyLabel.text = self.model.userNickName;
    self.inviteLabel.text = [NSString stringWithFormat:@"邀请人: %@",self.model.inviterNickName];
    
    NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *tString = [EaseKitUtil attributeContent:@"申请加入 " color:[UIColor colorWithHexString:@"#7F7F7F"] font:self.groupNameLabel.font];
    
    NSAttributedString *gString = [EaseKitUtil attributeContent:self.model.groupName color:[UIColor colorWithHexString:@"#171717"] font:self.groupNameLabel.font];
    
    [mutableAttString appendAttributedString:tString];
    [mutableAttString appendAttributedString:gString];
    self.groupNameLabel.attributedText = mutableAttString;
}

- (void)updateResultLabelWithIsHidden:(BOOL)isHidden {
    self.resultLabel.hidden = isHidden;
    self.declineButton.hidden = !isHidden;
    self.agreeButton.hidden = !isHidden;
}

- (void)declineButtonAction {
    self.model.state = @"fail";

    if (self.approvalBlock) {
        self.approvalBlock(self.model);
    }
}

- (void)agreeButtonAction {
    self.model.state = @"success";
    if (self.approvalBlock) {
        self.approvalBlock(self.model);
    }
}


#pragma mark getter and setter
- (UILabel *)applyLabel {
    if (_applyLabel == nil) {
        _applyLabel = [[UILabel alloc] init];
        _applyLabel.font = EaseIMKit_NFont(14.0);
        _applyLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _applyLabel.textAlignment = NSTextAlignmentLeft;
        _applyLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _applyLabel;
}

- (UILabel *)groupNameLabel {
    if (_groupNameLabel == nil) {
        _groupNameLabel = [[UILabel alloc] init];
        _groupNameLabel.font = EaseIMKit_NFont(12.0);
        _groupNameLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _groupNameLabel.textAlignment = NSTextAlignmentLeft;
        _groupNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _groupNameLabel;

}

- (UILabel *)inviteLabel {
    if (_inviteLabel == nil) {
        _inviteLabel = [[UILabel alloc] init];
        _inviteLabel.font = EaseIMKit_NFont(12.0);
        _inviteLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _inviteLabel.textAlignment = NSTextAlignmentLeft;
        _inviteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _inviteLabel;
}

- (UIButton *)declineButton {
    if (_declineButton == nil) {
        _declineButton = [[UIButton alloc] init];
        [_declineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_declineButton setTitle:@"拒绝" forState:UIControlStateNormal];
        _declineButton.titleLabel.font = EaseIMKit_NFont(14.0);
        
        [_declineButton addTarget:self action:@selector(declineButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _declineButton.backgroundColor = [UIColor colorWithHexString:@"#EDEFF2"];
        _declineButton.layer.cornerRadius = 2.0;
    }
    return _declineButton;

}


- (UIButton *)agreeButton {
    if (_agreeButton == nil) {
        _agreeButton = [[UIButton alloc] init];
        [_agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_agreeButton setTitle:@"接受" forState:UIControlStateNormal];
        _agreeButton.titleLabel.font = EaseIMKit_NFont(14.0);
        
        [_agreeButton addTarget:self action:@selector(agreeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _agreeButton.backgroundColor = [UIColor colorWithHexString:@"#4697CA"];
        _agreeButton.layer.cornerRadius = 2.0;
    }
    return _agreeButton;

}

- (UILabel *)resultLabel {
    if (_resultLabel == nil) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.font = EaseIMKit_NFont(14.0);
        _resultLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _resultLabel.textAlignment = NSTextAlignmentLeft;
        _resultLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _resultLabel.hidden = YES;
    }
    return _resultLabel;
    
}


@end
