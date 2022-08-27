//
//  EaseIMHelper.h
//  ChatDemo-UI3.0
//
//  Update by zhangchong on 2020/9/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseIMHelper.h"
#import "EMChatViewController.h"
#import "EMGroupInfoViewController.h"
#import "EMRemindManager.h"
#import "EaseAlertController.h"
#import "EaseIMKitOptions.h"
#import "EaseHeaders.h"
#import "EaseConversationModel.h"
#import "EaseIMKitManager.h"
#import "EMChatViewController.h"
#import "UserInfoStore.h"
#import "EBBannerView.h"
#import "EaseDateHelper.h"
#import "EMConversationsViewController.h"


static EaseIMHelper *helper = nil;


@interface EaseIMHelper ()
@property (nonatomic, strong) EBBannerView *bannerView;

@end

@implementation EaseIMHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EaseIMHelper alloc] init];
    });
    return helper;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self _initHelper];
    }
    return self;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.pushedConvIdArray removeAllObjects];
    
}


#pragma mark - init

- (void)_initHelper
{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushChatController:) name:CHAT_PUSHVIEWCONTROLLER object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushGroupsController:) name:GROUP_LIST_PUSHVIEWCONTROLLER object:nil];

    //自己发送的通话开始或者结束CMD消息刷新页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithCallCMDMessage:) name:EaseNotificationSendCallCreateCMDMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithCallCMDMessage:) name:EaseNotificationSendCallEndCMDMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushBannerMsgController:) name:Banner_PUSHVIEWCONTROLLER object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bannerDidClick:) name:EBBannerViewDidClickNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jiHuExGroupPushChatViewController:) name:JiHuExGroupPushChatViewController object:nil];

}


- (void)sendNoDisturbCMDMessageWithExt:(NSDictionary *)ext {
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"event"];
    body.isDeliverOnlineOnly = YES;
    

//action:event
//"eventType":"groupNoPush"/"userNoPush"
//"noPush":true/false
//"id":"xxx"
    
    NSString *userId = [EMClient sharedClient].currentUsername;
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:userId from:userId to:userId body:body ext:ext];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMChatMessage * _Nullable message, EMError * _Nullable error) {
        if (error == nil) {

        }else {
            [self showAlertWithMessage:error.errorDescription];
        }
    }];

}


#pragma mark - EMClientDelegate

// 网络状态变化回调
- (void)connectionStateDidChange:(EMConnectionState)aConnectionState
{
    if (aConnectionState == EMConnectionDisconnected) {
//        [EaseAlertController showErrorAlert:NSLocalizedString(@"offlinePrompt", nil)];
        
    }
}

- (void)autoLoginDidCompleteWithError:(EMError *)error
{
    if (error) {
        [self showAlertWithMessage:NSLocalizedString(@"loginPrompt", nil)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
    }
}


- (void)userAccountDidLoginFromOtherDevice
{
    [self kickedOffByServer];

}

- (void)userAccountDidRemoveFromServer
{
    [self kickedOffByServer];
}

- (void)userDidForbidByServer
{
    [self kickedOffByServer];
}

- (void)userAccountDidForcedToLogout:(EMError *)aError
{
    [self kickedOffByServer];
    
}

//被服务器强制踢下线
- (void)kickedOffByServer {
    EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
    options.isAutoLogin = NO;
    [options archive];
    [[EMClient sharedClient] logout:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveEnforceKickOffByServer object:nil];

}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    NSString *message = [NSString stringWithFormat:@"%li-%@-%@", (long)aEvent, aTarget, aExt];
    [self showAlertWithTitle:NSLocalizedString(@"multiDevices[Contact]", nil) message:message];
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    NSString *message = [NSString stringWithFormat:@"%li-%@-%@", (long)aEvent, aGroupId, aExt];
    [self showAlertWithTitle:NSLocalizedString(@"multiDevices[Group]", nil) message:message];
}

#pragma mark - EMChatManagerDelegate
- (void)cmdMessagesDidReceive:(NSArray<EMChatMessage *> *)aCmdMessages {
    
    for (int i = 0; i < aCmdMessages.count; ++i) {
        EMChatMessage *msg = aCmdMessages[i];
        if (msg.body.type == EMMessageBodyTypeCmd) {
            EMCmdMessageBody *cmdBody = (EMCmdMessageBody *)msg.body;
            if ([cmdBody.action isEqualToString:RequestJoinGroupEvent]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationRequestJoinGroupEvent object:nil];
            }
            
            //音视频通话开始结束
            if (msg.ext.count > 0 && [cmdBody.action isEqualToString:MutiCallAction]) {
                [self insertMsgWithCMDMessage:msg];
            }
            
            //免打扰多端同步
            if (msg.ext.count > 0 && [cmdBody.action isEqualToString:@"event"]) {
                [self _updateNoDisturbWithExt:msg.ext];
            }
         
            //群组创建
            if (msg.ext.count > 0 && [cmdBody.action isEqualToString:@"groupCreateEvent"]) {
//            群组创建：action:"groupCreateEvent" "ext":{"eventType":"groupCreate", "groupName":"xxx"}

                [self createGroupChatConvsationWithCMDMsg:msg];
            }
            
            
            //成员加入
            if (msg.ext.count > 0 && [cmdBody.action isEqualToString:@"groupJoinEvent"]) {
//            成员加入：action:"groupJoinEvent" "ext":{"eventType":"groupJoin", "userName":"xxx"}
                [self memberJoinedGroupWithCMDMsg:msg];
            }
            
        }
    }
        
}

- (void)_updateNoDisturbWithExt:(NSDictionary *)ext {
        
//action:event
//"eventType":"groupNoPush"/"userNoPush"
//"noPush":true/false
//"id":"xxx"
    
    NSString *eventType = ext[@"eventType"];
    if ([eventType isEqualToString:@""]) {
        BOOL noPush = [ext[@"noPush"] boolValue];
        NSString *convId = ext[@"id"];

        [[EaseIMKitManager shared] updateUndisturbMapsKey:convId value:noPush];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveMutiDeviceNoDisturb object:nil];
    }

}


- (void)insertMsgWithCMDMessage:(EMChatMessage  *)cmdMessage {
    
    NSString *callState = cmdMessage.ext[MutiCallCallState];
    NSString *callUser = cmdMessage.ext[MutiCallCallUser];

    NSString *msgText = @"";
    if ([callState isEqualToString:MutiCallCreateCall]) {
        msgText = [NSString stringWithFormat:@"%@ 发起了语音通话",callUser];
    }else {
        msgText = @"语音通话已经结束";
    }
    NSLog(@"%s msgText:%@",__func__,msgText);
       
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:msgText];
        
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:cmdMessage.conversationId from:cmdMessage.from to:cmdMessage.to body:body ext:cmdMessage.ext];
    
    message.chatType = cmdMessage.chatType;
    message.isRead = YES;
    message.timestamp = cmdMessage.timestamp;
    message.localTime = cmdMessage.localTime;
    message.messageId = cmdMessage.messageId;
    
    
    EMConversation *groupChat =  [[EMClient sharedClient].chatManager getConversation:cmdMessage.conversationId type:EMConversationTypeGroupChat createIfNotExist:YES];
    
    [groupChat insertMessage:message error:nil];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveMutiCallStartOrEnd object:message];
}


- (void)createGroupChatConvsationWithCMDMsg:(EMChatMessage *)msg {
//群组创建：action:"groupCreateEvent" "ext":{"eventType":"groupCreate", "groupName":"xxx"}

    NSDictionary *ext = msg.ext;
    
    NSString *eventType = ext[@"eventType"];
    if ([eventType isEqualToString:@"groupCreate"]) {
        NSString *groupId = msg.to;
        //专属群需要更新本地专属群Id数组
        BOOL isExGroup = [ext[@"action"] boolValue];
        if (isExGroup) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveCMDCreateExGroup object:groupId];
        }
        
        [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:groupId completion:^(EMGroup *aGroup, EMError *aError) {
            if (!aError) {
                
                EMConversation *groupConv = [[EMClient sharedClient].chatManager getConversation:groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
                if (isExGroup) {
                    groupConv.ext = @{@"JiHuExGroupChat":@(YES)};
                }

                
                [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveCMDCreateGroupChat object:nil];
            } else {
                // do nothing
            }
        }];
    }
}


- (void)memberJoinedGroupWithCMDMsg:(EMChatMessage *)msg {
    //            成员加入：action:"groupJoinEvent" "ext":{"eventType":"groupJoin", "userName":"xxx"}

    NSDictionary *ext = msg.ext;
    
    NSString *eventType = ext[@"eventType"];
    if ([eventType isEqualToString:@"groupJoin"]) {
        NSString *userName = ext[@"userName"];
        NSString *groupName = [EMGroup groupWithId:msg.to].groupName;

        
        
//        NSString *message = [NSString stringWithFormat:@"%@加入%@",userName,groupName];
//
//        EaseAlertView *alertView = [[EaseAlertView alloc] initWithTitle:@"提示" message:message];
//        [alertView show];

    }
    
}


#pragma mark - EMGroupManagerDelegate
- (void)groupSpecificationDidUpdate:(EMGroup *)aGroup {
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:aGroup.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveGroupInfoUpdate object:aGroup];
        } else {
            // do nothing
        }
    }];
    
}



- (void)didJoinGroup:(EMGroup *)aGroup inviter:(NSString *)aInviter message:(NSString *)aMessage
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"agreeJoinGroup", nil),[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
//    [alertView show];
}

- (void)didJoinedGroup:(EMGroup *)aGroup
               inviter:(NSString *)aInviter
               message:(NSString *)aMessage
{
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:[NSString stringWithFormat:NSLocalizedString(@"group.somebodyInvite", nil), aInviter, [NSString stringWithFormat:@"「%@」",aGroup.groupName]]];
//    [alertView show];
}

- (void)groupInvitationDidDecline:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"refuseJoinPrompt", nil), aInvitee, aGroup.groupName];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
//    [alertView show];
}

- (void)groupInvitationDidAccept:(EMGroup *)aGroup
                         invitee:(NSString *)aInvitee
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"agreeJoinPrompt", nil), aGroup.groupName, aInvitee];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
//    [alertView show];
    
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId reason:(NSString *)aReason
{
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), aGroupId];
    }
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:aReason];
//    [alertView show];
    
}

- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"agreedJoinGroup", nil),[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message];
//    [alertView show];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    NSString *message = NSLocalizedString(@"group.toMute", @"Mute");
    if ([aMutedMembers containsObject:EMClient.sharedClient.currentUsername]){
            message = [NSString stringWithFormat:NSLocalizedString(@"mutedPrompt", nil),[NSString stringWithFormat:@"「%@」",aGroup.groupName]];

        [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveMute object:aGroup];

    }
       
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    NSString *message = NSLocalizedString(@"group.toMute", @"Mute");
    if ([aMutedMembers containsObject:EMClient.sharedClient.currentUsername])
    {
        message = [NSString stringWithFormat:NSLocalizedString(@"unmutedPrompt", nil),[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//        EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
//        [alertView show];
  

        [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveUnMute object:aGroup];

    }
       
}

- (void)groupAllMemberMuteChanged:(EMGroup *)aGroup isAllMemberMuted:(BOOL)aMuted
{
    NSString * message = [NSString stringWithFormat:NSLocalizedString(@"allMutedPrompt", nil),[NSString stringWithFormat:@"「%@」",aGroup.groupName],aMuted ? NSLocalizedString(@"enable", nil) : NSLocalizedString(@"close", nil)];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
//    [alertView show];
    
}

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup addedWhiteListMembers:(NSArray *)aMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    if ([aMembers containsObject:EMClient.sharedClient.currentUsername]) {
        NSString * message = [NSString stringWithFormat:NSLocalizedString(@"addtowhitelistPrompt", nil),[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//        EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
//        [alertView show];
    }
}

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup removedWhiteListMembers:(NSArray *)aMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    if ([aMembers containsObject:EMClient.sharedClient.currentUsername]) {
        NSString * message = [NSString stringWithFormat:NSLocalizedString(@"removefromwhitelistPrompt", nil),[NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//        EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:message];
//        [alertView show];
    }
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"tobeadminPrompt", nil), aAdmin, [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.adminUpdate", @"Group Admin Update") message:msg];
//    [alertView show];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"memberPrompt", nil), aAdmin, [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.adminUpdate", @"Group Admin Update") message:msg];
//    [alertView show];

}

- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

//    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"groupOwnerChangePrompt", nil), aOldOwner, [NSString stringWithFormat:@"「%@」",aGroup.groupName], aNewOwner];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.ownerUpdate", @"Group Owner Update") message:msg];
//    [alertView show];
}

- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

//    NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", aUsername, NSLocalizedString(@"group.join", @"Join the group"), [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.membersUpdate", @"Group Members Update") message:msg];
//    [alertView show];
}

- (void)userDidLeaveGroup:(EMGroup *)aGroup
                     user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", aUsername, NSLocalizedString(@"group.leave", @"Leave group"), [NSString stringWithFormat:@"「%@」",aGroup.groupName]];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.membersUpdate", @"Group Members Update") message:msg];
//    [alertView show];
}

- (void)didLeaveGroup:(EMGroup *)aGroup reason:(EMGroupLeaveReason)aReason
{
//    __block EaseAlertView *alertView = nil;
//    if (aReason == EMGroupLeaveReasonBeRemoved) {
//        alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.leave", @"Leave group") message:[NSString stringWithFormat:NSLocalizedString(@"removedFromGroupPrompt", nil), aGroup.groupName]];
//
//        [[EMClient sharedClient].chatManager deleteServerConversation:aGroup.groupId conversationType:EMConversationTypeGroupChat isDeleteServerMessages:NO completion:^(NSString *aConversationId, EMError *aError) {
//
//            alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.leave", @"Leave group") message:[NSString stringWithFormat:NSLocalizedString(@"removedFromGroupPrompt", nil), aError.errorDescription]];
//            [alertView show];
//
//            [[EMClient sharedClient].chatManager deleteConversation:aGroup.groupId isDeleteMessages:NO completion:nil];
//        }];
//    }
//    if (aReason == EMGroupLeaveReasonDestroyed) {
//        alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.leave", @"Leave group") message:[NSString stringWithFormat:NSLocalizedString(@"groupDestroiedPrompt", nil), aGroup.groupName]];
//        [[EMClient sharedClient].chatManager deleteServerConversation:aGroup.groupId conversationType:EMConversationTypeGroupChat isDeleteServerMessages:NO completion:^(NSString *aConversationId, EMError *aError) {
//
//            alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.leave", @"Leave group") message:[NSString stringWithFormat:NSLocalizedString(@"removedFromGroupPrompt", nil), aError.errorDescription]];
//            [alertView show];
//
//            [[EMClient sharedClient].chatManager deleteConversation:aGroup.groupId isDeleteMessages:NO completion:nil];
//        }];
//    }
}

- (void)groupAnnouncementDidUpdate:(EMGroup *)aGroup
                      announcement:(NSString *)aAnnouncement
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];

    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"annoumentUpdate", nil),aGroup.groupName];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.announcementUpdate", @"Group Announcement Update") message:msg];
//    [alertView show];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               addedSharedFile:(EMGroupSharedFile *)aSharedFile
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupSharedFile" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.uploadSharedFile", @"Group:%@ Upload file ID: %@"), [NSString stringWithFormat:@"「%@」",aGroup.groupName], aSharedFile.fileId];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.sharedFileUpdate", @"Group SharedFile Update") message:msg];
//    [alertView show];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
             removedSharedFile:(NSString *)aFileId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupSharedFile" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.removeSharedFile", @"Group:%@ Remove file ID: %@"), [NSString stringWithFormat:@"「%@」",aGroup.groupName], aFileId];
//    EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:NSLocalizedString(@"group.sharedFileUpdate", @"Group SharedFile Update") message:msg];
//    [alertView show];
}

#pragma mark - EMContactManagerDelegate

- (void)friendRequestDidApproveByUser:(NSString *)aUsername
{
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"agreeContactPrompt", nil), aUsername];
    [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername
{
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"refuseContactPrompt", nil), aUsername];
    [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
}

#pragma mark - private

- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getGroupsWithoutPushNotification:nil];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

#pragma mark - NSNotification
- (void)updateUIWithCallCMDMessage:(NSNotification *)notify {
    EMChatMessage *msg = (EMChatMessage *)notify.object;
    [[EaseIMHelper shareHelper] insertMsgWithCMDMessage:msg];
    
}


- (void)handlePushChatController:(NSNotification *)aNotif
{
    id object = aNotif.object;
    EMConversationType type = -1;
    NSString *conversationId = nil;
    if ([object isKindOfClass:[NSString class]]) {
        conversationId = (NSString *)object;
        type = EMConversationTypeChat;
        
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[conversationId]];

    } else if ([object isKindOfClass:[EMGroup class]]) {
        EMGroup *group = (EMGroup *)object;
        conversationId = group.groupId;
        type = EMConversationTypeGroupChat;
    } else if ([object isKindOfClass:[EMChatroom class]]) {
        EMChatroom *chatroom = (EMChatroom *)object;
        conversationId = chatroom.chatroomId;
        type = EMConversationTypeChatRoom;
    } else if ([object isKindOfClass:[EaseConversationModel class]]) {
        EaseConversationModel *model = (EaseConversationModel *)object;
        conversationId = model.easeId;
        type = model.type;
        
        if (model.type == EMConversationTypeChat) {
            [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[conversationId]];
        }
    }
    
    EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:conversationId conversationType:type];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;

        if (conversationId.length > 0) {
            [self.pushedConvIdArray addObject:conversationId];
        }
        [nav pushViewController:controller animated:YES];
    }
    
}


- (void)handlePushGroupsController:(NSNotification *)aNotif
{

    
}

#pragma mark BannerView
- (void)handlePushBannerMsgController:(NSNotification *)aNotif
{
    EMChatMessage *msg = (EMChatMessage *)aNotif.object;
    [self showBanneMessage:msg];
}

- (void)bannerDidClick:(NSNotification*)notify {
    EMChatMessage *msg = (EMChatMessage *)notify.object;
    NSLog(@"%s msg:%@",__func__,msg);
    EMConversationType type = -1;
    
    if (msg.chatType == EMChatTypeChat) {
        type = EMConversationTypeChat;
    }
    if (msg.chatType == EMChatTypeGroupChat) {
        type = EMConversationTypeGroupChat;
    }
    EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:msg.conversationId conversationType:type];
    

    [self.bannerView hideWithCompletion:^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootViewController = window.rootViewController;
        NSLog(@"%s window:%@\n rootViewController:%@\n",__func__,window,rootViewController);
        
        if ([rootViewController isKindOfClass:[UINavigationController class]]) {
            NSLog(@"====isKindOfClass=======");
    
            UINavigationController *nav = (UINavigationController *)rootViewController;
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
    
            //入栈
            if (msg.conversationId.length > 0) {
                [self.pushedConvIdArray addObject:msg.conversationId];
            }

            [nav pushViewController:controller animated:YES];
        }
        
    }];
    
}


- (void)showBanneMessage:(EMChatMessage *)aMessage {
    
    EMChatMessage *msg = aMessage;
        
    UIImage *icon = nil;
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        icon = [UIImage easeUIImageNamed:@"jh_group_icon"];
    }else {
        if (msg.chatType == EMChatTypeGroupChat) {
            icon = [UIImage easeUIImageNamed:@"jh_group_icon"];
        }
        if (msg.chatType == EMChatTypeChat) {
            icon = [UIImage easeUIImageNamed:@"jh_user_icon"];
        }
    }
        
    
    NSString *title = [self getConvsationTitleWithBannerMsgFromId:msg];
    NSString *content = [self getContentFromBannerMsg:msg];
    
    NSString *prefix = @"";
//    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//        prefix = @"ARCFOX极狐";
//    }else {
//        prefix = @"服务小组";
//    }

    NSString *timeString = [NSString stringWithFormat:@"%@ %@",prefix,[EaseDateHelper formattedTimeFromTimeInterval:msg.timestamp]];
    
    self.bannerView = [EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
        make.style = 11;
        make.icon = icon;
        make.title = title;
        make.content = content;
        make.date = timeString;
        make.object = msg;
        make.stayDuration = 2.0;
    }];
    [self.bannerView show];
}

- (NSString *)getUserNameFromBannerMsgFromId:(NSString *)aUid {
    NSString *userName = aUid;
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUid];
    if(userInfo) {
        userName = userInfo.nickname.length > 0 ? userInfo.nickname: userInfo.userId;
        
    }else{
        userName = aUid;
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[aUid]];
    }
    return userName;

}

- (NSString *)getContentFromBannerMsg:(EMChatMessage *)msg {
    NSString *msgStr = nil;
    switch (msg.body.type) {
        case EMMessageBodyTypeText:
        {
            EMTextMessageBody *body = (EMTextMessageBody *)msg.body;
            msgStr = body.text;
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLER_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"noRespond", nil);
            }
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"remoteCancel", nil);
            }
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            msgStr = EaseLocalizableString(@"[location]", nil);
        }
            break;
        case EMMessageBodyTypeCustom:
        {
            msgStr = EaseLocalizableString(@"[customemsg]", nil);
        }
            break;
        case EMMessageBodyTypeImage:
        {
            msgStr = EaseLocalizableString(@"[image]", nil);
        }
            break;
        case EMMessageBodyTypeFile:
        {
            msgStr = EaseLocalizableString(@"[file]", nil);
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            msgStr = EaseLocalizableString(@"[audio]", nil);
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            msgStr = EaseLocalizableString(@"[video]", nil);
        }
            break;
            
        default:
            break;
    }
    
    NSString *content = [NSString stringWithFormat:@"%@:%@",[self getUserNameFromBannerMsgFromId:msg.from],msgStr];
    
    
    return content;
}

- (NSString *)getConvsationTitleWithBannerMsgFromId:(EMChatMessage *)msg {
    
    NSString *title = @"";
    if (msg.chatType == EMChatTypeGroupChat) {
        EMGroup *group = [EMGroup groupWithId:msg.conversationId];
        title = group.groupName;
    }
    
    if (msg.chatType == EMChatTypeChat) {
        title = [self getUserNameFromBannerMsgFromId:msg.from];
    }
    return [NSString stringWithFormat:@"[%@]",title];
}


#pragma mark jihu ExGroup
- (void)jiHuExGroupPushChatViewController:(NSNotification *)notify {
    
    NSArray *exGroupIds = (NSArray *)notify.object;

    if (exGroupIds.count == 0) {

    }
    
    BOOL isSingleGroupChat = NO;

    if (exGroupIds.count > 0) {
        if (exGroupIds.count == 1) {
            isSingleGroupChat = YES;
        }
    }

    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;

        if (isSingleGroupChat) {
            EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:exGroupIds.lastObject conversationType:EMConversationTypeGroupChat];
            
            [nav pushViewController:controller animated:YES];

        }else {
            EMConversationsViewController * conversationsVC= [[EMConversationsViewController alloc] initWithEnterType:EMConversationEnterTypeExclusiveGroup];

            [nav pushViewController:conversationsVC animated:YES];

        }
    }
}


- (void)clearGroupAtInfo {
    [self.grpupAtArray removeAllObjects];
    self.isAtAll = NO;
}

- (void)fetchAllMembersUserInfoWithGroup:(EMGroup *)aGroup {
    if (aGroup == nil) {
        return;
    }
    
    
    NSMutableArray *mArray = [NSMutableArray array];
    [mArray addObject:aGroup.owner];
    [mArray addObjectsFromArray:aGroup.memberList];
    
    [[UserInfoStore sharedInstance] fetchUserInfosFromServer:mArray];
}

#pragma mark getter and setter
- (NSMutableArray<NSString *> *)pushedConvIdArray {
    if (_pushedConvIdArray == nil) {
        _pushedConvIdArray = [NSMutableArray array];
    }
    return _pushedConvIdArray;
}

- (NSMutableArray *)grpupAtArray {
    if (_grpupAtArray == nil) {
        _grpupAtArray = [NSMutableArray array];
    }
    return _grpupAtArray;
}

@end
