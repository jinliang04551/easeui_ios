//
//  ACDTitleDetailCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/17.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "BQTitleDetailCell.h"
#import "EaseHeaders.h"

@implementation BQTitleDetailCell

- (void)prepare {
    
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(EaseIMKit_Padding * 1.6);
        make.right.equalTo(self.detailLabel.mas_left);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-EaseIMKit_Padding * 1.6);
    }];
    
}

#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = EaseIMKit_Font(@"PingFang SC", 14.0);
        _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}


@end
