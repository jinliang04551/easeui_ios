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
    
    [self setRightNavBarItemTitleColor];
}



}

- (void)addPopBackLeftItemWithTarget:(id _Nullable )aTarget
                              action:(SEL _Nullable )aAction
{
    

if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage easeUIImageNamed:@"jh_backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:aTarget action:aAction];
}else {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage easeUIImageNamed:@"yg_backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:aTarget action:aAction];
    
    [self setRightNavBarItemTitleColor];
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

- (void)setRightNavBarItemTitleColor {
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:EaseIMKit_TitleBlueColor, NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];
}


- (UIView *)customNavWithTitle:(NSString *)title
              rightBarIconName:(NSString *)rightBarIconName
                 rightBarTitle:(NSString *)rightBarTitle
                rightBarAction:(SEL)rightBarAction {
    
    UIView *contentView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:18];

    UIButton *backImageBtn = [[UIButton alloc]init];
    [backImageBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *rightImageBtn = [[UIButton alloc]init];
    [rightImageBtn addTarget:self action:rightBarAction forControlEvents:UIControlEventTouchUpInside];

    
    [contentView addSubview:titleLabel];
    [contentView addSubview:backImageBtn];
    
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
    
    if (rightBarIconName.length > 0) {
        [contentView addSubview:rightImageBtn];
        [rightImageBtn setImage:[UIImage easeUIImageNamed:rightBarIconName] forState:UIControlStateNormal];
        
        [rightImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@35);
            make.centerY.equalTo(titleLabel);
            make.right.equalTo(contentView).offset(-16);
        }];

    }
    
    if (rightBarTitle.length > 0) {
        [contentView addSubview:rightImageBtn];
        rightImageBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [rightImageBtn setTitle:rightBarTitle forState:UIControlStateNormal];
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            [rightImageBtn setTitleColor:[UIColor colorWithHexString:@"#4798CB"] forState:UIControlStateNormal];
        }else {
            [rightImageBtn setTitleColor:EaseIMKit_TitleBlueColor forState:UIControlStateNormal];
        }
        
        [rightImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@35);
            make.centerY.equalTo(titleLabel);
            make.right.equalTo(contentView).offset(-16);
        }];

        
    }
    

    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        titleLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"jh_backleft"] forState:UIControlStateNormal];
    }else {
        titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"yg_backleft"] forState:UIControlStateNormal];
    }
    return contentView;
}


#pragma mark private method
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
