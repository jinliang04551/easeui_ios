//
//  EaseSearchViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/13.
//  Copyright © 2022 djp. All rights reserved.
//

#import "EaseSearchViewController.h"
#import "EaseHeaders.h"


@interface EaseSearchViewController ()

@end

@implementation EaseSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#if EaseIMKit_JiHuApp
    self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
#else
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
#endif

    
    self.searchBar = [[EaseSearchBar alloc] init];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    [self.searchBar Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    self.tableView.rowHeight = 74;
    [self.tableView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.searchBar.ease_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.searchResults = [[NSMutableArray alloc] init];
    self.searchResultTableView = [[UITableView alloc] init];
    self.searchResultTableView.tableFooterView = [[UIView alloc] init];
    self.searchResultTableView.rowHeight = self.tableView.rowHeight;
    self.searchResultTableView.delegate = self;
    self.searchResultTableView.dataSource = self;
}

- (void)dealloc
{
    [[EaseRealtimeSearch shared] realtimeSearchStop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarShouldBeginEditing:(EaseSearchBar *)searchBar
{
    if (!self.isSearching) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.isSearching = YES;
        [self.view addSubview:self.searchResultTableView];
        [self.searchResultTableView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.searchBar.ease_bottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        
        
        [self.view addSubview:self.noDataPromptView];
        [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).offset(60.0);
            make.centerX.left.right.equalTo(self.view);
        }];
    }
}


- (void)searchBarCancelButtonAction:(EaseSearchBar *)searchBar
{
    [[EaseRealtimeSearch shared] realtimeSearchStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isSearching = NO;
    
    [self.searchResults removeAllObjects];
    [self.searchResultTableView reloadData];
    [self.searchResultTableView removeFromSuperview];
    [self.noDataPromptView removeFromSuperview];

}

- (void)searchBarSearchButtonClicked:(EaseSearchBar *)searchBar
{
    
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    
}

#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    if (!self.isSearching) {
        return;
    }
    
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(-keyBoardHeight);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    if (!self.isSearching) {
        return;
    }
    
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}


#pragma mark getter and setter
- (EaseSearchNoDataView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = EaseSearchNoDataView.new;
        [_noDataPromptView.noDataImageView setImage:[UIImage easeUIImageNamed:@"ji_search_nodata"]];
        _noDataPromptView.prompt.text = @"搜索无结果";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}


@end
