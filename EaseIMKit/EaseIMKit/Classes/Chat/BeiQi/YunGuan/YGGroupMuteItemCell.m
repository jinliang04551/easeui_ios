//
//  YGGroupMuteItemCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/26.
//

#import "YGGroupMuteItemCell.h"
#import "UserInfoStore.h"
#import "EaseHeaders.h"


@interface YGGroupMuteItemCell()

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) BOOL isChecked;

@end

@implementation YGGroupMuteItemCell

- (void)prepare {
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//        self.contentView.backgroundColor = EaseIMKit_ViewBgBlackColor;
//        self.nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        
        self.contentView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
    }else {
        self.contentView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
    }
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.checkButton];
    
}


- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(@(38.0));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0f);

    }];
    
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-16.0f);
        make.size.equalTo(@(24.0));
    }];

}



- (void)updateWithObj:(id)obj {
    
}

- (void)updateWithObj:(id)obj isChecked:(BOOL)isChecked {
    NSString *username = (NSString *)obj;
    
    self.userId = username;
    self.isChecked = isChecked;
    
    self.nameLabel.text = username;
    self.iconImageView.image = [UIImage easeUIImageNamed:@"jh_user_icon"];
    
    [self updateCellWithUserId:username];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setIsChecked:(BOOL)isChecked
{
    if (_isChecked != isChecked) {
        _isChecked = isChecked;
        if (isChecked) {
            
            [self.checkButton setImage:[UIImage easeUIImageNamed:@"yg_slected"] forState:UIControlStateNormal];
        } else {
            if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
                        [self.checkButton setImage:[UIImage easeUIImageNamed:@"yg_unSlected"] forState:UIControlStateNormal];
            }else {
                        [self.checkButton setImage:[UIImage easeUIImageNamed:@"yg_unSlected"] forState:UIControlStateNormal];
            }

        }
    }
}



- (void)checkButtonAction {
//    self.isChecked = !self.isChecked;
    if (self.checkBlcok) {
        self.checkBlcok(self.userId, self.isChecked);
    }
    
}

- (UIButton *)checkButton {
    if (_checkButton == nil) {
        _checkButton = [[UIButton alloc] init];
        [_checkButton setImage:[UIImage easeUIImageNamed:@"yg_unSlected"] forState:UIControlStateNormal];

        [_checkButton addTarget:self action:@selector(checkButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _checkButton;
}


@end
