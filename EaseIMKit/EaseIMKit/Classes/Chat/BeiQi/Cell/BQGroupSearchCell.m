//
//  BQGroupSearchCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/9.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQGroupSearchCell.h"
#import "UserInfoStore.h"
#import "EaseHeaders.h"


@interface BQGroupSearchCell ()
@property (nonatomic, strong) UIImageView *servicerIconImageView;
@property (nonatomic, strong) UILabel *servicerLabel;
@property (nonatomic, strong) UIButton *servicerButton;

@property (nonatomic, strong) UILabel *customerLabel;
@property (nonatomic, strong) UIButton *customerButton;
@property (nonatomic, strong) NSString *currentUserId;

@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;

@end


@implementation BQGroupSearchCell


- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.servicerButton];
    [self.contentView addSubview:self.servicerLabel];
    [self.contentView addSubview:self.customerButton];
    [self.contentView addSubview:self.customerLabel];
}


- (void)placeSubViews {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(EaseIMKit_AvatarHeight);
        
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.right.equalTo(self.contentView).offset(-16.0);
    }];

    [self.servicerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(30.0);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.width.equalTo(@(16.0));
        make.height.equalTo(@(16.0));
    }];

    [self.servicerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(30.0);
        make.left.equalTo(self.servicerButton.mas_right).offset(4.0);
        make.width.equalTo(@(90.0));
    }];

    
    [self.customerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.servicerButton);
        make.left.equalTo(self.servicerLabel.mas_right).offset(14.0);
        make.size.equalTo(self.servicerButton);
    }];
    
    [self.customerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.servicerButton);
        make.left.equalTo(self.customerButton.mas_right).offset(4.0);
        make.size.equalTo(self.servicerLabel);
    }];

}


- (void)updateWithObj:(id)obj {
    NSString *aUid = (NSString *)obj;
    self.currentUserId = aUid;
    
    self.groupUserType = BQGroupUserTypeNone;
//    [self.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_user_icon"]];
//    self.nameLabel.text = aUid;
    [self updateCellWithUserId:aUid];
}



#pragma mark action
- (void)servicerButtonAction {
    if (self.servicerBlock) {
        self.servicerBlock(self.currentUserId);
    }
    
    self.groupUserType = BQGroupUserTypeServicer;
}


- (void)customerButtonAction {
    if (self.customerBlock) {
        self.customerBlock(self.currentUserId);
    }
    self.groupUserType = BQGroupUserTypeCustomer;
}


#pragma mark getter and setter
- (UILabel *)servicerLabel {
    if (_servicerLabel == nil) {
        _servicerLabel = [[UILabel alloc] init];
        _servicerLabel.font = EaseIMKit_NFont(14.0);
        _servicerLabel.textColor = [UIColor colorWithHexString:@"#7E7E7E"];
        _servicerLabel.textAlignment = NSTextAlignmentLeft;
        _servicerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _servicerLabel.text = @"选为服务人员";

    }
    return _servicerLabel;
}


- (UIButton *)servicerButton {
    if (_servicerButton == nil) {
        _servicerButton = [[UIButton alloc] init];
        [_servicerButton setImage:self.normalImage forState:UIControlStateNormal];
        [_servicerButton addTarget:self action:@selector(servicerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _servicerButton;
}

- (UILabel *)customerLabel {
    if (_customerLabel == nil) {
        _customerLabel = [[UILabel alloc] init];
        _customerLabel.font = EaseIMKit_NFont(14.0);
        _customerLabel.textColor = [UIColor colorWithHexString:@"#7E7E7E"];
        _customerLabel.textAlignment = NSTextAlignmentLeft;
        _customerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _customerLabel.text = @"选为客户";
    }
    return _customerLabel;
}



- (UIButton *)customerButton {
    if (_customerButton == nil) {
        _customerButton = [[UIButton alloc] init];
        [_customerButton setImage:self.normalImage forState:UIControlStateNormal];

        [_customerButton addTarget:self action:@selector(customerButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _customerButton;
}

- (void)setGroupUserType:(BQGroupUserType)groupUserType {
    
    if(groupUserType == BQGroupUserTypeServicer) {
        [self.servicerButton setImage:[UIImage easeUIImageNamed:@"jh_user_check"] forState:UIControlStateNormal];
        [self.customerButton setImage:self.normalImage forState:UIControlStateNormal];
    }else if(groupUserType == BQGroupUserTypeCustomer) {
        [self.servicerButton setImage:self.normalImage forState:UIControlStateNormal];
        [self.customerButton setImage:[UIImage easeUIImageNamed:@"jh_user_check"] forState:UIControlStateNormal];
    }else {
        [self.servicerButton setImage:self.normalImage forState:UIControlStateNormal];
        [self.customerButton setImage:self.normalImage forState:UIControlStateNormal];

    }
    
}


- (UIImage *)normalImage {
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    _normalImage = [UIImage easeUIImageNamed:@"jh_user_normal"];
}else {
    _normalImage = [UIImage easeUIImageNamed:@"yg_user_normal"];
}

    return _normalImage;
}

- (UIImage *)selectedImage {
    _selectedImage = [UIImage easeUIImageNamed:@"jh_user_check"];
    return _selectedImage;
}

@end
