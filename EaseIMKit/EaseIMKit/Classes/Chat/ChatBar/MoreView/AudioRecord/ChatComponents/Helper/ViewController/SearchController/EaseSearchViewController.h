//
//  EaseSearchViewController.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/13.
//  Copyright © 2022 djp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseRefreshViewController.h"
#import "EaseSearchBar.h"
#import "EaseRealtimeSearch.h"
#import "EaseSearchNoDataView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseSearchViewController : EaseRefreshViewController<EaseSearchBarDelegate>

@property (nonatomic) BOOL isSearching;

@property (nonatomic, strong) EaseSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) UITableView *searchResultTableView;

@property (nonatomic, strong) EaseSearchNoDataView *noDataPromptView;

- (void)keyBoardWillShow:(NSNotification *)note;

- (void)keyBoardWillHide:(NSNotification *)note;

@end

NS_ASSUME_NONNULL_END

