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

    
}


- (void)updateNavAndTabbarWithIsJihuApp:(BOOL)isJihuApp {
    if (isJihuApp) {
        [UINavigationBar appearance].barStyle = UIBarStyleBlack;
        [UINavigationBar appearance].translucent = NO;
        [UINavigationBar appearance].tintColor = EaseIMKit_ViewBgBlackColor;
        [[UINavigationBar appearance] setBarTintColor:EaseIMKit_ViewBgBlackColor];
        
        [[UINavigationBar appearance] setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#F5F5F5"], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16.0], NSFontAttributeName, nil]];
    }else {
//        [[UINavigationBar appearance] setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16.0], NSFontAttributeName, nil]];
//
////        [[UINavigationBar appearance] setBackgroundImage:[UIImage easeUIImageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
        
        [UINavigationBar appearance].barStyle = UIBarStyleDefault;
        [UINavigationBar appearance].translucent = NO;
        [UINavigationBar appearance].tintColor = EaseIMKit_ViewBgWhiteColor;
        [[UINavigationBar appearance] setBarTintColor:EaseIMKit_ViewBgWhiteColor];

        [[UINavigationBar appearance] setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#171717"], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16.0], NSFontAttributeName, nil]];
        
        
//        [[UINavigationBar appearance] setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16.0], NSFontAttributeName, nil]];
        
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage easeUIImageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance].layer setMasksToBounds:YES];
        [UINavigationBar appearance].backgroundColor = [UIColor whiteColor];
    }
    
}



@end
