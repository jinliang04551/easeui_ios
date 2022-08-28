//
//  YGPopOperationCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/24.
//

#import "YGPopOperationCell.h"
#import "UIView+MISRedPoint.h"

@implementation YGPopOperationCell
- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
     
}


- (void)placeSubViews {
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 0;
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(@(28.0));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.right.equalTo(self.contentView).offset(-12.0);
    }];
    
    self.contentView.MIS_redDot = [MISRedDot redDotWithConfig:({
        MISRedDotConfig *config = [[MISRedDotConfig alloc] init];
        config.offsetY = [YGPopOperationCell height]* 0.4;
        config.offsetX = 5.0;
        config.size = CGSizeMake(8.0, 8.0);
        config.radius = 8.0 * 0.5;
        config;
    })];
    self.contentView.MIS_redDot.hidden = YES;
    
}

- (void)showRedPoint:(BOOL)isShow {
    self.contentView.MIS_redDot.hidden = !isShow;
}

+ (CGFloat)height {
    return 44.0;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            self.contentView.backgroundColor = EaseIMKit_COLOR_HEX(0x252525);
        }else {
            self.contentView.backgroundColor = EaseIMKit_COLOR_HEX(0xECF5FF);
        }
        
    }else {
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
                self.contentView.backgroundColor = EaseIMKit_ViewCellBgBlackColor;
        }else {
                self.contentView.backgroundColor = EaseIMKit_ViewCellBgWhiteColor;
        }

    }
}


@end
