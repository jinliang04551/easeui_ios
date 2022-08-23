//
//  ELDSettingTitleValueAccessCell.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/6/12.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "BQTitleValueAccessCell.h"

@interface BQTitleValueAccessCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;

@end


@implementation BQTitleValueAccessCell

- (void)prepare {
    
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.accessoryImageView];
    [self.contentView addSubview:self.bottomLine];

}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(EaseIMKit_Padding * 1.6);
        make.width.equalTo(@(150.0));
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.accessoryImageView.mas_left);
    }];
    
    [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(28.0));
        make.height.equalTo(@(28.0));
        make.right.equalTo(self.contentView).offset(-16.0);
    }];
    
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(EaseIMKit_ONE_PX));
        make.bottom.equalTo(self.contentView);
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

- (UIImageView *)accessoryImageView {
    if (_accessoryImageView == nil) {
        _accessoryImageView = [[UIImageView alloc] init];
        [_accessoryImageView setImage:[UIImage easeUIImageNamed:@"jh_right_access"]];
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _accessoryImageView;
}


@end
