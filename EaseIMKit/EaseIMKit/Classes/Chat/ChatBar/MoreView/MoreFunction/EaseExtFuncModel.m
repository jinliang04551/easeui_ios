//
//  EaseExtFuncModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/12/7.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EaseExtFuncModel.h"
#import "UIColor+EaseUI.h"
#import "EaseHeaders.h"

@implementation EaseExtFuncModel

- (instancetype)init
{
    if (self = [super init]) {

#if EaseIMKit_JiHuApp
        _iconBgColor = [UIColor clearColor];
        _viewBgColor = [UIColor colorWithHexString:@"#F2F2F2"];
        _fontColor = [UIColor colorWithHexString:@"#B9B9B9"];
#else
        _iconBgColor = [UIColor whiteColor];
        _viewBgColor = [UIColor colorWithHexString:@"#F2F2F2"];
        _fontColor = [UIColor colorWithHexString:@"#999999"];
#endif
        
        _fontSize = 12;
        _collectionViewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    }
    return self;
}

- (void)setIconBgColor:(UIColor *)iconBgColor
{
    if (iconBgColor) {
        _iconBgColor = iconBgColor;
    }
}

- (void)setViewBgColor:(UIColor *)viewBgColor
{
    if (viewBgColor) {
        _viewBgColor = viewBgColor;
    }
}

- (void)setFontColor:(UIColor *)fontColor
{
    if (fontColor) {
        _fontColor = fontColor;
    }
}

- (void)setFontSize:(CGFloat)fontSize
{
    if (fontSize) {
        _fontSize = fontSize;
    }
}

- (void)setCollectionViewSize:(CGSize)collectionViewSize
{
    _collectionViewSize = collectionViewSize;
}

@end
