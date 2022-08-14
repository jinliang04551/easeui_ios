//
//  Util.m
//  EaseIM
//
//  Created by liu001 on 2022/7/22.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "EaseKitUtil.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EaseIMKitOptions.h"
#import "EaseHeaders.h"

@implementation EaseKitUtil

+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font {
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:content attributes:
        @{NSForegroundColorAttributeName:color,
          NSFontAttributeName:font
        }];
    return attrString;
}

+ (void)saveLoginUserToken:(NSString *)token userId:(NSString *)userId {

    NSString *key = [NSString stringWithFormat:@"login_token_%@",userId];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


+ (NSString *)getLoginUserToken {

    NSString *key = [NSString stringWithFormat:@"login_token_%@",[EMClient sharedClient].currentUsername];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (token == nil) {
        token = @"";
    }
    return token;
    
}

+ (void )removeLoginUserToken {
    NSString *key = [NSString stringWithFormat:@"login_token_%@",[EMClient sharedClient].currentUsername];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


+ (UIView *)customNavViewWithTitle:(NSString *)title backAction:(SEL)backAction {
    UIView *contentView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:18];

    UIButton *backImageBtn = [[UIButton alloc]init];
    [backImageBtn addTarget:self action:backAction forControlEvents:UIControlEventTouchUpInside];

    [contentView addSubview:titleLabel];
    [contentView addSubview:backImageBtn];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        titleLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"jh_backleft"] forState:UIControlStateNormal];
    }else {
        titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"yg_backleft"] forState:UIControlStateNormal];
    }
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.centerY.equalTo(contentView);
        make.height.equalTo(@25);
    }];

    
    [backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.centerY.equalTo(titleLabel);
        make.left.equalTo(contentView).offset(16);
    }];
    
    return contentView;
}


+ (UIViewController*)atPersentViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
         
        
        return [self atPersentViewController:vc.presentedViewController];
         
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
         
        
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self atPersentViewController:svc.viewControllers.lastObject];
        else
            return vc;
         
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
         
        
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self atPersentViewController:svc.topViewController];
        else
            return vc;
         
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
         
        
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self atPersentViewController:svc.selectedViewController];
        else
            return vc;
         
    } else {
        return vc;
         
    }
     
}

+ (UIViewController*)currentViewController {
    
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self atPersentViewController:viewController];
     
}

@end
