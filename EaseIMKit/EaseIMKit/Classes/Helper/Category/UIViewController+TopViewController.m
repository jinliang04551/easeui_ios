//
//  UIViewController+TopViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/8.
//

#import "UIViewController+TopViewController.h"

@implementation UIViewController (TopViewController)
 
+ (UIViewController * )topViewController {
    UIViewController *resultVC;
    resultVC = [self recursiveTopViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self recursiveTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
 
+ (UIViewController * )recursiveTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self recursiveTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self recursiveTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
 


@end
