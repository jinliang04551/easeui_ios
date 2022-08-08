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

@interface EaseCallPlaceholderView ()
@property (nonatomic, strong) UIImageView *loadingImageView;
@end

@implementation EaseCallPlaceholderView

- (instancetype)init
{
    self = [super init];
    if(self) {
        self.backgroundColor = [UIColor blackColor];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:12.0];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.nameLabel];
        [self bringSubviewToFront:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-5);
            make.left.equalTo(self).offset(16.0);
            make.width.equalTo(self);
            make.height.equalTo(@30);
        }];
        
        self.placeHolder = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamedFromBundle:@"call_default_user_icon"];
        self.placeHolder.image = image;
        [self addSubview:self.placeHolder];
        self.placeHolder.alpha = 0.5;
        [self.placeHolder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@70);
            make.center.equalTo(self);
        }];
        
        _activity = [[UIActivityIndicatorView alloc] init];
        if(@available(iOS 13.0, *)) {
            _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
        }else{
            _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        }
        [self addSubview:_activity];
        [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _activity.hidesWhenStopped = YES;
        [_activity startAnimating];
    }
    return self;
}

- (UIImageView *)loadingImageView {
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc]init];
        _loadingImageView.animationDuration = 1;
        UIImage *img1 = [UIImage imageNamed:@"图1.tiff"];
        UIImage *img2 = [UIImage imageNamed:@"图2.tiff"];
        NSArray *array = @[img1,img2];

        _loadingImageView.animationImages = array;
        _loadingImageView.animationRepeatCount = 0;
        [_loadingImageView startAnimating];
    }
    return _loadingImageView;
}



@end
