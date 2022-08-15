//
//  BQGroupATMemberViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQGroupATMemberViewController.h"
#import "EMRealtimeSearch.h"
#import "EaseSearchBar.h"
#import "EaseGroupAtCell.h"
#import "EaseSearchNoDataView.h"
#import "EaseIMKitManager.h"
#import "EaseNoDataPlaceHolderView.h"
#import "EMSearchBar.h"

@interface BQGroupATMemberViewController ()<EMSearchBarDelegate>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) EaseNoDataPlaceHolderView *noDataPromptView;
@property (nonatomic, strong) EMSearchBar  *searchBar;
@property (nonatomic) BOOL isSearching;
@property (nonatomic, strong) EaseGroupAtCell *allCell;
@property (nonatomic, assign) BOOL isOwner;


@end

@implementation BQGroupATMemberViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        self.isOwner = (self.group.permissionType == EMGroupPermissionTypeOwner) ? YES : NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
if (EaseIMKitManager.shared.isJiHuApp){
    self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    self.tableView.backgroundColor = EaseIMKit_ViewBgBlackColor;
    self.tableView.backgroundColor = EaseIMKit_ViewBgBlackColor;
}else {
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    self.tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    self.tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;

}

    [self.tableView registerClass:[EaseGroupAtCell class] forCellReuseIdentifier:NSStringFromClass([EaseGroupAtCell class])];
    [self.tableView registerClass:[EaseGroupAtCell class] forCellReuseIdentifier:NSStringFromClass([EaseGroupAtCell class])];

    
    [self _setupSubviews];
    [self _fetchGroupMembersWithIsHeader:YES isShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
//    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    
    self.title = @"选择提醒人";
    
    self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];


    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view).offset(16.0);
        make.right.equalTo(self.view).offset(-16.0);
        make.height.equalTo(@(32.0));
    }];


    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(8.0);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.view addSubview:self.noDataPromptView];
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(60.0);
        make.centerX.left.right.equalTo(self.view);
    }];

    

    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 64.0;
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return [self.searchResultArray count];
    } else {
        if (self.isOwner) {
            return [self.dataArray count] + 1;
        }else {
            return [self.dataArray count];
        }
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    EaseGroupAtCell *cell = (EaseGroupAtCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EaseGroupAtCell class])];
    
    NSString *userId = @"";
    
    if (self.isSearching) {
        userId = [self.searchResultArray objectAtIndex:indexPath.row];
    } else {
        if (self.isOwner) {

            if (indexPath.row == 0) {
                return self.allCell;
            }else {
                userId = [self.dataArray objectAtIndex:indexPath.row -1];
            }
            
        }else {
            userId = [self.dataArray objectAtIndex:indexPath.row];
        }
    
    }
    [cell updateWithObj:userId];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *name = nil;
    if (self.isSearching) {
        name = [self.searchResultArray objectAtIndex:indexPath.row];
    } else {
        if (self.isOwner) {

            if (indexPath.row == 0) {
                name = @"ALL";
            }else {
                name = [self.dataArray objectAtIndex:indexPath.row-1];
            }
        }else {
            name = [self.dataArray objectAtIndex:indexPath.row];
        }
    
    }
    
    if (self.selectedAtMemberBlock) {
        self.selectedAtMemberBlock(name);
    }
    
    [self backAction];
}

#pragma mark - EMSearchBarDelegate
- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
{
    self.isSearching = YES;
}

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isSearching = NO;
    
    self.noDataPromptView.hidden = YES;
    [self.searchResultArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}


- (void)searchTextDidChangeWithString:(NSString *)aString {
    
    EaseIMKit_WS
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.noDataPromptView.hidden = results.count > 0 ? YES : NO;
            [weakSelf.searchResultArray removeAllObjects];
            [weakSelf.searchResultArray addObjectsFromArray:results];
            [weakSelf.tableView reloadData];
            
        });
    }];

    
}

#pragma mark - Data

- (void)_fetchGroupMembersWithIsHeader:(BOOL)aIsHeader
                             isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchGroupMember...", nil)];
    }
    
    __weak typeof(self) weakself = self;
    void (^errorBlock)(EMError *aError) = ^(EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        [EaseAlertController showErrorAlert:aError.errorDescription];
    };
    
    void (^fetchMembersBlock) (void) = ^(void) {
        [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:weakself.group.groupId cursor:weakself.cursor pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
            if (aError) {
                errorBlock(aError);
                return ;
            }
            
            if (aIsShowHUD) {
                [weakself hideHud];
            }
            weakself.cursor = aResult.cursor;
            [weakself.dataArray addObjectsFromArray:aResult.list];
            [weakself.dataArray removeObject:[EMClient sharedClient].currentUsername];
            
            if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
                weakself.showRefreshFooter = NO;
            } else {
                weakself.showRefreshFooter = YES;
            }
            
            [weakself.tableView reloadData];
            [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        }];
    };
    
    if (aIsHeader) {
        [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            if (aError) {
                errorBlock(aError);
                return ;
            }
            
            weakself.group = aGroup;
            [weakself.dataArray removeAllObjects];
            [weakself.dataArray addObject:aGroup.owner];
            [weakself.dataArray addObjectsFromArray:aGroup.adminList];
            fetchMembersBlock();
        }];
    } else {
        fetchMembersBlock();
    }
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = nil;
    [self _fetchGroupMembersWithIsHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self _fetchGroupMembersWithIsHeader:NO isShowHUD:NO];
}

#pragma mark - Action
- (void)backAction {
    [[EMRealtimeSearch shared] realtimeSearchStop];
    [self.navigationController popViewControllerAnimated:YES];
}


- (EaseNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = EaseNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:[UIImage easeUIImageNamed:@"ji_search_nodata"]];
        _noDataPromptView.prompt.text = @"搜索无结果";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (NSMutableArray *)searchResultArray {
    if (_searchResultArray == nil) {
        _searchResultArray = [NSMutableArray array];
    }
    return _searchResultArray;
}
- (EaseGroupAtCell *)allCell {
    if (_allCell == nil) {
        _allCell = [[EaseGroupAtCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([EaseGroupAtCell class])];
        [_allCell updateWithObj:@"所有人"];
    }
    return _allCell;
}

@end
