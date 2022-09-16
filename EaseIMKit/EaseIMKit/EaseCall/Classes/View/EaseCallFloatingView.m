//
//  EaseCallFloatingView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/23.
//

#import "EaseCallFloatingView.h"
#import "EaseHeaders.h"
#import "UIImage+Ext.h"


@interface EaseCallFloatingView()
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation EaseCallFloatingView
- (instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    [self addSubview:self.contentBgView];
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}



- (void)tapAction {
    if (self.tapViewBlock) {
        self.tapViewBlock();
    }
}

#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [_iconImageView setImage:[UIImage imageNamedFromBundle:@"floating_voice"]];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
    }
    return _nameLabel;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.backgroundColor = [UIColor colorWithHexString:@"#1C1C1C"];
       
        [_contentView addSubview:self.iconImageView];
        [_contentView addSubview:self.nameLabel];

        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(8.0);
            make.size.equalTo(@(28.0));
            make.centerX.equalTo(_contentView);

        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView.mas_bottom).offset(4.0);
            make.centerX.equalTo(_contentView);
            make.left.right.equalTo(_contentView);
            
        }];
    }
    return _contentView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}

- (UIView *)contentBgView {
    if (_contentBgView == nil) {
        _contentBgView = [[UIView alloc] init];
        
        _contentBgView.backgroundColor = [UIColor colorWithHexString:@"#252525"];
        _contentBgView.layer.cornerRadius = 4.0;
        _contentBgView.layer.borderColor = [UIColor colorWithHexString:@"#2D2C2C"].CGColor;
        _contentBgView.layer.borderWidth = 1.0;
        
        [_contentBgView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_contentBgView).insets(UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0));
        }];
    }
    return _contentBgView;
}


@end
