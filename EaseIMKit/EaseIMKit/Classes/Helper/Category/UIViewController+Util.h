//
//  UIViewController+Util.h
//  dxstudio
//
//  Created by XieYajie on 25/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Util)

//@property (nonatomic, strong) UIView *titleView;


- (void)addPopBackLeftItem;

- (void)addPopBackLeftItemWithTarget:(id _Nullable )aTarget
                              action:(SEL _Nullable )aAction;

- (void)addKeyboardNotificationsWithShowSelector:(SEL _Nullable )aShowSelector
                                    hideSelector:(SEL _Nullable )aHideSelector;

- (void)removeKeyboardNotifications;


- (void)showAlertControllerWithMessage:(NSString *)aMsg title:(NSString*)title handler:(void (^ __nullable)(UIAlertAction *action))handler;

- (void)setRightNavBarItemTitleColor;


- (UIView *)customNavWithTitle:(NSString *)title
              rightBarIconName:(NSString *)rightBarIconName
                 rightBarTitle:(NSString *)rightBarTitle
                rightBarAction:(SEL)rightBarAction;

- (UIView *)customNavWithTitle:(NSString *)title
                   isNoDisturb:(BOOL)isNoDisturb
                   groupIdInfo:(NSString *)groupIdInfo
              rightBarIconName:(NSString *)rightBarIconName
                rightBarAction:(SEL)rightBarAction;

@end
