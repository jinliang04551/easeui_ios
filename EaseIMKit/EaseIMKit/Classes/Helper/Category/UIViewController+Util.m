//
//  UIViewController+Util.m
//  dxstudio
//
//  Created by XieYajie on 25/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import "UIViewController+Util.h"
#import "EaseIMKitOptions.h"
#import "EaseHeaders.h"

@implementation UIViewController (Util)

- (void)addPopBackLeftItem
{

if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage easeUIImageNamed:@"jh_backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBackLeftItemAction)];
}else {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage easeUIImageNamed:@"yg_backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBackLeftItemAction)];
}



}

- (void)addPopBackLeftItemWithTarget:(id _Nullable )aTarget
                              action:(SEL _Nullable )aAction
{
    

if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage easeUIImageNamed:@"jh_backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:aTarget action:aAction];
}else {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"yg_backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:aTarget action:aAction];
}

}

- (void)addKeyboardNotificationsWithShowSelector:(SEL)aShowSelector
                                    hideSelector:(SEL)aHideSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aShowSelector name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aHideSelector name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)popBackLeftItemAction
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertControllerWithMessage:(NSString *)aMsg title:(NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:handler];
    [alertController addAction:okAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}



@end
