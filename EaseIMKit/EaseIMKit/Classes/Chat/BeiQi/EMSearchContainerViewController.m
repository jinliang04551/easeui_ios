//
//  EMSearchContainerViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/11.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "EMSearchContainerViewController.h"
#import "MISScrollPage.h"
#import "EaseHeaders.h"

@interface EMSearchContainerViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>

@end

@implementation EMSearchContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    }else {
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }
    
}



#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{

}

- (void)viewDidAppearForIndex:(NSUInteger)index{
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    if (index == 0) {
        self.editing = NO;
        [self.searchBar.textField resignFirstResponder];
    }
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{

}


@end
