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
    
    return [self customNavWithTitle:title isRootNav:NO rightBarIconName:rightBarIconName rightBarTitle:rightBarTitle rightBarAction:rightBarAction];
    
}


- (UIView *)customRootNavWithTitle:(NSString *)title
                  rightBarIconName:(NSString *)rightBarIconName
                     rightBarTitle:(NSString *)rightBarTitle
                    rightBarAction:(SEL)rightBarAction {
    return [self customNavWithTitle:title isRootNav:YES rightBarIconName:rightBarIconName rightBarTitle:rightBarTitle rightBarAction:rightBarAction];
}


- (UIView *)customNavWithTitle:(NSString *)title
                     isRootNav:(BOOL)isRootNav
              rightBarIconName:(NSString *)rightBarIconName
                 rightBarTitle:(NSString *)rightBarTitle
                rightBarAction:(SEL)rightBarAction {
    //44.0
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_NavBarAndStatusBarHeight)];
//    [contentView addTransitionColorLeftToRight:UIColor.whiteColor endColor:EaseIMKit_COLOR_HEX(0xD9D9D9)];
  
    [contentView addTransitionColorLeftToRight:UIColor.whiteColor endColor:EaseIMKit_NavBgColor];

    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:16.0];

    UIButton *backImageBtn = [[UIButton alloc]init];
    [backImageBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *rightImageBtn = [[UIButton alloc]init];
    [rightImageBtn addTarget:self action:rightBarAction forControlEvents:UIControlEventTouchUpInside];

    [contentView addSubview:titleLabel];
   
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(EaseIMKit_StatusBarHeight);
        make.centerX.equalTo(contentView);
        make.height.equalTo(@25);
    }];

    if (!isRootNav) {
        [contentView addSubview:backImageBtn];
        [backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@35);
            make.centerY.equalTo(titleLabel);
            make.left.equalTo(contentView).offset(16);
        }];
    }
    
   
    
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

//运管群聊nav
- (UIView *)customNavWithTitle:(NSString *)title
                   isNoDisturb:(BOOL)isNoDisturb
                   groupIdInfo:(NSString *)groupIdInfo
              rightBarIconName:(NSString *)rightBarIconName
                rightBarAction:(SEL)rightBarAction {
    //Height:52.0
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_StatusBarHeight + 52.0)];

    [contentView addTransitionColorLeftToRight:UIColor.whiteColor endColor:EaseIMKit_NavBgColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];

    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.hidden = !isNoDisturb;
    
    UILabel *groupIdLabel = [[UILabel alloc] init];
    groupIdLabel.text = groupIdInfo;
    groupIdLabel.font = [UIFont systemFontOfSize:12];
    groupIdLabel.textColor = [UIColor colorWithHexString:@"#A5A5A5"];
    
    UIButton *backImageBtn = [[UIButton alloc]init];
    [backImageBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];

    UIButton *rightImageBtn = [[UIButton alloc]init];
    [rightImageBtn setImage:[UIImage easeUIImageNamed:rightBarIconName] forState:UIControlStateNormal];
    [rightImageBtn addTarget:self action:rightBarAction forControlEvents:UIControlEventTouchUpInside];

    [contentView addSubview:titleLabel];
    [contentView addSubview:iconImageView];
    [contentView addSubview:groupIdLabel];
    [contentView addSubview:backImageBtn];
    [contentView addSubview:rightImageBtn];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(EaseIMKit_StatusBarHeight+8.0);
        make.height.equalTo(@(16.0));
    }];

    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.width.height.equalTo(@(20.0));
        make.left.equalTo(titleLabel.mas_right).offset(8.0);
    }];
    
    [groupIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4.0);
        make.centerX.equalTo(contentView);
        make.height.equalTo(@(16.0));
    }];
    
    [backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.top.equalTo(contentView).offset(EaseIMKit_StatusBarHeight);
        make.left.equalTo(contentView).offset(16);
    }];
    
    
    [rightImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(backImageBtn);
        make.centerY.equalTo(backImageBtn);
        make.right.equalTo(contentView).offset(-16);
    }];
    
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [iconImageView setImage:[UIImage easeUIImageNamed:@"jh_undisturbRing"]];

        titleLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"jh_backleft"] forState:UIControlStateNormal];
    }else {
        [iconImageView setImage:[UIImage easeUIImageNamed:@"yg_undisturbRing"]];

        titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"yg_backleft"] forState:UIControlStateNormal];
    }
        
    return contentView;
}



#pragma mark private method
- (void)backAction {
    if (self.navigationController == nil) {
        
    }else {
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
