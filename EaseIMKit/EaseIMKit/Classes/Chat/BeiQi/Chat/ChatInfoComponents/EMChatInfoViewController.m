//
//  EMChatInfoViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/2/4.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatInfoViewController.h"
#import "EMChatRecordViewController.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>


#import "BQTitleValueAccessCell.h"
#import "BQTitleSwitchCell.h"
#import "BQAvatarTitleRoleCell.h"
#import "BQChatRecordContainerViewController.h"
#import "EaseConversationModel.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"
#import "EaseIMHelper.h"

@interface EMChatInfoViewController ()

@property (nonatomic, strong) UITableViewCell *clearChatRecordCell;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseConversationModel *conversationModel;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation EMChatInfoViewController

- (instancetype)initWithCoversation:(EMConversation *)aConversation
{
    self = [super init];
    if (self) {
        _conversation = aConversation;
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registeCell];
    [self _setupSubviews];
    
    self.showRefreshHeader = NO;
}

- (void)registeCell {
    
    [self.tableView registerClass:[BQAvatarTitleRoleCell class] forCellReuseIdentifier:NSStringFromClass([BQAvatarTitleRoleCell class])];
    [self.tableView registerClass:[BQTitleValueAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
    [self.tableView registerClass:[BQTitleSwitchCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleSwitchCell class])];

}

- (void)_setupSubviews
{
    self.title = NSLocalizedString(@"msgInfo", nil);

    self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BQAvatarTitleRoleCell *titleAvatarCell = [tableView dequeueReusableCellWithIdentifier:[BQAvatarTitleRoleCell reuseIdentifier]];
    
    BQTitleValueAccessCell *titleValueAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueAccessCell reuseIdentifier]];

    BQTitleSwitchCell *titleSwitchCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleSwitchCell reuseIdentifier]];


    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [titleAvatarCell updateWithObj:self.conversation.conversationId  isOwner:NO];
            return titleAvatarCell;
        }
        
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            titleValueAccessCell.nameLabel.text = @"查找聊天内容";
            titleValueAccessCell.detailLabel.text = @"";
            titleValueAccessCell.tapCellBlock = ^{
                [self goSearchChatRecord];
            };
            return titleValueAccessCell;
        }else {
            titleSwitchCell.nameLabel.text = @"消息免打扰";
            NSArray *ignoredUidList = [[EMClient sharedClient].pushManager noPushUIds];
            if ([ignoredUidList containsObject:self.conversation.conversationId]) {
                [titleSwitchCell.aSwitch setOn:YES];
            } else {
                [titleSwitchCell.aSwitch setOn:NO];
            }
            
            EaseIMKit_WS
            titleSwitchCell.switchActionBlock = ^(UISwitch * _Nonnull aSwitch) {
                [weakSelf noDisturbEnableWithSwitch:aSwitch];
            };
            
            return titleSwitchCell;
        }
    }
    return nil;

}

- (void)goSearchChatRecord {
    //查找聊天记录
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.conversation.conversationId type:EMConversationTypeGroupChat createIfNotExist:NO];
    BQChatRecordContainerViewController *chatRrcordController = [[BQChatRecordContainerViewController alloc]initWithCoversationModel:conversation];
  
    [self.navigationController pushViewController:chatRrcordController animated:YES];
}

#pragma mark - Action
- (void)noDisturbEnableWithSwitch:(UISwitch *)aSwitch {
    EaseIMKit_WS
   
    [[EMClient sharedClient].pushManager updatePushServiceForUsers:@[self.conversation.conversationId] disablePush:aSwitch.isOn completion:^(EMError * _Nonnull aError) {
        if (aError) {
            [weakSelf showHint:[NSString stringWithFormat:NSLocalizedString(@"setDistrbute", nil),aError.errorDescription]];
            [aSwitch setOn:NO];
        }else {
            [[EaseIMKitManager shared] updateUndisturbMapsKey:self.conversation.conversationId value:aSwitch.isOn];
            
//        action:event
//        "eventType":"groupNoPush"/"userNoPush"
//        "noPush":true/false
//        "id":"xxx"
            
            NSDictionary *ext = @{@"eventType":@"userNoPush",@"noPush":@(aSwitch.isOn),@"id":_conversation.conversationId};
            
            [[EaseIMHelper shareHelper] sendNoDisturbCMDMessageWithExt:ext];
            
        }
    }];


}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2)
        return 60;
    
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0.001;
    
    return 24.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 5)
        return 40;
    
    return 1;
}


//清除聊天记录
- (void)deleteChatRecord
{
    __weak typeof(self) weakself = self;
    //UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"removePrompt", nil),self.conversationModel.emModel.conversationId] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"removeMsgPrompt", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"clear", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.conversation.conversationId type:EMConversationTypeChat createIfNotExist:NO];
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

//cell开关
- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    __weak typeof(self) weakself = self;
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 2) {
        [[EaseIMKitManager shared] updateUndisturbMapsKey:self.conversation.conversationId value:aSwitch.isOn];
        [[EMClient sharedClient].pushManager updatePushServiceForUsers:@[self.conversation.conversationId] disablePush:aSwitch.isOn completion:^(EMError * _Nonnull aError) {
            if (aError) {
                [weakself showHint:[NSString stringWithFormat:NSLocalizedString(@"setDistrbute", nil),aError.errorDescription]];
                [aSwitch setOn:NO];
            }
        }];
    }
    if (section == 3) {
        if (row == 0) {
            //置顶
            if (aSwitch.isOn) {
                [self.conversationModel setIsTop:YES];
            } else {
                [self.conversationModel setIsTop:NO];
            }
        }
    }
}

#pragma mark - Private

- (NSInteger)_tagWithIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger tag = aIndexPath.section * 10 + aIndexPath.row;
    return tag;
}

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

@end
