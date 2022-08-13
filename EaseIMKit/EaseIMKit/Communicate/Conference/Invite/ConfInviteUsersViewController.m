//
//  ConfInviteUsersViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "ConfInviteUsersViewController.h"

#import "EMRealtimeSearch.h"
#import "ConferenceController.h"
//#import "YGGroupMuteItemCell.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "BQConfInviteSelectedUsersView.h"
#import "EaseHeaders.h"
#import "YGGroupMuteItemCell.h"
#import "EaseIMKitManager.h"
#import "EMSearchBar.h"

@interface ConfInviteUsersViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,EMSearchBarDelegate>

@property (nonatomic, strong) UIView *customNavBarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic) BOOL isCreate;
@property (nonatomic) ConfInviteType type;
@property (nonatomic, strong) NSArray *excludeUsers;
@property (nonatomic, strong) NSString *gorcId;

@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, strong) EMSearchBar  *searchBar;
@property (nonatomic) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray *searchDataArray;
@property (nonatomic, strong) NSMutableArray *inviteUsers;

@property (nonatomic, strong) BQConfInviteSelectedUsersView *confInviteSelectedUsersView;


@end



@implementation ConfInviteUsersViewController

- (instancetype)initWithType:(ConfInviteType)aType
                    isCreate:(BOOL)aIsCreate
                excludeUsers:(NSArray *)aExcludeUsers
           groupOrChatroomId:(NSString *)aGorcId
{
    self = [super init];
    if (self) {
        _type = aType;
        _isCreate = aIsCreate;
        _excludeUsers = aExcludeUsers;
        _gorcId = aGorcId;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchDataArray = [[NSMutableArray alloc] init];
    self.inviteUsers = [[NSMutableArray alloc] init];
    
    if (self.isCreate) {
        self.titleLabel.text = @"选择成员";
    }else {
        self.titleLabel.text = @"添加成员";
    }
    
    [self _setupSubviews];
    
    self.showRefreshHeader = YES;
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)dealloc
{
    self.searchBar.delegate = nil;
}

#pragma mark - Subviews

- (void)_setupSubviews {

    [self.view addSubview:self.customNavBarView];
    [self.view addSubview:self.confInviteSelectedUsersView];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];


    [self.customNavBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(48.0));
    }];

    
    [self.confInviteSelectedUsersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(0));
        make.width.equalTo(@(0));
    }];
    
    
    [self.view sendSubviewToBack:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confInviteSelectedUsersView.mas_bottom).offset(8.0);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(32.0));
    }];


    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(8.0);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    
    [self updateCustomNavView];
    self.tableView.rowHeight = 64.0;
    [self.tableView registerClass:[YGGroupMuteItemCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupMuteItemCell class])];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? [self.searchDataArray count] : [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    YGGroupMuteItemCell *cell = (YGGroupMuteItemCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YGGroupMuteItemCell class])];
    
    NSString *username = self.isSearching ? [self.searchDataArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    BOOL isChecked = [self userIsChecked:username];

    [cell updateWithObj:username isChecked:isChecked];
    
    EaseIMKit_WS
    cell.checkBlcok = ^(NSString * _Nonnull userId, BOOL isChecked) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.inviteUsers containsObject:username]) {
                [weakSelf.inviteUsers removeObject:username];
            } else {
                [weakSelf.inviteUsers addObject:username];
            }
            
            [self updateUI];
        });
    };
    return cell;
}

- (BOOL)userIsChecked:(NSString *)userId {
    return [self.inviteUsers containsObject:userId];
}


- (void)updateUI {
    
    CGFloat inviteHeight = self.inviteUsers.count > 0 ? 70 : 0;
    CGFloat inviteWidth = self.inviteUsers.count * [BQConfInviteSelectedUsersView itemSize].width + [BQConfInviteSelectedUsersView itemSpacing] * (self.inviteUsers.count -1) + [BQConfInviteSelectedUsersView collectionLeftRightPadding] * 2;
//    if (inviteWidth >= EaseIMKit_ScreenWidth) {
//        inviteWidth = EaseIMKit_ScreenWidth;
//    }
    
    NSLog(@"%s =======width:%@ height:%@",__func__,@(inviteWidth),@(inviteHeight));
    
    [self.confInviteSelectedUsersView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(inviteHeight));
        make.width.equalTo(@(inviteWidth));

    }];
    
    
    NSString *confirmTitle = [NSString stringWithFormat:@"确定(%@)",@([self.inviteUsers count])];
    [self.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self.confInviteSelectedUsersView updateUIWithMemberArray:self.inviteUsers];
        
        [self.tableView reloadData];

    });
        
}


//#pragma mark - UISearchBarDelegate
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    [searchBar setShowsCancelButton:YES];
//    return YES;
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if (!self.isSearching) {
//        self.isSearching = YES;
//        [self.view addSubview:self.searchTableView];
//        [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.tableView);
//            make.left.equalTo(self.tableView);
//            make.right.equalTo(self.tableView);
//            make.bottom.equalTo(self.tableView);
//        }];
//    }
//
//    __weak typeof(self) weakSelf = self;
//    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:searchBar.text collationStringSelector:nil resultBlock:^(NSArray *results) {
//        if ([results count] > 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.searchDataArray removeAllObjects];
//                [weakSelf.searchDataArray addObjectsFromArray:results];
//                [self.searchTableView reloadData];
//            });
//        }
//    }];
//}
//
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if ([text isEqualToString:@"\n"]) {
//        [searchBar resignFirstResponder];
//
//        return NO;
//    }
//
//    return YES;
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    [[EMRealtimeSearch shared] realtimeSearchStop];
//    [searchBar setShowsCancelButton:NO];
//    [searchBar resignFirstResponder];
//
//    self.isSearching = NO;
//    [self.searchDataArray removeAllObjects];
//    [self.searchTableView removeFromSuperview];
//    [self.searchTableView reloadData];
//    [self.tableView reloadData];
//}

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
    
    [self.searchDataArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}


- (void)searchTextDidChangeWithString:(NSString *)aString {
    
    EaseIMKit_WS
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.searchDataArray removeAllObjects];
            [weakSelf.searchDataArray addObjectsFromArray:results];
            [self.tableView reloadData];
        });
    }];
    
    
}


- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

#pragma mark - Data

- (NSArray *)_getInvitableUsers:(NSArray *)aAllUsers
{
    NSMutableArray *retNames = [[NSMutableArray alloc] init];
    [retNames addObjectsFromArray:aAllUsers];
    
    NSString *loginName = [[EMClient sharedClient].currentUsername lowercaseString];
    if ([retNames containsObject:loginName]) {
        [retNames removeObject:loginName];
    }
    
    for (NSString *name in self.excludeUsers) {
        if ([retNames containsObject:name]) {
            [retNames removeObject:name];
        }
    }
    
    return retNames;
}

- (void)_fetchGroupMembersWithIsHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchingGroupMember...", nil)];
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.gorcId cursor:self.cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        if (aError) {
            [weakSelf hideHud];
            [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
            
            [weakSelf showHint:[[NSString alloc] initWithFormat:NSLocalizedString(@"fetchGroupMemberFail", nil), aError.errorDescription]];
            return ;
        }
        
        weakSelf.cursor = aResult.cursor;
        
        if (aIsHeader) {
            [weakSelf.dataArray removeAllObjects];
            
            EMError *error = nil;
            EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.gorcId error:&error];
            if (!error) {
                NSArray *owners = [weakSelf _getInvitableUsers:@[group.owner]];
                [weakSelf.dataArray addObjectsFromArray:owners];
                
                NSArray *admins = [weakSelf _getInvitableUsers:group.adminList];
                [weakSelf.dataArray addObjectsFromArray:admins];
            }
        }
        
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        
        NSArray *usernames = [weakSelf _getInvitableUsers:aResult.list];
        [weakSelf.dataArray addObjectsFromArray:usernames];
        [weakSelf.tableView reloadData];
        if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
            weakSelf.showRefreshFooter = NO;
        } else {
            weakSelf.showRefreshFooter = YES;
        }
    }];
}

- (void)_fetchChatroomMembersWithIsHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchingChatroomMember...", nil)];
    [[EMClient sharedClient].roomManager getChatroomMemberListFromServerWithId:self.gorcId cursor:self.cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        if (aError) {
            [weakSelf hideHud];
            [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
            
            [weakSelf showHint:[[NSString alloc] initWithFormat:NSLocalizedString(@"fetchChatroomMemberFail", nil), aError.errorDescription]];
            return ;
        }
        
        weakSelf.cursor = aResult.cursor;
        
        if (aIsHeader) {
            [weakSelf.dataArray removeAllObjects];
            
            EMError *error = nil;
            EMChatroom *chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:weakSelf.gorcId error:&error];
            if (!error) {
                NSArray *owners = [weakSelf _getInvitableUsers:@[chatroom.owner]];
                [weakSelf.dataArray addObjectsFromArray:owners];
                
                NSArray *admins = [weakSelf _getInvitableUsers:chatroom.adminList];
                [weakSelf.dataArray addObjectsFromArray:admins];
            }
        }
        
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        
        NSArray *usernames = [weakSelf _getInvitableUsers:aResult.list];
        [weakSelf.dataArray addObjectsFromArray:usernames];
        [weakSelf.tableView reloadData];
        
        if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
            self.showRefreshFooter = NO;
        } else {
            self.showRefreshFooter = YES;
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    if (self.type == ConfInviteTypeUser) {
        NSArray *usernames = [self _getInvitableUsers:[[EMClient sharedClient].contactManager getContacts]];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:usernames];
        [self.tableView reloadData];
        
        [self tableViewDidFinishTriggerHeader:YES reload:NO];
    } else if (self.type == ConfInviteTypeGroup) {
        self.cursor = @"";
        [self _fetchGroupMembersWithIsHeader:YES];
    } else if (self.type == ConfInviteTypeChatroom) {
        self.cursor = @"";
        [self _fetchChatroomMembersWithIsHeader:YES];
    }
}

- (void)tableViewDidTriggerFooterRefresh
{
    if (self.type == ConfInviteTypeGroup) {
        [self _fetchGroupMembersWithIsHeader:NO];
    } else if (self.type == ConfInviteTypeChatroom) {
        [self _fetchChatroomMembersWithIsHeader:NO];
    } else {
        [self tableViewDidFinishTriggerHeader:NO reload:NO];
    }
}

#pragma mark - Action

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmButtonAction {
    EaseIMKit_WS
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.doneCompletion) {
            weakSelf.doneCompletion(self.inviteUsers);
        }
    }];
    
}


#pragma mark getter and setter
- (BQConfInviteSelectedUsersView *)confInviteSelectedUsersView {
    if (_confInviteSelectedUsersView == nil) {
        _confInviteSelectedUsersView = [[BQConfInviteSelectedUsersView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 70.0)];
    }
    return _confInviteSelectedUsersView;
}


- (UIView *)customNavBarView {
    if (_customNavBarView == nil) {
        _customNavBarView = [[UIView alloc] init];
        _customNavBarView.backgroundColor = UIColor.clearColor;
        
        [_customNavBarView addSubview:self.titleLabel];
        [_customNavBarView addSubview:self.cancelButton];
        [_customNavBarView addSubview:self.confirmButton];
    
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_customNavBarView);
            make.centerX.equalTo(_customNavBarView);
            make.width.equalTo(@(100.0));
        }];
        
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_customNavBarView).offset(16.0);
            make.centerY.equalTo(self.titleLabel);
            make.width.equalTo(@(60.0));
        }];

        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(_customNavBarView).offset(-16.0);
            make.size.equalTo(self.cancelButton);
        }];
    }
    return _customNavBarView;
}


- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] init];
//        _cancelButton.titleLabel.font = EaseIMKit_NFont(14.0);
//        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"#B9B9B9"] forState:UIControlStateNormal];

        UILabel *tLabel = [[UILabel alloc] init];
        tLabel.font = EaseIMKit_NFont(14.0);
        tLabel.text = @"取消";
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            tLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        }else {
            tLabel.textColor = [UIColor colorWithHexString:@"#252525"];
        }
        
        tLabel.textAlignment = NSTextAlignmentLeft;
        [_cancelButton addSubview:tLabel];
        [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_cancelButton);
        }];
        
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _confirmButton.layer.cornerRadius = 4.0;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
    }
    return _confirmButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _titleLabel;
}

- (void)updateCustomNavView {
    if (EaseIMKitManager.shared.isJiHuApp){
        [self.cancelButton setTitleColor:[UIColor colorWithHexString:@"#B9B9B9"] forState:UIControlStateNormal];

        [self.titleLabel setTextColor:[UIColor whiteColor]];
        
    }else {
        [self.cancelButton setTitleColor:[UIColor colorWithHexString:@"#171717"] forState:UIControlStateNormal];

        [self.titleLabel setTextColor:[UIColor colorWithHexString:@"#171717"]];
    }
}

- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}


- (UITableView *)searchTableView {
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc] init];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.rowHeight = 64.0;
        _searchTableView.backgroundColor = EaseIMKit_ViewBgBlackColor;
    }
    return _searchTableView;
}

@end
