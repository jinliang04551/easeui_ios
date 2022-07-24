//
//  EaseIMKitAppStyle.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/24.
//

#import "EaseIMKitAppStyle.h"
#import "EaseHeaders.h"

@implementation EaseIMKitAppStyle
+ (instancetype)shareAppStyle {
    static EaseIMKitAppStyle *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = EaseIMKitAppStyle.new;
    });
    
    return instance;
}


- (void)defaultStyle {
//    //UITabBarItem
//    [UITabBarItem.appearance setTitleTextAttributes:@{
//                                                      NSFontAttributeName : EaseIMKit_NFont(12.0f),
//                                                      NSForegroundColorAttributeName : EaseIMKit_COLOR_HEX(0x000000)
//                                                      } forState:UIControlStateNormal];
//    [UITabBarItem.appearance setTitleTextAttributes:@{
//                                                      NSFontAttributeName : EaseIMKit_NFont(12.0f),
//                                                      NSForegroundColorAttributeName : EaseIMKit_COLOR_HEX(0x114EFF)
//                                                      } forState:UIControlStateSelected];

    //去黑线
//    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
//    [UITabBar appearance].layer.borderWidth = 0.0f;
//    [UITabBar appearance].clipsToBounds = YES;
//    [[UITabBar appearance] setTranslucent:YES];

    
}

@end
