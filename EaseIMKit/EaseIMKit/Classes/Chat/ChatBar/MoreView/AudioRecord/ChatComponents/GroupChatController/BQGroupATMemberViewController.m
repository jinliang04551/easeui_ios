//
//  BQGroupATMemberViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQGroupATMemberViewController.h"
#import "EaseRealtimeSearch.h"
#import "EaseSearchBar.h"
#import "EaseGroupAtCell.h"
#import "EaseSearchNoDataView.h"
#import "EaseIMKitManager.h"


@interface BQGroupATMemberViewController ()<EaseSearchBarDelegate>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation BQGroupATMemberViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
if (EaseIMKitManager.shared.isJiHuApp){
    self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    self.tableView.backgroundColor = EaseIMKit_ViewBgBlackColor;
    self.searchResultTableView.backgroundColor = EaseIMKit_ViewBgBlackColor;
}else {
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    self.tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    self.searchResultTableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;

}

    
    
    [self.tableView registerClass:[EaseGroupAtCell class] forCellReuseIdentifier:NSStringFromClass([EaseGroupAtCell class])];
    [self.searchResultTableView registerClass:[EaseGroupAtCell class] forCellReuseIdentifier:NSStringFromClass([EaseGroupAtCell class])];

    
    [self _setupSubviews];
    [self _fetchGroupMembersWithIsHeader:YES isShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
//    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    
    self.title = @"选择提醒人";
    
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 64.0;
    
}


//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
//}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [self.dataArray count];
    } else {
        return [self.searchResults count];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    EaseGroupAtCell *cell = (EaseGroupAtCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EaseGroupAtCell class])];
    
    NSString *userId = @"";
    
    if (tableView == self.tableView) {
        userId = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        userId = [self.searchResults objectAtIndex:indexPath.row];
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
    if (tableView == self.tableView) {
        name = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        name = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    if (self.selectedAtMemberBlock) {
        self.selectedAtMemberBlock(name);
    }
    
    [self backAction];
}

#pragma mark - EMSearchBarDelegate

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakself = self;
    [[EaseRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.noDataPromptView.hidden = results.count > 0 ? YES : NO;
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself.searchResultTableView reloadData];
            
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

- (void)backAction
{
    [[EaseRealtimeSearch shared] realtimeSearchStop];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
