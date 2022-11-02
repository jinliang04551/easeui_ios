//
//  EMGroupInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupInfoViewController.h"
#import "EMAvatarNameCell.h"

#import "EaseTextFieldViewController.h"
#import "EaseTextViewController.h"
#import "EMGroupMembersViewController.h"
#import "EMChatRecordViewController.h"

#import "BQTitleAvatarCell.h"
#import "BQTitleValueAccessCell.h"
#import "BQTitleValueCell.h"
#import "BQTitleSwitchCell.h"
#import "BQGroupMemberCell.h"
#import "BQGroupEditMemberViewController.h"
#import "BQChatRecordContainerViewController.h"
#import "BQTitleAvatarAccessCell.h"
#import "YGGroupMuteSettingViewController.h"
#import "YGGroupYunGuanRemarkViewController.h"
#import "EaseHeaders.h"
#import "EaseConversationModel.h"
#import "EaseIMKitManager.h"
#import "EaseIMHelper.h"
#import "UserInfoStore.h"
#import "BQTitleContentAccessCell.h"
#import "YGGroupManageViewController.h"



@interface EMGroupInfoViewController ()<EMMultiDevicesDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseConversationModel *conversationModel;
@property (nonatomic, strong) BQGroupMemberCell *groupMemberCell;
//群组成员
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) NSMutableArray *serverArray;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) NSString *groupOwnerNickname;

//是否可编辑（群主或者管理员）
@property (nonatomic, assign) BOOL isEditable;


//群组公告
@property (nonatomic, strong) NSString *groupAnnocement;

//群组介绍
@property (nonatomic, strong) NSString *groupIntroduce;

//群头像
@property (nonatomic, strong) BQTitleAvatarCell *titleAvatarCell;
//群名称
@property (nonatomic, strong) BQTitleValueCell *groupNameCell;

//群名称(可修改)
@property (nonatomic, strong) BQTitleValueAccessCell *groupNameAccessCell;

//群主
@property (nonatomic, strong) BQTitleValueCell *groupOwnerCell;

//群介绍
@property (nonatomic, strong) BQTitleValueAccessCell *groupInterduceAccessCell;

//群公告
@property (nonatomic, strong) BQTitleValueAccessCell *groupAnnocementAccessCell;


//群介绍（有内容）
@property (nonatomic, strong) BQTitleContentAccessCell *groupInterduceContentAccessCell;

//群公告（有内容）
@property (nonatomic, strong) BQTitleContentAccessCell *groupAnnocementContentAccessCell;


//群管理
@property (nonatomic, strong) BQTitleValueAccessCell *groupManageAccessCell;

//运营备注
@property (nonatomic, strong) BQTitleValueAccessCell *ygMarkAccessCell;

//查找聊天记录
@property (nonatomic, strong) BQTitleValueAccessCell *searchChatRecordAccessCell;

//消息免打扰
@property (nonatomic, strong) BQTitleSwitchCell *titleSwitchCell;


@property (nonatomic, strong) NSMutableArray<NSMutableArray *>  *sections;

@end

@implementation EMGroupInfoViewController

- (instancetype)initWithConversation:(EMConversation *)aConversation
{
    self = [super init];
    if (self) {
        _groupId = aConversation.conversationId;
        _conversation = aConversation;
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:aConversation];
        
        [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoUpdated:) name:GROUP_INFO_UPDATED object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoUpdated:) name:GROUP_INFO_REFRESH object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoUpdated:) name:EaseNotificationReceiveGroupInfoUpdate object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    }
    
    return self;
}

- (void)refreshTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registeCell];
    [self _setupSubviews];

    self.showRefreshHeader = NO;
    
    [self buildCells];
    
    [self _fetchGroupWithId:self.groupId isShowHUD:YES];
  
    
}

- (void)registeCell {
    
    [self.tableView registerClass:[BQTitleAvatarCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleAvatarCell class])];
    [self.tableView registerClass:[BQTitleValueAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
    [self.tableView registerClass:[BQTitleSwitchCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleSwitchCell class])];
    [self.tableView registerClass:[BQTitleValueCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueCell class])];

    [self.tableView registerClass:[BQTitleAvatarAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleAvatarAccessCell class])];
    
    [self.tableView registerClass:[BQTitleContentAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleContentAccessCell class])];

}


- (void)buildCells {
    [self updateCellInfos];
    
    NSMutableArray *sections = [NSMutableArray array];
    
    NSMutableArray *section1 = [NSMutableArray array];
    NSMutableArray *section2 = [NSMutableArray array];
    NSMutableArray *section3 = [NSMutableArray array];

    //section1
    [section1 addObject:self.titleAvatarCell];
    [section1 addObject:self.groupMemberCell];
    
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
                
        [section2 addObject:self.groupNameCell];
        [section2 addObject:self.groupOwnerCell];
        
        if (self.groupAnnocement.length > 0) {
            [section2 addObject:self.groupAnnocementContentAccessCell];
        }else {
            [section2 addObject:self.groupAnnocementAccessCell];
        }
        
        if (self.groupIntroduce.length > 0) {
            [section2 addObject:self.groupInterduceContentAccessCell];
        }else {
            [section2 addObject:self.groupInterduceAccessCell];
        }
    }else {
        //section2
        if (self.group.permissionType == EMGroupPermissionTypeOwner ||self.group.permissionType == EMGroupPermissionTypeAdmin){
            [section2 addObject:self.groupNameAccessCell];
        }else {
            [section2 addObject:self.groupNameCell];
        }
        
        [section2 addObject:self.groupOwnerCell];
        if (self.groupAnnocement.length > 0) {
            [section2 addObject:self.groupAnnocementContentAccessCell];
        }else {
            [section2 addObject:self.groupAnnocementAccessCell];
        }
        
        if (self.groupIntroduce.length > 0) {
            [section2 addObject:self.groupInterduceContentAccessCell];
        }else {
            [section2 addObject:self.groupInterduceAccessCell];
        }
            
        if (self.group.permissionType == EMGroupPermissionTypeOwner ||self.group.permissionType == EMGroupPermissionTypeAdmin) {
            [section2 addObject:self.groupManageAccessCell];
        }
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            //
        }else {
            [section2 addObject:self.ygMarkAccessCell];
        }

    }
    

    //section3
    [section3 addObject:self.searchChatRecordAccessCell];
    [section3 addObject:self.titleSwitchCell];

    [sections addObject:section1];
    [sections addObject:section2];
    [sections addObject:section3];

    self.sections = sections;
    [self.tableView reloadData];
}


- (void)updateCellInfos {
    [self.groupMemberCell updateWithObj:self.memberArray];
    self.groupNameCell.detailLabel.text = self.group.groupName;
    self.groupNameAccessCell.detailLabel.text = self.group.groupName;
    
    self.groupOwnerCell.detailLabel.text = self.groupOwnerNickname;
    self.groupAnnocementContentAccessCell.contentLabel.text = self.groupAnnocement;
    self.groupInterduceContentAccessCell.contentLabel.text = self.groupIntroduce;

    [self.titleSwitchCell.aSwitch setOn:!self.group.isPushNotificationEnabled];

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


- (void)fetchGroupInfo {
    EaseIMKit_WS
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            weakSelf.group = aGroup;
            [weakSelf _resetGroup:aGroup];
        } else {
//            [EaseAlertController showErrorAlert:[NSString stringWithFormat:NSLocalizedString(@"fetchGroupSubjectFail", nil),aError.description]];
            
        }
    }];
}


- (void)dealloc
{
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Subviews

- (void)_setupSubviews
{

    
     self.titleView = [self customNavWithTitle:@"群设置" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.sections[section].count;
    
//    if (section == 0) {
//        return 2;
//    }else if (section == 1){
//        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//                return 4;
//        }else {
//            if (self.group.permissionType == EMGroupPermissionTypeOwner) {
//                    return 6;
//                } else {
//                    return 5;
//                }
//        }
//        return 4;
//    }else {
//        return 2;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = self.sections[indexPath.section][indexPath.row];
    return cell;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    BQTitleAvatarCell *titleAvatarCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleAvatarCell reuseIdentifier]];
//
//    BQTitleValueAccessCell *titleValueAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueAccessCell reuseIdentifier]];
//
//    BQTitleValueCell *titleValueCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueCell reuseIdentifier]];
//
//    BQTitleSwitchCell *titleSwitchCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleSwitchCell reuseIdentifier]];
//
//    BQTitleContentAccessCell *titleContentAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleContentAccessCell reuseIdentifier]];
//
//
//    if (indexPath.section == 0) {
//        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//                if (indexPath.row == 0) {
//                    titleAvatarCell.nameLabel.text = @"群头像";
//                    [titleAvatarCell.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_group_icon"]];
//                    return titleAvatarCell;
//                }else {
//                    [self.groupMemberCell updateWithObj:self.memberArray];
//                    return self.groupMemberCell;
//                }
//        }else {
//                if (indexPath.row == 0) {
//                    titleAvatarCell.nameLabel.text = @"群头像";
//                    [titleAvatarCell.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_group_icon"]];
//                    return titleAvatarCell;
//
//                }else {
//                    [self.groupMemberCell updateWithObj:self.memberArray];
//                    return self.groupMemberCell;
//                }
//        }
//
//    }else if (indexPath.section == 1){
//if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//        if (indexPath.row == 0) {
//            titleValueCell.nameLabel.text = @"群名称";
//            titleValueCell.detailLabel.text = self.group.groupName;
//            return titleValueCell;
//        }else if (indexPath.row == 1){
//            titleValueCell.nameLabel.text = @"群主";
//
//            titleValueCell.detailLabel.text = self.groupOwnerNickname;
//            return titleValueCell;
//
//        }else if (indexPath.row == 2){
//            if (self.groupAnnocement.length > 0) {
//                titleContentAccessCell.nameLabel.text = @"群公告";
//                titleContentAccessCell.contentLabel.text = self.groupAnnocement;
//                titleContentAccessCell.tapCellBlock = ^{
//                    [self groupAnnouncementAction];
//                };
//                return titleContentAccessCell;
//            }else {
//                titleValueAccessCell.nameLabel.text = @"群公告";
//                titleValueAccessCell.detailLabel.text = @"未设置";
//                titleValueAccessCell.tapCellBlock = ^{
//                    [self groupAnnouncementAction];
//                };
//                return titleValueAccessCell;
//            }
//        }else {
//
//            if (self.groupIntroduce.length > 0) {
//                titleContentAccessCell.nameLabel.text = @"群介绍";
//                titleContentAccessCell.contentLabel.text = self.groupIntroduce;
//                titleContentAccessCell.tapCellBlock = ^{
//                    [self _updateGroupDetailAction];
//                };
//                return titleContentAccessCell;
//            }else {
//                titleValueAccessCell.nameLabel.text = @"群介绍";
//                titleValueAccessCell.detailLabel.text = @"未设置";
//                titleValueAccessCell.tapCellBlock = ^{
//                    [self _updateGroupDetailAction];
//                };
//                return titleValueAccessCell;
//            }
//
//
//        }
//}else {
//    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
//            if (indexPath.row == 0) {
//                titleValueAccessCell.nameLabel.text = @"群名称";
//                titleValueAccessCell.detailLabel.text = self.group.groupName;
//                titleValueAccessCell.tapCellBlock = ^{
//                    [self _updateGroupNameAction];
//                };
//                return titleValueAccessCell;
//            }else if (indexPath.row == 1){
//                titleValueCell.nameLabel.text = @"群主";
//                titleValueCell.detailLabel.text = self.groupOwnerNickname;
//                return titleValueCell;
//
//            }else if (indexPath.row == 2){
//
//                if (self.groupAnnocement.length > 0) {
//                    titleContentAccessCell.nameLabel.text = @"群公告";
//                    titleContentAccessCell.contentLabel.text = self.groupAnnocement;
//                    titleContentAccessCell.tapCellBlock = ^{
//                        [self groupAnnouncementAction];
//                    };
//                    return titleContentAccessCell;
//                }else {
//                    titleValueAccessCell.nameLabel.text = @"群公告";
//                    titleValueAccessCell.detailLabel.text = @"未设置";
//                    titleValueAccessCell.tapCellBlock = ^{
//                        [self groupAnnouncementAction];
//                    };
//                    return titleValueAccessCell;
//                }
//
//            }else  if (indexPath.row == 3){
//
//                if (self.groupIntroduce.length > 0) {
//                    titleContentAccessCell.nameLabel.text = @"群介绍";
//                    titleContentAccessCell.contentLabel.text = self.groupIntroduce;
//                    titleContentAccessCell.tapCellBlock = ^{
//                        [self _updateGroupDetailAction];
//                    };
//                    return titleContentAccessCell;
//                }else {
//                    titleValueAccessCell.nameLabel.text = @"群介绍";
//                    titleValueAccessCell.detailLabel.text = @"未设置";
//                    titleValueAccessCell.tapCellBlock = ^{
//                        [self _updateGroupDetailAction];
//                    };
//                    return titleValueAccessCell;
//                }
//
//            }else if (indexPath.row == 4){
//                titleValueAccessCell.nameLabel.text = @"群管理";
//                titleValueAccessCell.detailLabel.text = @"";
//                titleValueAccessCell.tapCellBlock = ^{
//                    [self goGroupManagePage];
//                };
//                return titleValueAccessCell;
//            }else {
//                titleValueAccessCell.nameLabel.text = @"运营备注";
//                titleValueAccessCell.detailLabel.text = @"";
//                titleValueAccessCell.tapCellBlock = ^{
//                    [self _updateGroupYunGuanRemark];
//                };
//                return titleValueAccessCell;
//            }
//
//        } else {
//            if (indexPath.row == 0) {
//                titleValueCell.nameLabel.text = @"群名称";
//                titleValueCell.detailLabel.text = self.group.groupName;
//                return titleValueCell;
//            }else if (indexPath.row == 1){
//                titleValueCell.nameLabel.text = @"群主";
//                titleValueCell.detailLabel.text = self.groupOwnerNickname;
//                return titleValueCell;
//
//            }else if (indexPath.row == 2){
////                titleValueAccessCell.nameLabel.text = @"群公告";
////                titleValueAccessCell.detailLabel.text = @"";
////                titleValueAccessCell.tapCellBlock = ^{
////                    [self groupAnnouncementAction];
////                };
////                return titleValueAccessCell;
//
//                if (self.groupAnnocement.length > 0) {
//                    titleContentAccessCell.nameLabel.text = @"群公告";
//                    titleContentAccessCell.contentLabel.text = self.groupAnnocement;
//                    titleContentAccessCell.tapCellBlock = ^{
//                        [self groupAnnouncementAction];
//                    };
//                    return titleContentAccessCell;
//                }else {
//                    titleValueAccessCell.nameLabel.text = @"群公告";
//                    titleValueAccessCell.detailLabel.text = @"未设置";
//                    titleValueAccessCell.tapCellBlock = ^{
//                        [self groupAnnouncementAction];
//                    };
//                    return titleValueAccessCell;
//                }
//
//            }else  if (indexPath.row == 3){
////                titleValueAccessCell.nameLabel.text = @"群介绍";
////                titleValueAccessCell.detailLabel.text = @"";
////                titleValueAccessCell.tapCellBlock = ^{
////                    [self _updateGroupDetailAction];
////                };
////                return titleValueAccessCell;
//
//                if (self.groupIntroduce.length > 0) {
//                    titleContentAccessCell.nameLabel.text = @"群介绍";
//                    titleContentAccessCell.contentLabel.text = self.groupIntroduce;
//                    titleContentAccessCell.tapCellBlock = ^{
//                        [self _updateGroupDetailAction];
//                    };
//                    return titleContentAccessCell;
//                }else {
//                    titleValueAccessCell.nameLabel.text = @"群介绍";
//                    titleValueAccessCell.detailLabel.text = @"未设置";
//                    titleValueAccessCell.tapCellBlock = ^{
//                        [self _updateGroupDetailAction];
//                    };
//                    return titleValueAccessCell;
//                }
//
//
//            }else {
//                titleValueAccessCell.nameLabel.text = @"运营备注";
//                titleValueAccessCell.detailLabel.text = @"";
//                titleValueAccessCell.tapCellBlock = ^{
//                    [self _updateGroupYunGuanRemark];
//                };
//                return titleValueAccessCell;
//            }
//        }
//}
//
//    }else {
//        if (indexPath.row == 0) {
//            titleValueAccessCell.nameLabel.text = @"查找聊天内容";
//            titleValueAccessCell.detailLabel.text = @"";
//            titleValueAccessCell.tapCellBlock = ^{
//                [self goSearchChatRecord];
//            };
//            return titleValueAccessCell;
//        }else {
//            titleSwitchCell.nameLabel.text = @"消息免打扰";
//            [titleSwitchCell.aSwitch setOn:!self.group.isPushNotificationEnabled];
//            EaseIMKit_WS
//            titleSwitchCell.switchActionBlock = ^(UISwitch * _Nonnull aSwitch) {
//                [weakSelf noDisturbEnableWithSwitch:aSwitch];
//            };
//
//            return titleSwitchCell;
//        }
//    }
//    return nil;
//}
 

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1){
        return [BQGroupMemberCell cellHeightWithObj:self.memberArray];
    }
    
    if (indexPath.section == 1 && indexPath.row == 2){
        if (self.groupAnnocement.length > 0) {
            return [BQTitleContentAccessCell heightWithObj:self.groupAnnocement];
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 3){
        if (self.groupIntroduce.length > 0) {
            return [BQTitleContentAccessCell heightWithObj:self.groupIntroduce];
        }
    }
    

    return 64.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.001;
    
    return 12.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] init];
    hView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    return hView;
}


- (void)goSearchChatRecord {
    //查找聊天记录
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
    BQChatRecordContainerViewController *vc = [[BQChatRecordContainerViewController alloc]initWithCoversationModel:conversation];
  
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    switch (aEvent) {
        case EMMultiDevicesEventGroupKick:
        case EMMultiDevicesEventGroupBan:
        case EMMultiDevicesEventGroupAllow:
        case EMMultiDevicesEventGroupAssignOwner:
        case EMMultiDevicesEventGroupAddAdmin:
        case EMMultiDevicesEventGroupRemoveAdmin:
        case EMMultiDevicesEventGroupAddMute:
        case EMMultiDevicesEventGroupRemoveMute:
        {
            if ([aGroupId isEqualToString:self.group.groupId]) {
                [self.tableView reloadData];
            }
        }
            
        default:
            break;
    }
}

#pragma mark - Data

- (void)_resetGroup:(EMGroup *)aGroup
{
    if (![self.group.groupName isEqualToString:aGroup.groupName]) {
        if (_conversation) {
            NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:_conversation.ext];
            [ext setObject:aGroup.groupName forKey:@"subject"];
            [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
            _conversation.ext = ext;
            
        }
    }
    
    self.group = aGroup;
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        // do nothing
    }else {
        if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) {
                self.isEditable = YES;
            }
    }
    
        
    [self fetchGroupAnnocement];
    self.groupIntroduce = self.group.description;
    [self getGroupMembers];
    
    [self buildCells];
}

- (void)fetchGroupAnnocement {
    [[EMClient sharedClient].groupManager getGroupAnnouncementWithId:self.group.groupId completion:^(NSString *aAnnouncement, EMError * _Nullable aError) {
        if (aError == nil) {
            self.groupAnnocement = aAnnouncement;
            [self buildCells];
            [self.tableView reloadData];
        }
    }];
}

- (void)_fetchGroupWithId:(NSString *)aGroupId
                isShowHUD:(BOOL)aIsShowHUD
{
    __weak typeof(self) weakself = self;
    
    
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupId fetchMembers:YES completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        [weakself hideHud];
        if (!aError) {
            [[EaseIMHelper shareHelper] fetchAllMembersUserInfoWithGroup:aGroup];
            [weakself getOwnerNicknameWithUserId:aGroup.owner];
            [weakself _resetGroup:aGroup];
        } else {
            
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
    
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchGroupWithId:self.groupId isShowHUD:NO];
}

#pragma mark - EMGroupManagerDelegate

- (void)didLeaveGroup:(EMGroup *)aGroup reason:(EMGroupLeaveReason)aReason
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.leaveOrDestroyCompletion) {
        self.leaveOrDestroyCompletion();
    }
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin
{
    if ([aAdmin isEqualToString:EMClient.sharedClient.currentUsername]) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin
{
    if ([aAdmin isEqualToString:EMClient.sharedClient.currentUsername]) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}
- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner
{
    if ([aOldOwner isEqualToString:EMClient.sharedClient.currentUsername]) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

#pragma mark - NSNotification

- (void)handleGroupInfoUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    if (!group || ![group.groupId isEqualToString:self.groupId]) {
        return;
    }
    
    [self _fetchGroupWithId:self.groupId isShowHUD:NO];
}

#pragma mark - Action
- (void)noDisturbEnableWithSwitch:(UISwitch *)aSwitch {
    
    EaseIMKit_WS
   
    [EMClient.sharedClient.groupManager updatePushServiceForGroup:self.group.groupId isPushEnabled:!aSwitch.isOn completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            weakSelf.group = aGroup;
            [[EaseIMKitManager shared] updateUndisturbMapsKey:self.conversation.conversationId value:aSwitch.isOn];
            
            //        action:event
            //        "eventType":"groupNoPush"/"userNoPush"
            //        "noPush":true/false
            //        "id":"xxx"
                        
        NSDictionary *ext = @{@"eventType":@"groupNoPush",@"noPush":@(aSwitch.isOn),@"id":_conversation.conversationId};
        
        [[EaseIMHelper shareHelper] sendNoDisturbCMDMessageWithExt:ext];
                        
        } else {
            if (aError) {
                [weakSelf showHint:[NSString stringWithFormat:NSLocalizedString(@"setDistrbute", nil),aError.errorDescription]];
                [aSwitch setOn:NO];
            }
        }
    }];
}


//cell开关
- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 3) {
        if (row == 0) {
            //免打扰
            __weak typeof(self) weakself = self;
            
            [[EaseIMKitManager shared] updateUndisturbMapsKey:self.conversation.conversationId value:aSwitch.isOn];
            [EMClient.sharedClient.groupManager updatePushServiceForGroup:self.group.groupId isPushEnabled:!aSwitch.isOn completion:^(EMGroup *aGroup, EMError *aError) {
                if (!aError) {
                    weakself.group = aGroup;
                } else {
                    if (aError) {
                        [weakself showHint:[NSString stringWithFormat:NSLocalizedString(@"setDistrbute", nil),aError.errorDescription]];
                        [aSwitch setOn:NO];
                    }
                }
            }];
        } else if (row == 1) {
            //置顶
            if (aSwitch.isOn) {
                [self.conversationModel setIsTop:YES];
            } else {
                [self.conversationModel setIsTop:NO];
            }
        }
    }
}

//清空聊天记录
- (void)deleteGroupRecord
{
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"removeGroupMsgs", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"clear", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.group.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
        EMError *error = nil;
        [conversation deleteAllMessages:&error];
        if (weakself.clearRecordCompletion) {
            if (!error) {
                [EaseAlertController showSuccessAlert:NSLocalizedString(@"cleared", nil)];
                weakself.clearRecordCompletion(YES);
            } else {
                [EaseAlertController showErrorAlert:NSLocalizedString(@"clearFail", nil)];
                weakself.clearRecordCompletion(NO);
            }
        }
    }];
    [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
    [alertController addAction:clearAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)groupAnnouncementAction
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchingGroupAnn...", nil)];
    [[EMClient sharedClient].groupManager getGroupAnnouncementWithId:self.groupId completion:^(NSString *aAnnouncement, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            NSString *hint;
            if (self.isEditable) {
                hint = NSLocalizedString(@"inputGroupAnn", nil);
            } else {
                hint = @"暂无新公告";
            }
            EaseTextViewController *controller = [[EaseTextViewController alloc] initWithString:aAnnouncement placeholder:hint isEditable:self.isEditable];
            controller.title = @"群公告";
            
            __weak typeof(controller) weakController = controller;
            [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
                [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateGroupAnn...", nil)];
                [[EMClient sharedClient].groupManager updateGroupAnnouncementWithId:weakself.groupId announcement:aString completion:^(EMGroup *aGroup, EMError *aError) {
                    [weakController hideHud];
                    if (aError) {
                        [EaseAlertController showErrorAlert:NSLocalizedString(@"updateGroupAnnFail", nil)];
                    } else {
                        [self showHint:@"群信息修改成功"];
                        [self fetchGroupAnnocement];

                        [weakController.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
                return NO;
            }];
            
            [weakself.navigationController pushViewController:controller animated:YES];
        } else {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"fetchGroupAnnFail", nil)];
        }
    }];
}


- (void)_updateGroupNameAction
{
    if (!self.isEditable) {
        return;
    }
    
    EaseTextFieldViewController *controller = [[EaseTextFieldViewController alloc] initWithString:self.group.groupName placeholder:NSLocalizedString(@"inputGroupSubject", nil) isEditable:self.isEditable];
    controller.title = NSLocalizedString(@"editGroupSubject", nil);
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        if ([aString length] == 0) {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"emtpyGroupSubject", nil)];
            return NO;
        }
                
        EaseIMKit_WS
        [[EaseHttpManager sharedManager] modifyGroupNameWithGroupId:weakSelf.group.groupId groupname:aString completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        
            if (response && response.length > 0 && statusCode) {
                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
                if (statusCode == 200) {
                    NSDictionary *data = responsedict[@"data"];
                    BOOL status = data[@"groupname"];

                    if (status) {
                        [weakController.navigationController popViewControllerAnimated:YES];
                        [weakSelf showHint:@"修改群名称成功"];
                        [weakSelf fetchGroupInfo];
                    }
                   
                }else {
                    [EaseAlertController showErrorAlert:errorDescription];
                }
            }
            
        }];
        
        return NO;
    }];

    
}


- (void)_updateGroupYunGuanRemark
{
    YGGroupYunGuanRemarkViewController *controller = [[YGGroupYunGuanRemarkViewController alloc] initWithGroupId:self.groupId];
    
    controller.doneCompletion = ^(NSString * _Nonnull aString) {
        NSLog(@"%s aString:%@",__func__,aString);
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}


- (void)_updateGroupDetailAction
{
    EaseTextViewController *controller = [[EaseTextViewController alloc] initWithString:self.group.description placeholder:NSLocalizedString(@"inputGroupDescription", nil) isEditable:self.isEditable];
    if (self.isEditable) {
         controller.title = NSLocalizedString(@"editGroupDescription", nil);
    } else {
        controller.title = NSLocalizedString(@"groupDescription", nil);
    }
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        [weakController showHudInView:weakController.view hint:NSLocalizedString(@"updateGroupDescription...", nil)];
        [[EMClient sharedClient].groupManager updateDescription:aString forGroup:weakself.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetGroup:aGroup];
                [weakController.navigationController popViewControllerAnimated:YES];
                [self showHint:@"群信息修改成功"];

            } else {
                [EaseAlertController showErrorAlert:NSLocalizedString(@"updateGroupDescriptionFail", nil)];
            }
        }];
        
        return NO;
    }];
}

- (void)getGroupMembers {
    NSMutableArray *tArray = [NSMutableArray array];
    [tArray addObject:self.group.owner];
    if (self.group.adminList.count > 0) {
        [tArray addObjectsFromArray:self.group.adminList];
    }
    if (self.group.memberList.count > 0) {
        [tArray addObjectsFromArray:self.group.memberList];
    }
    self.memberArray = [tArray mutableCopy];
}

- (void)goAddGroupMemberPage {
    BQGroupEditMemberViewController *controller = [[BQGroupEditMemberViewController alloc] init];
    EaseIMKit_WS
    controller.addedMemberBlock = ^(NSMutableArray * _Nonnull userArray, NSMutableArray * _Nonnull serverArray) {
        weakSelf.userArray = userArray;
        weakSelf.serverArray = serverArray;
        
        [weakSelf inviteMembers];
    };
    
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)inviteMembers {
    if (self.userArray.count == 0 && self.serverArray.count ==0) {
        return;
    }
    
    [[EaseHttpManager sharedManager] inviteGroupMemberWithGroupId:self.group.groupId customerUserIds:self.userArray waiterUserIds:self.serverArray completion:^(NSInteger statusCode, NSString * _Nonnull response) {
       
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                //group owner
                NSString *status = responsedict[@"status"];
                //member
                NSString *groupId = responsedict[@"groupId"];

                if (status.length > 0) {
                    if (self.group.permissionType != EMGroupPermissionTypeOwner) {
                        [self showHint:@"邀请成功，等待群管理员审核"];
                    }else {
                        [self showHint:@"邀请成员成功"];
                    }
                }else {
                    [EaseAlertController showErrorAlert:@"邀请失败"];
                }

            }else {
                [EaseAlertController showErrorAlert:@"邀请失败"];
            }
        }
    }];
}



- (void)goCheckGroupMemberPage {
    EMGroupMembersViewController *controller = [[EMGroupMembersViewController alloc]initWithGroup:self.group];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goGroupManagePage {
    YGGroupManageViewController *controller = [[YGGroupManageViewController alloc] initWithGroup:self.group];
    controller.transferOwnerBlock = ^(BOOL success) {
        if (success) {
            [self _fetchGroupWithId:self.groupId isShowHUD:NO];
        }
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)getOwnerNicknameWithUserId:(NSString *)aUid {
    
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUid];
    if(userInfo) {
        
        self.groupOwnerNickname = userInfo.nickname.length > 0 ? userInfo.nickname: userInfo.userId;
        
    }else{
        self.groupOwnerNickname = aUid;

        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[aUid]];
    }
    
}

    
#pragma mark - Private

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

//string TO dictonary
- (NSMutableDictionary *)changeStringToDictionary:(NSString *)string{

    if (string) {
        NSMutableDictionary *returnDic = [[NSMutableDictionary  alloc]  init];
        returnDic = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return returnDic;
    }
    return nil;
}

#pragma mark getter and setter
- (BQGroupMemberCell *)groupMemberCell {
    if (_groupMemberCell == nil) {
        _groupMemberCell =  [[BQGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[BQGroupMemberCell reuseIdentifier]];
        
        EaseIMKit_WS
        _groupMemberCell.addMemberBlock = ^{
            [weakSelf goAddGroupMemberPage];
        };
        
        _groupMemberCell.moreMemberBlock = ^{
            [weakSelf goCheckGroupMemberPage];
        };
        
    }
    return _groupMemberCell;
}

- (NSMutableArray *)memberArray {
    if (_memberArray == nil) {
        _memberArray = NSMutableArray.array;
    }
    return _memberArray;
}

- (NSMutableArray *)userArray {
    if (_userArray == nil) {
        _userArray = [[NSMutableArray alloc] init];
    }
    return _userArray;
}

- (NSMutableArray *)serverArray {
    if (_serverArray == nil) {
        _serverArray = [[NSMutableArray alloc] init];
    }
    return _serverArray;
}

- (BQTitleAvatarCell *)titleAvatarCell {
    if (_titleAvatarCell == nil) {
        _titleAvatarCell = [[BQTitleAvatarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleAvatarCell class])];
        _titleAvatarCell.nameLabel.text = @"群头像";
        [_titleAvatarCell.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_group_icon"]];

    }
    return _titleAvatarCell;
}


- (BQTitleValueCell *)groupNameCell {
    if (_groupNameCell == nil) {
        _groupNameCell = [[BQTitleValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueCell class])];
        _groupNameCell.nameLabel.text = @"群名称";
    }
    return _groupNameCell;
}

- (BQTitleValueAccessCell *)groupNameAccessCell {
    if (_groupNameAccessCell == nil) {
        _groupNameAccessCell = [[BQTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
        EaseIMKit_WS
        _groupNameAccessCell.nameLabel.text = @"群名称";
        _groupNameAccessCell.tapCellBlock = ^{
            [weakSelf _updateGroupNameAction];
        };
    }
    return _groupNameAccessCell;

}

- (BQTitleValueCell *)groupOwnerCell {
    if (_groupOwnerCell == nil) {
        _groupOwnerCell = [[BQTitleValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueCell class])];
        _groupOwnerCell.nameLabel.text = @"群主";
    }
    return _groupOwnerCell;
    
}



- (BQTitleValueAccessCell *)groupAnnocementAccessCell {
    if (_groupAnnocementAccessCell == nil) {
        _groupAnnocementAccessCell = [[BQTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
        
        EaseIMKit_WS
        _groupAnnocementAccessCell.nameLabel.text = @"群公告";
        _groupAnnocementAccessCell.detailLabel.text = @"未设置";
        _groupAnnocementAccessCell.tapCellBlock = ^{
            [weakSelf groupAnnouncementAction];
        };
        
    }
    return _groupAnnocementAccessCell;
    
}

- (BQTitleValueAccessCell *)groupInterduceAccessCell {
    if (_groupInterduceAccessCell == nil) {
        _groupInterduceAccessCell = [[BQTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
        
        EaseIMKit_WS
        _groupInterduceAccessCell.nameLabel.text = @"群介绍";
        _groupInterduceAccessCell.detailLabel.text = @"未设置";
        _groupInterduceAccessCell.tapCellBlock = ^{
            [weakSelf _updateGroupDetailAction];
        };
    }
    return _groupInterduceAccessCell;
    
}

- (BQTitleContentAccessCell *)groupAnnocementContentAccessCell {
    if (_groupAnnocementContentAccessCell == nil) {
        _groupAnnocementContentAccessCell = [[BQTitleContentAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleContentAccessCell class])];
        
        EaseIMKit_WS
        _groupAnnocementContentAccessCell.nameLabel.text = @"群公告";
        _groupAnnocementContentAccessCell.tapCellBlock = ^{
            [weakSelf groupAnnouncementAction];
        };
        
    }
    return _groupAnnocementContentAccessCell;

}


- (BQTitleContentAccessCell *)groupInterduceContentAccessCell {
    if (_groupInterduceContentAccessCell == nil) {
        _groupInterduceContentAccessCell = [[BQTitleContentAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleContentAccessCell class])];
        
        EaseIMKit_WS
        _groupInterduceContentAccessCell.nameLabel.text = @"群介绍";
        _groupInterduceContentAccessCell.tapCellBlock = ^{
            [weakSelf _updateGroupDetailAction];
        };
    }
    return _groupInterduceContentAccessCell;

}


- (BQTitleValueAccessCell *)groupManageAccessCell {
    if (_groupManageAccessCell == nil) {
        _groupManageAccessCell = [[BQTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
        
        EaseIMKit_WS
        _groupManageAccessCell.nameLabel.text = @"群管理";
        _groupManageAccessCell.detailLabel.text = @"";
        _groupManageAccessCell.tapCellBlock = ^{
            [weakSelf goGroupManagePage];
        };
    }
    return _groupManageAccessCell;
}


- (BQTitleValueAccessCell *)ygMarkAccessCell {
    if (_ygMarkAccessCell == nil) {
        _ygMarkAccessCell = [[BQTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
        
        EaseIMKit_WS
        _ygMarkAccessCell.nameLabel.text = @"运营备注";
        _ygMarkAccessCell.detailLabel.text = @"";
        _ygMarkAccessCell.tapCellBlock = ^{
            [weakSelf _updateGroupYunGuanRemark];
        };
        
    }
    return _ygMarkAccessCell;
}

- (BQTitleValueAccessCell *)searchChatRecordAccessCell {
    if (_searchChatRecordAccessCell == nil) {
        _searchChatRecordAccessCell = [[BQTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
        
        EaseIMKit_WS
        
        _searchChatRecordAccessCell.nameLabel.text = @"查找聊天内容";
        _searchChatRecordAccessCell.detailLabel.text = @"";
        _searchChatRecordAccessCell.tapCellBlock = ^{
            [weakSelf goSearchChatRecord];
        };
    }
    return _searchChatRecordAccessCell;
}

- (BQTitleSwitchCell *)titleSwitchCell {
    if (_titleSwitchCell == nil) {
        _titleSwitchCell = [[BQTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BQTitleSwitchCell class])];
        
        EaseIMKit_WS
        _titleSwitchCell.nameLabel.text = @"消息免打扰";
        _titleSwitchCell.switchActionBlock = ^(UISwitch * _Nonnull aSwitch) {
            [weakSelf noDisturbEnableWithSwitch:aSwitch];
        };
    }
    return _titleSwitchCell;

}

- (NSMutableArray<NSMutableArray *> *)sections {
    if (_sections == nil) {
        _sections = [NSMutableArray array];
    }
    return _sections;
}

@end
