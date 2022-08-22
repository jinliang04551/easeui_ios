//
//  EaseCallPlaceholderView.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/12/9.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallPlaceholderView.h"
#import <Masonry/Masonry.h>
#import "UIImage+Ext.h"
#import "EaseHeaders.h"

@interface EaseCallPlaceholderView ()
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIView *coverView;

@end

@implementation EaseCallPlaceholderView

- (instancetype)init
{
    self = [super init];
    if(self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.placeHolderImageView];
        [self.placeHolderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        
//        _activity = [[UIActivityIndicatorView alloc] init];
//        if(@available(iOS 13.0, *)) {
//            _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
//        }else{
//            _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//        }
        [self addSubview:self.loadingImageView];
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            make.size.equalTo(@(40.0));
        }];
        
    }
    return self;
}


- (UIImageView *)loadingImageView {
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc]init];
        _loadingImageView.animationDuration = 1.0;
        
        NSMutableArray *tArray = [NSMutableArray array];

        for (int i = 1; i < 4; ++i) {
            UIImage *image = [UIImage imageNamedFromBundle:[NSString stringWithFormat:@"call_loading_%@",[@(i) stringValue]]];
            [tArray addObject:image];
        }
        
        _loadingImageView.animationImages = tArray;
        _loadingImageView.animationRepeatCount = 0;
        [_loadingImageView startAnimating];
    }
    return _loadingImageView;
}

- (UIImageView *)placeHolderImageView {
    if (_placeHolderImageView == nil) {
        _placeHolderImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamedFromBundle:@"call_default_user_icon"];
        _placeHolderImageView.image = image;

        [_placeHolderImageView addSubview:self.coverView];
        [_placeHolderImageView addSubview:self.nameLabel];

        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_placeHolderImageView);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_placeHolderImageView).offset(-5);
            make.left.equalTo(_placeHolderImageView).offset(16.0);
            make.width.equalTo(_placeHolderImageView);
            make.height.equalTo(@30);
        }];

        
    }
    return _placeHolderImageView;
}



- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor colorWithHexString:@"#141414"];
        _coverView.alpha = 0.75;
    }
    return _coverView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}



@end
