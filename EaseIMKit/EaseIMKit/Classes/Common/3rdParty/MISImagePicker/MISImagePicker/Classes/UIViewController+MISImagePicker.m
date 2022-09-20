//
//  UIViewController+MISHUD.m
//  MIS
//
//  Created by mao on 1/24/15.
//  Copyright (c) 2015 EDU. All rights reserved.
//

#import "UIViewController+MISImagePicker.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation UIViewController(MISImagePicker)

- (void)mis_imgpk_showWait {
	UIView *viewToRemove = nil;
	for (UIView *v in [self.view subviews]) {
		if ([v isKindOfClass:[MBProgressHUD class]]) {
			viewToRemove = v;
		}
	}
	if (viewToRemove != nil) {
		MBProgressHUD *hud = (MBProgressHUD *)viewToRemove;
		hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES];
	}
	
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
	hud.label.text = @"加载中...";
	hud.mode = MBProgressHUDModeIndeterminate;
	
	[self.view addSubview:hud];
    [hud showAnimated:YES];
}


- (void)mis_imgpk_hideWait {
	UIView *viewToRemove = nil;
	for (UIView *v in [self.view subviews]) {
		if ([v isKindOfClass:[MBProgressHUD class]]) {
			viewToRemove = v;
		}
	}
	if (viewToRemove != nil) {
		MBProgressHUD *hud = (MBProgressHUD *)viewToRemove;
		hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES];
	}
}

@end
