//
//  EaseIMKitManager.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseIMKitManager.h"
#import "EaseConversationsViewController.h"
#import "EaseIMKitManager+ExtFunction.h"
#import "EaseMulticastDelegate.h"
#import "EaseDefines.h"

#import "EaseIMKitOptions.h"
#import "EaseIMKitAppStyle.h"
#import "EaseIMHelper.h"
#import "EMNotificationHelper.h"
#import "UserInfoStore.h"
#import "EaseCallManager.h"
#import "SingleCallController.h"
#import "ConferenceController.h"
#import "MBProgressHUD.h"
#import "EaseHttpManager.h"
#import "EaseHeaders.h"
#import "EaseIMKitMessageHelper.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EBBannerView.h"
#import "EMRemindManager.h"
#import "EaseKitUtil.h"
#import "EMChatViewController.h"
#import "EMConversationsViewController.h"


bool gInit;
static EaseIMKitManager *easeIMKit = nil;
static NSString *g_UIKitVersion = @"1.0.0";

@interface EaseIMKitManager ()<EMMultiDevicesDelegate, EMContactManagerDelegate, EMGroupManagerDelegate, EMChatManagerDelegate,EaseCallDelegate>
@property (nonatomic, strong) EaseMulticastDelegate<EaseIMKitManagerDelegate> *delegates;
@property (nonatomic, assign) NSInteger currentUnreadCount; //当前未读总数
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, strong) NSMutableDictionary *undisturbMaps;//免打扰会话的map

//是否是极狐app
@property (nonatomic, assign) BOOL isJiHuApp;
//专属群未读数
@property (nonatomic, assign) NSInteger exclusivegroupUnReadCount;

@property (nonatomic, strong) NSMutableArray *joinedGroupIdArray;

//极狐专属服务群id列表
@property (nonatomic, strong) NSMutableArray *exGroupIds;

//加入的群组的人数字典
@property (nonatomic, strong) NSMutableDictionary *joinedGroupMemberDic;



@end

#define IMKitVersion @"1.0.0"

@implementation EaseIMKitManager
+ (BOOL)managerWithEaseIMKitOptions:(EaseIMKitOptions *)options {
    if (!gInit) {
        [EMClient.sharedClient initializeSDKWithOptions:[options toOptions]];
        [[self shareInstance] configIMKitWithOption:options];
        
        gInit = YES;
    }
    
    return gInit;
}

- (void)configIMKitWithOption:(EaseIMKitOptions *)option {
    [EaseIMKitManager.shared configuationIMKitIsJiHuApp:option.isJiHuApp];
    
    //初始化EaseIMHelper，注册 EMClient 监听
    [EaseIMHelper shareHelper];
    [EaseIMKitMessageHelper shareMessageHelper];

    
    if (option.isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@(YES)];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@(NO)];
    }
    
}
    

- (void)updateSettingAfterLoginSuccess {
    
    [[EMClient sharedClient].pushManager getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions * _Nonnull aOptions, EMError * _Nonnull aError) {
        if (!aError) {
            [[EaseIMKitManager shared] cleanMemoryUndisturbMaps];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EMUserPushConfigsUpdateSuccess" object:nil];//更新用户重启App时，会话免打扰状态UI同步
        }
    }];
    
    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:0 pageSize:-1 completion:^(NSArray<EMGroup *> *aList, EMError * _Nullable aError) {
        
        if (!aError) {
            
            NSMutableArray *tArray = [NSMutableArray array];
            for (int i = 0; i < aList.count; ++i) {
                EMGroup *group = aList[i];
                if (group) {
                    [tArray addObject:group.groupId];
                }
                [self fetchGroupSpecWithGroupId:group.groupId];
            }
            self.joinedGroupIdArray = [tArray mutableCopy];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_LIST_FETCHFINISHED object:self.joinedGroupIdArray];
        }
    }];
    
    
    [EMNotificationHelper shared];
    [SingleCallController sharedManager];
    [ConferenceController sharedManager];
    
    [[UserInfoStore sharedInstance] loadInfosFromLocal];
          
    EaseCallConfig* config = [[EaseCallConfig alloc] init];
//    config.agoraAppId = @"15cb0d28b87b425ea613fc46f7c9f974";
    config.agoraAppId = @"943bfefbbfb54b3cac36507a1b006a9f";

    config.enableRTCTokenValidate = YES;

    [[EaseCallManager sharedManager] initWithConfig:config delegate:self];
    
    [self fetchOwnUserInfo];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [self fetchJiHuExGroupList];
    }else {
        [self fetchAllConvsationsAndloadUnreadCount];
    }
    
}

- (void)fetchGroupSpecWithGroupId:(NSString *)groupId {
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        if (aError == nil) {
            if (aGroup.memberList >0) {
                [self.joinedGroupMemberDic setObject:@(aGroup.memberList.count) forKey:aGroup.groupId];
            }
        }
    }];
}



- (void)fetchJiHuExGroupList {
    //极狐需要调接口
    [[EaseHttpManager sharedManager] fetchExclusiveServerGroupListWithCompletion:^(NSInteger statusCode, NSString * _Nonnull response) {

        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSArray *groups = responsedict[@"entity"];
                NSMutableArray *tGroupIds = [NSMutableArray array];
                for (int i = 0; i< groups.count; ++i) {
                    NSDictionary *groupDic = groups[i];
                    NSString *groupId = groupDic[@"groupId"];
                    if (groupId) {
                        [tGroupIds addObject:groupId];
                    }
                }
                self.exGroupIds = tGroupIds;
                [self createExGroupsConversations];
                [self fetchAllConvsationsAndloadUnreadCount];


            }else {
                NSLog(@"%s errorDescription:%@",__func__,errorDescription);
            }

        }

    }];

}


- (void)createExGroupsConversations {
    NSArray *exGroupIds = self.exGroupIds;
    for (int i = 0; i < exGroupIds.count; ++i) {
        NSString *groupId = exGroupIds[i];
       EMConversation *groupConv =  [[EMClient sharedClient].chatManager getConversation:groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
        groupConv.ext = @{@"JiHuExGroupChat":@(YES)};
    }

}

    
- (void)fetchAllConvsationsAndloadUnreadCount {
    if (![EaseIMKitOptions sharedOptions].isFirstLaunch) {
        [EaseIMKitOptions sharedOptions].isFirstLaunch = YES;
        [[EaseIMKitOptions sharedOptions] archive];
        
        [[EMClient sharedClient].chatManager getConversationsFromServer:^(NSArray *aCoversations, EMError *aError) {
            [self _resetConversationsUnreadCount];
        }];
    }else {
        [self _resetConversationsUnreadCount];
    }
}



- (void)fetchOwnUserInfo {
    NSString *username = [EMClient sharedClient].currentUsername;
    if (username.length == 0) {
        return;
    }
    [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[username]];
}




+ (EaseIMKitManager *)shared {
    return easeIMKit;
}

+ (NSString *)EaseIMKitVersion {
    return IMKitVersion;
}

+ (EaseIMKitManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (easeIMKit == nil) {
            easeIMKit = [[EaseIMKitManager alloc] init];
        }
    });
    return easeIMKit;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = (EaseMulticastDelegate<EaseIMKitManagerDelegate> *)[[EaseMulticastDelegate alloc] init];
        _msgQueue = dispatch_queue_create("easemessage.com", NULL);
        _undisturbMaps = [NSMutableDictionary dictionary];
    }
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChanged:) name:ACCOUNT_LOGIN_CHANGED object:nil];


    return self;
}

- (void)dealloc
{
    [self.delegates removeAllDelegates];
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark NSNotification
- (void)loginStateChanged:(NSNotification *)notify {
    BOOL loginSuccess = [notify.object boolValue];
    if (loginSuccess) {
        [self updateSettingAfterLoginSuccess];
    }
}


#pragma mark - Public

- (NSString *)version
{
    return g_UIKitVersion;
}

- (void)addDelegate:(id<EaseIMKitManagerDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EaseIMKitManagerDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

#pragma mark - EMChatManageDelegate

//收到消息
- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self _resetConversationsUnreadCount];
    
    for (int i = 0 ; i < aMessages.count; ++i) {
        EMChatMessage *msg = aMessages[i];
        NSString *action = msg.ext[@"action"];
        if ([action isEqualToString:@"invite"]) {
            //通话邀请
            continue;
        }
        if (i == aMessages.count - 1) {
            BOOL isShow = [self isShowbannerMessage:msg];
            if (!isShow) {
                [EMRemindManager remindMessage:msg];
                return;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:Banner_PUSHVIEWCONTROLLER object:msg];
            
        }else {
            [EMRemindManager remindMessage:msg];
        }
        
    }
    
}



- (BOOL)isShowbannerMessage:(EMChatMessage *)aMessage {
    BOOL isShow = NO;
    EMChatMessage *msg = aMessage;

    if ([self isNoDisturbWithConvId:aMessage.conversationId]) {
        isShow = NO;
        return isShow;
    }
    
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        UIViewController *currentVC =  [EaseKitUtil currentViewController];
        
        NSLog(@"%s currentVC:%@",__func__,currentVC);
        
        NSString *topConvId = [EaseIMHelper shareHelper].pushedConvIdArray.lastObject;
        
        //存在active会话页面
        if (topConvId.length > 0) {
            
            NSLog(@"%s topConvId:%@",__func__,topConvId);

            if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
                //是群聊且不是当前消息的专属群页面 应当跳转到专属群
                if (msg.chatType == EMChatTypeGroupChat && ![msg.conversationId isEqualToString:topConvId] &&[self.exGroupIds containsObject:msg.conversationId]) {
                    isShow = YES;
                }
                
            }else {
                if ((msg.chatType == EMChatTypeGroupChat||msg.chatType == EMChatTypeChat) && ![msg.conversationId isEqualToString:topConvId]) {
                    isShow = YES;
                }
            }

            
        }else {
            //非聊天界面
            if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
                if (msg.chatType == EMChatTypeGroupChat &&[self.exGroupIds containsObject:msg.conversationId]) {
                    isShow = YES;
                }
            }else {
                
                if (msg.chatType == EMChatTypeGroupChat||msg.chatType == EMChatTypeChat) {
                    isShow = YES;
                }
            }
        }
        
    }

    return isShow;
}


- (BOOL)isNoDisturbWithConvId:(NSString *)convId {
    // 是否是免打扰的消息(聊天室没有免打扰消息)
    BOOL unremindChat = [self _unremindChat:convId];//单聊免打扰
    BOOL unremindGroup = [self _unremindGroup:convId];//群组免打扰
    return unremindChat || unremindGroup;
}


- (BOOL)_unremindGroup:(NSString *)fromChatter {
    return [[[EMClient sharedClient].pushManager noPushGroups] containsObject:fromChatter];
}

- (BOOL)_unremindChat:(NSString *)conversationId {
    return [[[EMClient sharedClient].pushManager noPushUIds] containsObject:conversationId];
}


#pragma mark - EMContactManagerDelegate

//收到好友请求
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage
{
    if ([aUsername length] == 0) {
        return;
    }
    [self structureSystemNotification:aUsername userName:aUsername reason:ContanctsRequestDidReceive];
}

//收到好友请求被同意/同意
- (void)friendshipDidAddByUser:(NSString *)aUsername
{
    [self notificationMsg:aUsername aUserName:aUsername conversationType:EMConversationTypeChat];
}

#pragma mark - EMGroupManagerDelegate

//群主同意用户A的入群申请后，用户A会接收到该回调
- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup
{
    [self notificationMsg:aGroup.groupId aUserName:EMClient.sharedClient.currentUsername conversationType:EMConversationTypeGroupChat];
}

//有用户加入群组
- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [self notificationMsg:aGroup.groupId aUserName:aUsername conversationType:EMConversationTypeGroupChat];
}

//收到群邀请
- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    if ([aGroupId length] == 0 || [aInviter length] == 0) {
        return;
    }
    [self structureSystemNotification:aGroupId userName:aInviter reason:GroupInvitationDidReceive];
}

//收到加群申请
- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason
{
    if ([aGroup.groupId length] == 0 || [aUsername length] == 0) {
        return;
    }
    [self structureSystemNotification:aGroup.groupId userName:aUsername reason:JoinGroupRequestDidReceive];
}

#pragma mark - private

//系统通知构造为会话
- (void)structureSystemNotification:(NSString *)conversationId userName:(NSString*)userName reason:(EaseIMKitCallBackReason)reason
{
    if (![self isNeedsSystemNoti]) {
        return;
    }
    NSString *notificationStr = nil;
    NSString *notiType = nil;
    if (reason == ContanctsRequestDidReceive) {
        notificationStr = [NSString stringWithFormat:EaseLocalizableString(@"friendApplyfrom", nil),conversationId];
        notiType = SYSTEM_NOTI_TYPE_CONTANCTSREQUEST;
    }
    if (reason == GroupInvitationDidReceive) {
        notificationStr = [NSString stringWithFormat:EaseLocalizableString(@"joinInvitefrom", nil),userName];
        notiType = SYSTEM_NOTI_TYPE_GROUPINVITATION;
    }
    if (reason == JoinGroupRequestDidReceive) {
        notificationStr = [NSString stringWithFormat:EaseLocalizableString(@"joinApplyfrom", nil),userName];
        notiType = SYSTEM_NOTI_TYPE_JOINGROUPREQUEST;
    }
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveShowMessage:requestUser:reason:)]) {
        NSString *tempStr = [self.systemNotiDelegate requestDidReceiveShowMessage:conversationId requestUser:userName reason:reason];
        // 空字符串返回不做操作 / nil：默认操作 / 有自定义值其他长度值使用自定义值
        if (tempStr) {
            if ([tempStr isEqualToString:@""]) {
                return;
            } else if (tempStr.length > 0) {
                notificationStr = tempStr;
            }
        }
    }
    EMTextMessageBody *body = [[EMTextMessageBody alloc]initWithText:notificationStr];
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:EMSYSTEMNOTIFICATIONID from:userName to:EMClient.sharedClient.currentUsername body:body ext:nil];
    message.timestamp = [self getLatestMsgTimestamp];
    message.isRead = NO;
    message.chatType = EMChatTypeChat;
    message.direction = EMMessageDirectionReceive;
    EMConversation *notiConversation = [[EMClient sharedClient].chatManager getConversation:message.conversationId type:EMConversationTypeChat createIfNotExist:YES];
    NSDictionary *ext = nil;
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveConversationExt:requestUser:reason:)]) {
        ext = [self.systemNotiDelegate requestDidReceiveConversationExt:conversationId requestUser:userName reason:reason];
    } else {
        ext = @{SYSTEM_NOTI_TYPE:notiType};
    }
    [notiConversation setExt:ext];
    [notiConversation insertMessage:message error:nil];
    [self _resetConversationsUnreadCount];
    //刷新会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATIONLIST_UPDATE object:nil];
}

//加好友，加群 成功通知
- (void)notificationMsg:(NSString *)itemId aUserName:(NSString *)aUserName conversationType:(EMConversationType)aType
{
    return;
    EMConversationType conversationType = aType;
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:itemId type:conversationType createIfNotExist:YES];
    EMTextMessageBody *body;
    NSString *to = itemId;
    EMChatMessage *message;
    if (conversationType == EMChatTypeChat) {
        body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:EaseLocalizableString(@"friended", nil),aUserName]];
        message = [[EMChatMessage alloc] initWithConversationID:to from:EMClient.sharedClient.currentUsername to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDFRIEND}];
    } else if (conversationType == EMChatTypeGroupChat) {
        if ([aUserName isEqualToString:EMClient.sharedClient.currentUsername]) {
            body = [[EMTextMessageBody alloc] initWithText:EaseLocalizableString(@"joinedgroup", nil)];
        } else {
            body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:EaseLocalizableString(@"userjoinGroup", nil),aUserName]];
        }
        message = [[EMChatMessage alloc] initWithConversationID:to from:aUserName to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDGROUP}];
    }
    message.chatType = (EMChatType)conversation.type;
    message.isRead = YES;
    [conversation insertMessage:message error:nil];
    //刷新会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATIONLIST_UPDATE object:nil];
}

//最新消息时间
- (long long)getLatestMsgTimestamp
{
    return [[NSDate new] timeIntervalSince1970] * 1000;
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    __weak typeof(self) weakself = self;
    if (aEvent == EMMultiDevicesEventContactAccept || aEvent == EMMultiDevicesEventContactDecline) {
        EMConversation *systemConversation = [EMClient.sharedClient.chatManager getConversation:EMSYSTEMNOTIFICATIONID type:-1 createIfNotExist:NO];
        [systemConversation loadMessagesStartFromId:nil count:systemConversation.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            BOOL hasUnreadMsg = NO;
            for (EMChatMessage *message in aMessages) {
                if (message.isRead == NO && message.chatType == EMChatTypeChat) {
                    message.isRead = YES;
                    hasUnreadMsg = YES;
                }
            }
            if (hasUnreadMsg) {
                [weakself _resetConversationsUnreadCount];
            }
        }];
    }
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    __weak typeof(self) weakself = self;
    if (aEvent == EMMultiDevicesEventGroupInviteDecline || aEvent == EMMultiDevicesEventGroupInviteAccept || aEvent == EMMultiDevicesEventGroupApplyAccept || aEvent == EMMultiDevicesEventGroupApplyDecline) {
        EMConversation *systemConversation = [EMClient.sharedClient.chatManager getConversation:EMSYSTEMNOTIFICATIONID type:-1 createIfNotExist:NO];
        [systemConversation loadMessagesStartFromId:nil count:systemConversation.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            BOOL hasUnreadMsg = NO;
            for (EMChatMessage *message in aMessages) {
                if (message.isRead == NO && message.chatType == EMChatTypeGroupChat) {
                    message.isRead = YES;
                    hasUnreadMsg = YES;
                }
            }
            if (hasUnreadMsg) {
                [weakself _resetConversationsUnreadCount];
            }
        }];
    }
}

#pragma mark - 未读数变化

- (BOOL)conversationUndisturb:(NSString *)conversationId {
    if (_undisturbMaps == nil) {
        _undisturbMaps = [NSMutableDictionary dictionary];
    }
    if (_undisturbMaps.count <= 0) {
        [self fillUndisturbMaps];
    }
    if (conversationId == nil) { return NO; }
    return [[_undisturbMaps valueForKey:conversationId] boolValue];
}

- (void)updateUndisturbMapsKey:(NSString *)key value:(BOOL )value {
    [_undisturbMaps setValue:[NSNumber numberWithBool:value] forKey:key];
}

- (void)cleanMemoryUndisturbMaps {
    _undisturbMaps = nil;
}

- (void)fillUndisturbMaps {
    for (EMConversation *conversation in [EMClient.sharedClient.chatManager getAllConversations]) {
        if ([[[EMClient sharedClient].pushManager noPushUIds] containsObject:conversation.conversationId]) {
            if ([_undisturbMaps valueForKey:conversation.conversationId] == nil) {
                [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            }
        }
        if ([[[EMClient sharedClient].pushManager noPushGroups] containsObject:conversation.conversationId]) {
            if ([_undisturbMaps valueForKey:conversation.conversationId] == nil) {
                [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            }
        }
    }
}

//会话所有信息标记已读
- (void)markAllMessagesAsReadWithConversation:(EMConversation *)conversation
{
    if (conversation && conversation.unreadMessagesCount > 0) {
        [conversation markAllMessagesAsRead:nil];
        [self _resetConversationsUnreadCount];
    }
}

//未读总数变化
- (void)_resetConversationsUnreadCount
{
    NSInteger unreadCount = 0;
    NSInteger undisturbCount = 0;
    NSInteger exclusivegroupUnReadCount = 0;

    NSArray *conversationList = [EMClient.sharedClient.chatManager getAllConversations];
    for (EMConversation *conversation in conversationList) {
        NSLog(@"%s convId:%@\n unread:%@\n",__func__,conversation.conversationId,[@(conversation.unreadMessagesCount) stringValue]);
        
//        if ([conversation.conversationId isEqualToString:_currentConversationId]) {
//            continue;
//        }
        
        if ([[[EMClient sharedClient].pushManager noPushUIds] containsObject:conversation.conversationId]) {
            undisturbCount += conversation.unreadMessagesCount;
            [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            continue;
        }
        if ([[[EMClient sharedClient].pushManager noPushGroups] containsObject:conversation.conversationId]) {
            undisturbCount += conversation.unreadMessagesCount;
            [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            continue;
        }
        unreadCount += conversation.unreadMessagesCount;
        
        //专属群未读
        if ([self.exGroupIds containsObject:conversation.conversationId]) {
            exclusivegroupUnReadCount += conversation.unreadMessagesCount;
        }
    }
    
    _currentUnreadCount = unreadCount;
    _exclusivegroupUnReadCount = exclusivegroupUnReadCount;
    [self coversationsUnreadCountUpdate:unreadCount undisturbCount:undisturbCount];
}

#pragma mark - 多播

//未读总数多播总数法
- (void)coversationsUnreadCountUpdate:(NSInteger)unreadCount undisturbCount:(NSInteger)undisturbCount
{
    EaseMulticastDelegateEnumerator *multicastDelegates = [self.delegates delegateEnumerator];
    for (EaseMulticastDelegateNode *node in [multicastDelegates getDelegates]) {
        id<EaseIMKitManagerDelegate> delegate = (id<EaseIMKitManagerDelegate>)node.delegate;
        if (delegate&&[delegate respondsToSelector:@selector(conversationsUnreadCountUpdate:)])
            [delegate conversationsUnreadCountUpdate:unreadCount];
        if (delegate&&[delegate respondsToSelector:@selector(conversationsUnreadCountUpdate:undisturbCount:)]) {
            [delegate conversationsUnreadCountUpdate:unreadCount undisturbCount:undisturbCount];
        }
    }
}

#pragma mark - 系统通知

//是否需要系统通知
- (BOOL)isNeedsSystemNoti
{
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(isNeedsSystemNotification)]) {
        return [self.systemNotiDelegate isNeedsSystemNotification];
    }
    return YES;
}

//收到请求返回展示信息
- (NSString*)requestDidReceiveShowMessage:(NSString *)conversationId requestUser:(NSString *)requestUser reason:(EaseIMKitCallBackReason)reason
{
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveShowMessage:requestUser:reason:)]) {
        return [self.systemNotiDelegate requestDidReceiveShowMessage:conversationId requestUser:requestUser reason:reason];
    }
    return @"";
}

//收到请求返回扩展信息
- (NSDictionary *)requestDidReceiveConversationExt:(NSString *)conversationId requestUser:(NSString *)requestUser reason:(EaseIMKitCallBackReason)reason
{
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveConversationExt:requestUser:reason:)]) {
        return [self.systemNotiDelegate requestDidReceiveConversationExt:conversationId requestUser:requestUser reason:reason];
    }
    return [[NSDictionary alloc]init];
}

- (void)configuationIMKitIsJiHuApp:(BOOL)isJiHuApp {

    _isJiHuApp = isJiHuApp;
    [[EaseIMKitAppStyle shareAppStyle] updateNavAndTabbarWithIsJihuApp:isJiHuApp];
}


#pragma mark EaseCallDelegate
- (void)callDidEnd:(NSString*)aChannelName reason:(EaseCallEndReason)aReason time:(int)aTm type:(EaseCallType)aCallType
{
    NSString* msg = @"";
    switch (aReason) {
        case EaseCallEndReasonHandleOnOtherDevice:
            msg = NSLocalizedString(@"otherDevice", nil);
            break;
        case EaseCallEndReasonBusy:
            msg = NSLocalizedString(@"remoteBusy", nil);
            break;
        case EaseCallEndReasonRefuse:
            msg = NSLocalizedString(@"refuseCall", nil);
            break;
        case EaseCallEndReasonCancel:
            msg = NSLocalizedString(@"cancelCall", nil);
            break;
        case EaseCallEndReasonRemoteCancel:
            msg = NSLocalizedString(@"callCancel", nil);
            break;
        case EaseCallEndReasonRemoteNoResponse:
            msg = NSLocalizedString(@"remoteNoResponse", nil);
            break;
        case EaseCallEndReasonNoResponse:
            msg = NSLocalizedString(@"noResponse", nil);
            break;
            //通话结束用会话里的灰条提示
//        case EaseCallEndReasonHangup:
//            msg = [NSString stringWithFormat:NSLocalizedString(@"callendPrompt", nil),aTm];
//            break;
        default:
            break;
    }
    
    if([msg length] > 0){
        [self showHint:msg];
    }
    
}

// 多人音视频邀请按钮的回调
- (void)multiCallDidInvitingWithCurVC:(UIViewController*_Nonnull)vc excludeUsers:(NSArray<NSString*> *_Nullable)users ext:(NSDictionary *)aExt
{
    NSString* groupId = nil;
    if(aExt) {
        groupId = [aExt objectForKey:@"groupId"];
    }
    
    ConfInviteUsersViewController * confVC = nil;
    if([groupId length] == 0) {
        confVC = [[ConfInviteUsersViewController alloc] initWithType:ConfInviteTypeUser isCreate:NO excludeUsers:users groupOrChatroomId:nil];
    }else{
        confVC = [[ConfInviteUsersViewController alloc] initWithType:ConfInviteTypeGroup isCreate:NO excludeUsers:users groupOrChatroomId:groupId];
    }
    
    [confVC setDoneCompletion:^(NSArray *aInviteUsers) {
        for (NSString* strId in aInviteUsers) {
            EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:strId];
            if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
                EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
                [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:strId info:user];
            }
        }
        [[EaseCallManager sharedManager] startInviteUsers:aInviteUsers ext:aExt completion:nil];
        
    }];
    confVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [vc presentViewController:confVC animated:NO completion:nil];
    
}


// 振铃时增加回调
- (void)callDidReceive:(EaseCallType)aType inviter:(NSString*_Nonnull)username ext:(NSDictionary*)aExt
{
    EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
    if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
        EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
        [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
    }
}

// 异常回调
- (void)callDidOccurError:(EaseCallError *)aError
{
    
}

- (void)callDidRequestRTCTokenForAppId:(NSString *)aAppId channelName:(NSString *)aChannelName account:(NSString *)aUserAccount uid:(NSInteger)aAgoraUid
{
    
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
//                                                          delegate:nil
//                                                     delegateQueue:[NSOperationQueue mainQueue]];

//    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/token/rtcToken/v1?userAccount=%@&channelName=%@&appkey=%@",[EMClient sharedClient].currentUsername,aChannelName,[EMClient sharedClient].options.appkey];
//    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//    NSURL* url = [NSURL URLWithString:utf8Url];
//    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
//    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[EMClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(data) {
//            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSLog(@"%@",body);
//            if(body) {
//                NSString* resCode = [body objectForKey:@"code"];
//                if([resCode isEqualToString:@"RES_0K"]) {
//                    NSString* rtcToken = [body objectForKey:@"accessToken"];
//                    NSNumber* uid = [body objectForKey:@"agoraUserId"];
//                    [[EaseCallManager sharedManager] setRTCToken:rtcToken channelName:aChannelName uid:[uid unsignedIntegerValue]];
//                }
//            }
//        }
//
//
//    }];
//
//    [task resume];
    
    [[EaseHttpManager sharedManager] fetchRTCTokenWithChannelName:aChannelName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
            
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            
            if(responseData) {
                NSDictionary* body = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                NSLog(@"%@",body);
                
                if(body) {
                    NSString* resCode = [body objectForKey:@"status"];
                    NSDictionary *entity = body[@"entity"];

                    if([resCode isEqualToString:@"OK"]) {
                        NSString* rtcToken = [entity objectForKey:@"token"];
                        NSNumber* uid = [entity objectForKey:@"uid"];
                        [[EaseCallManager sharedManager] setRTCToken:rtcToken channelName:aChannelName uid:[uid unsignedIntegerValue]];
                    }
                    
                }
            }
                    
        }
    }];
    
    
}

-(void)remoteUserDidJoinChannel:( NSString*_Nonnull)aChannelName uid:(NSInteger)aUid username:(NSString*_Nullable)aUserName
{
    if(aUserName.length > 0) {
        EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUserName];
        if(userInfo && (userInfo.avatarUrl.length > 0 || userInfo.nickName.length > 0)) {
            EaseCallUser* user = [EaseCallUser userWithNickName:userInfo.nickName image:[NSURL URLWithString:userInfo.avatarUrl]];
            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:aUserName info:user];
        }
    }else{
        [self _fetchUserMapsFromServer:aChannelName];
    }
}

- (void)callDidJoinChannel:(NSString*_Nonnull)aChannelName uid:(NSUInteger)aUid
{
    [self _fetchUserMapsFromServer:aChannelName];
}

- (void)_fetchUserMapsFromServer:(NSString*)aChannelName
{
    // 这里设置映射表，设置头像，昵称
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
//                                                          delegate:nil
//                                                     delegateQueue:[NSOperationQueue mainQueue]];
//
//    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/channel/mapper?userAccount=%@&channelName=%@&appkey=%@",[EMClient sharedClient].currentUsername,aChannelName,[EMClient sharedClient].options.appkey];
//    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//    NSURL* url = [NSURL URLWithString:utf8Url];
//    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
//    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[EMClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(data) {
//            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSLog(@"mapperBody:%@",body);
//            if(body) {
//                NSString* resCode = [body objectForKey:@"code"];
//                if([resCode isEqualToString:@"RES_0K"]) {
//                    NSString* channelName = [body objectForKey:@"channelName"];
//                    NSDictionary* result = [body objectForKey:@"result"];
//                    NSMutableDictionary<NSNumber*,NSString*>* users = [NSMutableDictionary dictionary];
//                    for (NSString* strId in result) {
//                        NSString* username = [result objectForKey:strId];
//                        NSNumber* uId = [NSNumber numberWithInteger:[strId integerValue]];
//                        [users setObject:username forKey:uId];
//                        EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
//                        if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
//                            EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
//                            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
//                        }
//                    }
//                    [[EaseCallManager sharedManager] setUsers:users channelName:channelName];
//                }
//            }
//        }
//    }];
//
//    [task resume];
    
    
    [[EaseHttpManager sharedManager] fetchRTCUidsWithChannelName:aChannelName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
    
        NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                
        if(responseData) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            NSLog(@"%s mapperBody:%@",__func__,body);
            
            [self parseGetUidsDataWithDic:body channelName:aChannelName];
        }
    }];
    
}

//{
//"status": "OK",
//"entity": {
//    "channelName": "",
//    "username": "",
//    "rtcChannels": [
//        "[{uid=675, channelName=27199as293jk28932, username=213221}]",
//        "[{uid=989, channelName=27199as293jk28932, username=213221}]"
//    ],
//    "uid": 0
//}
//}

- (void)parseGetUidsDataWithDic:(NSDictionary *)dic channelName:(NSString *)channelName {
    if (dic.count <= 0) {
        return;
    }
    
    NSString* resCode = [dic objectForKey:@"status"];
    NSString* error = [dic objectForKey:@"error"];

    NSDictionary *entity = dic[@"entity"];

    
    if (error.length > 0) {
        return;
    }
    
    
    if([resCode isEqualToString:@"OK"]) {
        NSDictionary* rtcChannels = [entity objectForKey:@"rtcChannels"];

        
        [self parseChannelWithChannalDic:rtcChannels channelName:channelName];
        
//        NSMutableArray* rtcChannels = [entity objectForKey:@"rtcChannels"];
//
//        NSMutableArray *tChannelUidArray = [NSMutableArray array];
//
//        for (NSString *rtcChannel in rtcChannels) {
//            if (rtcChannel.length > 0) {
//                NSRange startRange = [rtcChannel rangeOfString:@"[{"];
//                 NSRange endRange = [rtcChannel rangeOfString:@"}]"];
//                 NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
//                 NSString *result = [rtcChannel substringWithRange:range];
//                NSDictionary  *channelDic = [self getChannalUidArrayWithResult:result];
//                NSLog(@"%s channelDic:%@",__func__,channelDic);
//                [tChannelUidArray addObject:channelDic];
//            }
//        }
//
//        [self parseChannelWithChannelUidArray:tChannelUidArray channelName:channelName];

  }
    
}

- (void)parseChannelWithChannalDic:(NSDictionary *)channalDic  channelName:(NSString *)channelName {
    NSMutableDictionary<NSNumber*,NSString*>* users = [NSMutableDictionary dictionary];
    
    [channalDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        NSString* username = key;
        NSInteger uId = [obj integerValue];
        
        [users setObject:username forKey:@(uId)];
        EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
        if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
            EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
        }
    }];
    
    [[EaseCallManager sharedManager] setUsers:users channelName:channelName];

}



- (void)parseChannelWithChannelUidArray:(NSMutableArray *)channelUidArray  channelName:(NSString *)channelName {
    NSMutableDictionary<NSNumber*,NSString*>* users = [NSMutableDictionary dictionary];
    
    for (NSDictionary* infoDic in channelUidArray) {
        NSLog(@"%s infoDic:%@",__func__,infoDic);
        
        NSString* username = infoDic[@"username"];
        NSNumber* uId = [NSNumber numberWithInteger:[infoDic[@"uid"] integerValue]];
        [users setObject:username forKey:uId];
        EMUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
        if(info && (info.avatarUrl.length > 0 || info.nickName.length > 0)) {
            EaseCallUser* user = [EaseCallUser userWithNickName:info.nickName image:[NSURL URLWithString:info.avatarUrl]];
            [[[EaseCallManager sharedManager] getEaseCallConfig] setUser:username info:user];
        }
    }
    [[EaseCallManager sharedManager] setUsers:users channelName:channelName];

}


- (NSDictionary *)getChannalUidArrayWithResult:(NSString *)result {

    NSArray *array = [result componentsSeparatedByString:@","];
    NSMutableDictionary *tDic = [NSMutableDictionary dictionary];
    for (NSString *tString in array) {
        if (tString.length > 0) {
            NSArray *subArray = [tString componentsSeparatedByString:@"="];

            NSString *key = subArray[0];
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *value = subArray[1];
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            tDic[key] = value;
        }
    }

    return tDic;
}
    
    
- (void)showHint:(NSString *)hint
{
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.margin = 10.f;
    CGPoint offset = hud.offset;
    offset.y = 180;
    hud.offset = offset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}


- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
               completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock {
    
    
    void (^finishBlock) (NSString *aName, EMError *aError) = ^(NSString *aName, EMError *aError) {
        
        if (!aError) {
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
            options.isAutoLogin = YES;
            options.loggedInUsername = userName;
            options.loggedInPassword = password;
            [options archive];

            //发送自动登录状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:[NSNumber numberWithBool:YES]];
            
            aCompletionBlock(200,@"登录成功");

            return ;
        }
        
        NSString *errorDes = NSLocalizedString(@"loginFailPrompt", nil);
        switch (aError.code) {
            case EMErrorUserNotFound:
                errorDes = NSLocalizedString(@"userNotFount", nil);
                break;
            case EMErrorNetworkUnavailable:
                errorDes = NSLocalizedString(@"offlinePrompt", nil);
                break;
            case EMErrorServerNotReachable:
                errorDes = NSLocalizedString(@"notReachServer", nil);
                break;
            case EMErrorUserAuthenticationFailed:
                errorDes = NSLocalizedString(@"userIdOrPwdError", nil);
                break;
            case EMErrorUserLoginTooManyDevices:
                errorDes = NSLocalizedString(@"devicesExceedLimit", nil);
                break;
            case EMErrorUserLoginOnAnotherDevice:
                errorDes = NSLocalizedString(@"loginOnOtherDevice", nil);
                break;
                case EMErrorUserRemoved:
                errorDes = NSLocalizedString(@"userRemovedByServer", nil);
            break;
            default:
                break;
        }
        
        aCompletionBlock(aError.code,errorDes);

    };
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [[EMClient sharedClient] loginWithUsername:[userName lowercaseString] password:password completion:finishBlock];
        
    }else {
        [[EaseHttpManager sharedManager] loginToApperServer:[userName lowercaseString] pwd:password completion:^(NSInteger statusCode, NSString * _Nonnull response) {
            NSLog(@"%s response:%@ state:%@",__func__,response,@(statusCode));
            
            if (response && response.length > 0 && statusCode) {
                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
                if (statusCode == 200) {
                    NSDictionary *entityDic = responsedict[@"entity"];
                    NSString *token = [entityDic objectForKey:@"token"];
                    [EaseKitUtil saveLoginUserToken:token userId:userName];
                    
                    [[EMClient sharedClient] loginWithUsername:[userName lowercaseString] password:password completion:finishBlock];
                    
                    return;
                }else {
                    
                    aCompletionBlock(statusCode,response);
                    
                }

            }
            
        }];
    }


}

- (void)logoutWithCompletion:(void (^)(BOOL success,NSString *errorMsg))completion {
    [[EaseHttpManager sharedManager] logoutWithCompletion:^(NSInteger statusCode, NSString * _Nonnull response) {
            
        NSLog(@"%s response:%@ state:%@",__func__,response,@(statusCode));
        
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            
            [[EMClient sharedClient] logout:YES completion:^(EMError * _Nullable aError) {
                if (aError == nil) {
                    [self clearCacheAfterLogoutSuccessed];
                    completion(YES,nil);
                }else {
                    
                    [[EMClient sharedClient] logout:NO completion:^(EMError * _Nullable aError) {
                        [self clearCacheAfterLogoutSuccessed];
                        completion(YES,nil);
                    }];
                }
                                    
            }];

            
        }
    }];
    
}


- (void)clearCacheAfterLogoutSuccessed {
    [EaseKitUtil removeLoginUserToken];
    [[EaseIMKitMessageHelper shareMessageHelper] clearMemeryCache];
    
    [EaseIMHelper shareHelper].pushedConvIdArray = nil;

    
    EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
    options.isAutoLogin = NO;
    options.loggedInUsername = @"";
    options.isFirstLaunch = NO;
    [options archive];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
    
}


- (NSMutableArray *)joinedGroupIdArray {
    if (_joinedGroupIdArray == nil) {
        _joinedGroupIdArray = [NSMutableArray array];
    }
    return _joinedGroupIdArray;
}

- (NSMutableArray *)exGroupIds {
    if (_exGroupIds == nil) {
        _exGroupIds = [NSMutableArray array];
    }
    return _exGroupIds;
}

- (void)enterSingleChatPageWithUserId:(NSString *)userId {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:userId];
}

//进入专属群列表，仅有一个直接进入群聊
- (void)enterJihuExGroup {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JiHuExGroupPushChatViewController object:self.exGroupIds];
}

- (NSMutableDictionary *)joinedGroupMemberDic {
    if (_joinedGroupMemberDic == nil) {
        _joinedGroupMemberDic = [NSMutableDictionary dictionary];
    }
    return _joinedGroupMemberDic;
}


@end


