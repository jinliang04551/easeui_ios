//
//  BQAddGroupMemberViewController.h
//  EaseIM
//
//  Created by liu001 on 2022/7/8.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSearchBar.h"
#import "EMRealtimeSearch.h"


NS_ASSUME_NONNULL_BEGIN

@interface BQGroupEditMemberViewController : UIViewController<EMSearchBarDelegate>
@property (nonatomic, copy) void (^addedMemberBlock)(NSMutableArray *userArray,NSMutableArray *serverArray);
　
@property (nonatomic) BOOL isSearching;

@property (nonatomic, strong) EMSearchBar *searchBar;

- (instancetype)initWithUserArray:(NSMutableArray *)userArray
                      serverArray:(NSMutableArray *)serverArray;

- (void)keyBoardWillShow:(NSNotification *)note;

- (void)keyBoardWillHide:(NSNotification *)note;

@end

NS_ASSUME_NONNULL_END
