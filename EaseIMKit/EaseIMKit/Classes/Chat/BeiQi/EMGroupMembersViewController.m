//
//  EMGroupMembersViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupMembersViewController.h"
#import "UserInfoStore.h"
#import "BQAvatarTitleRoleCell.h"
#import "BQGroupEditMemberViewController.h"
#import "EaseHeaders.h"


@interface EMGroupMembersViewController ()

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, strong) NSMutableArray *mutesList;
@property (nonatomic) BOOL isUpdated;

@end

@implementation EMGroupMembersViewController

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

    self.cursor = nil;
    self.isUpdated = NO;

    [self.tableView registerClass:[BQAvatarTitleRoleCell class] forCellReuseIdentifier:NSStringFromClass([BQAvatarTitleRoleCell class])];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    
    [self _setupSubviews];
    [self _fetchGroupMembersWithIsHeader:YES isShowHUD:YES];
    self.mutesList = [[NSMutableArray alloc]init];
    [self _fetchGroupMutes:1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
//    self.title = NSLocalizedString(@"groupMembers", nil);
    self.title = @"群成员列表";
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 60;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(inviteMemberAction)];
    
}

- (void)inviteMemberAction {
    BQGroupEditMemberViewController *controller = [[BQGroupEditMemberViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BQAvatarTitleRoleCell *cell = (BQAvatarTitleRoleCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BQAvatarTitleRoleCell class])];
    
    NSString *userId = self.dataArray[indexPath.row];
    BOOL isOwner = [self.group.owner isEqualToString:userId];
    [cell updateWithObj:userId isOwner:isOwner];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self personalData:[self.dataArray objectAtIndex:indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) ? YES : NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这样写才能实现既能禁止滑动删除Cell，又允许在编辑状态下进行删除
    if (!tableView.editing)
        return UITableViewCellEditingStyleNone;
    else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakself = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"remove", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _deleteMember:userName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"bringtobl", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _blockMember:userName];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[weakself.mutesList containsObject:userName] ? NSLocalizedString(@"unmute", nil) : NSLocalizedString(@"mute", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if ([weakself.mutesList containsObject:userName]) {
            [weakself _unMuteMemeber:userName];
        } else {
            [weakself _muteMember:userName];
        }
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        UITableViewRowAction *adminAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"upRight", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [weakself _memberToAdmin:userName];
        }];
        adminAction.backgroundColor = [UIColor blackColor];
        
        return @[deleteAction, blackAction, muteAction, adminAction];
    }
    
    return @[deleteAction, blackAction, muteAction];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    NSMutableArray *swipeActions = [[NSMutableArray alloc] init];
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:NSLocalizedString(@"remove", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _deleteMember:userName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UIContextualAction *blackAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:NSLocalizedString(@"bringtobl", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _blockMember:userName];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UIContextualAction *muteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                             title:[weakself.mutesList containsObject:userName] ? NSLocalizedString(@"unmute", nil) : NSLocalizedString(@"mute", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        if ([weakself.mutesList containsObject:userName]) {
            [weakself _unMuteMemeber:userName];
        } else {
            [weakself _muteMember:userName];
        }
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    
    [swipeActions addObject:deleteAction];
    [swipeActions addObject:blackAction];
    [swipeActions addObject:muteAction];
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        UIContextualAction *adminAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                   title:NSLocalizedString(@"upRight", nil)
                                                                                 handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                            {
            [weakself _memberToAdmin:userName];
        }];
        adminAction.backgroundColor = [UIColor blackColor];
        [swipeActions addObject:adminAction];
    }
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

#pragma mark - Data

- (void)_fetchGroupMembersWithIsHeader:(BOOL)aIsHeader
                             isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchingGroupMembers...", nil)];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.group.groupId cursor:self.cursor pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (aError) {
            [EaseAlertController showErrorAlert:aError.errorDescription];
        } else {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
                [weakself.dataArray addObject:self.group.owner];
                [weakself.dataArray addObjectsFromArray:self.group.adminList];
            }
            
            weakself.cursor = aResult.cursor;
            [weakself.dataArray addObjectsFromArray:aResult.list];
            
            if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
                weakself.showRefreshFooter = NO;
            } else {
                weakself.showRefreshFooter = YES;
            }
            
            [weakself.tableView reloadData];
        }
        
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
    }];
}

- (void)_fetchGroupMutes:(int)aPage
{
    if (self.group.permissionType == EMGroupPermissionTypeMember || self.group.permissionType == EMGroupPermissionTypeNone) {
        return;
    }
    if (aPage == 1) {
        [self.mutesList removeAllObjects];
    }
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupMuteListFromServerWithId:self.group.groupId pageNumber:aPage pageSize:200 completion:^(NSArray *aList, EMError *aError) {
        if (aError) {
            [EaseAlertController showErrorAlert:aError.errorDescription];
        } else {
            [weakself.mutesList addObjectsFromArray:aList];
        }
        if ([aList count] == 200) {
            [weakself _fetchGroupMutes:(aPage + 1)];
        }
    }];
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

- (void)_deleteMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"removeGroupMember", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager removeMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"removeContactFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EaseAlertController showSuccessAlert:NSLocalizedString(@"removeContactSucess", nil)];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_blockMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"moveToBL", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager blockMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"moveToBLFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EaseAlertController showSuccessAlert:NSLocalizedString(@"moveToBLSuccess", nil)];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_muteMember:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"muteGroupMember", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager muteMembers:@[aUsername] muteMilliseconds:-1 fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"muteFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EaseAlertController showSuccessAlert:NSLocalizedString(@"muteSuccess", nil)];
            [weakself.tableView reloadData];
            [weakself _fetchGroupMutes:1];
        }
    }];
}

- (void)_unMuteMemeber:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"unmuteGroupMember", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager unmuteMembers:@[aUsername] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"unmuteFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EaseAlertController showSuccessAlert:NSLocalizedString(@"unmuteSuccess", nil)];
            [weakself _fetchGroupMutes:1];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)_memberToAdmin:(NSString *)aUsername
{
    [self showHudInView:self.view hint:[NSString stringWithFormat:NSLocalizedString(@"beComeAdmin", nil),aUsername]];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager addAdmin:aUsername toGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"tobeAdminFail", nil)];
        } else {
            weakself.isUpdated = YES;
            [EaseAlertController showSuccessAlert:NSLocalizedString(@"tobeAdminSuccess", nil)];
            [weakself.dataArray removeObject:aUsername];
            [weakself.tableView reloadData];
        }
    }];
}

- (void)backAction
{
    if (self.isUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_UPDATED object:self.group];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

@end
