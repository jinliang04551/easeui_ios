//
//  EBDefaultBannerView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/9/5.
//

#import "EBDefaultBannerView.h"
#import "EaseHeaders.h"
#import "UserInfoStore.h"

#define kIconImageHeight 20.0

@interface EBDefaultBannerView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;
@end


@implementation EBDefaultBannerView
- (instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {

        [self placeAndLayoutSubViews];
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            self.contentView.backgroundColor = EaseIMKit_ViewBgBlackColor;
            self.timeLabel.textColor = [UIColor colorWithHexString:@"#141414"];
            self.nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
            self.contentLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];

        }else {
            self.timeLabel.textColor = [UIColor colorWithHexString:@"#141414"];
            self.nameLabel.textColor = [UIColor colorWithHexString:@"#141414"];
            self.contentLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];

        }
    }
    return self;
}


- (void)tapAction {
    if (self.tapCellBlock) {
        self.tapCellBlock();
    }
}

- (void)placeAndLayoutSubViews {
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}


#pragma mark getter and setter
- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc]init];
        
        [_contentView addSubview:self.iconImageView];
        [_contentView addSubview:self.timeLabel];
        [_contentView addSubview:self.nameLabel];
        [_contentView addSubview:self.contentLabel];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(12.0);
            make.left.equalTo(_contentView).offset(16.0);
            make.size.equalTo(@(kIconImageHeight));
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView.mas_right).offset(16.0);
            make.right.equalTo(_contentView).offset(-16.0);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).offset(12.0);
            make.left.equalTo(self.iconImageView);
            make.right.equalTo(_contentView).offset(-16.0);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(4.0);
            make.left.equalTo(self.iconImageView);
            make.right.equalTo(_contentView).offset(-16.0);
        }];

    }
    return _contentView;
}

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.layer.cornerRadius = kIconImageHeight * 0.5;
    }
    return _iconImageView;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = EaseIMKit_NFont(12.0);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _timeLabel;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = EaseIMKit_BFont(14.0);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nameLabel;
}


- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = EaseIMKit_NFont(14.0);
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _contentLabel;
}


- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}


@end

#undef kIconImageHeight

