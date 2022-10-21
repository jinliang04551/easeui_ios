//
//  EaseConversationsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseConversationsViewController.h"
#import "EaseHeaders.h"
#import "EaseConversationViewModel.h"
#import "EaseConversationCell.h"
#import "EaseConversationModel.h"
#import "EMConversation+EaseUI.h"
#import "UIImage+EaseUI.h"
#import "EaseIMKitManager.h"
#import "UIViewController+HUD.h"
#import "EaseIMKitMessageHelper.h"
#import "EMSearchBar.h"
#import "EMRealtimeSearch.h"
#import "EaseNoDataPlaceHolderView.h"
#import "EaseNetworkErrorView.h"
#import "Reachability.h"


@interface EaseConversationsViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
EMContactManagerDelegate,
EMChatManagerDelegate,
EMGroupManagerDelegate,
EMClientDelegate,
EMSearchBarDelegate
>
{
    dispatch_queue_t _loadDataQueue;
}
@property (nonatomic, strong) UIView *blankPerchView;

@property (nonatomic, strong) NSString *mutiCallMsgId;

@property (nonatomic) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) EaseNoDataPlaceHolderView *noDataPromptView;
@property (nonatomic, strong) EaseNetworkErrorView *networkErrorView;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) Reachability *reach;

@end

@implementation EaseConversationsViewController

@synthesize viewModel = _viewModel;

- (instancetype)initWithModel:(EaseConversationViewModel *)aModel{
    if (self = [super initWithModel:aModel]) {
        _viewModel = aModel;
        _loadDataQueue = dispatch_queue_create("com.easemob.easeui.conversations.queue", 0);
        [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
        
        [self addNetworkObserver];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];

    [self addNotifacationObserver];
    
    [self.view addSubview:self.noDataPromptView];
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(60.0);
        make.centerX.left.right.equalTo(self.view);
    }];

}

- (void)addNetworkObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
        
    self.reach = [Reachability reachabilityForInternetConnection];
    [self updateUIWithNetworkStatus:self.reach.currentReachabilityStatus];

    [self.reach startNotifier];
    
}



- (void)addNotifacationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTabView)
                                                 name:CONVERSATIONLIST_UPDATE object:nil];
    //本地插入提示消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCMDInsertLocalTextMsg:) name:EaseNotificationReceiveCMDInsertLocalTextMsg object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMutiDeviceNoDisturb:) name:EaseNotificationReceiveMutiDeviceNoDisturb object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveGroupInfoUpdate:) name:EaseNotificationReceiveGroupInfoUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCMDCreateGroupChat) name:EaseNotificationReceiveCMDCreateGroupChat object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf endRefresh];
    });
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveCMDInsertLocalTextMsg:(NSNotification *)notify {
    EMChatMessage *msg = notify.object;
    self.mutiCallMsgId = msg.messageId;
    [self refreshTabView];
}

- (void)receiveMutiDeviceNoDisturb:(NSNotification *)notify {
    
    [self refreshTabView];
}

- (void)receiveGroupInfoUpdate:(NSNotification *)notify {
    [self refreshTabView];
}

- (void)receiveCMDCreateGroupChat {
    [self refreshTabView];
}


- (void)reachabilityChangedNotification:(NSNotification *)notify {
    Reachability *reach = (Reachability *)notify.object;
    NetworkStatus status =  reach.currentReachabilityStatus;
    NSLog(@"%s status:%@",__func__,@(status));
    
    [self updateUIWithNetworkStatus:status];
}

- (void)updateUIWithNetworkStatus:(NetworkStatus)status {
    if (status == NotReachable) {
        self.tableView.tableHeaderView = self.headerView;
    }else {
        self.tableView.tableHeaderView = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - EMClientDelegate

- (void)autoLoginDidCompleteWithError:(EMError *)aError
{
    if (!aError) {
        [self _loadAllConversationsFromDB];
    }
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesUndisturbEventNotifyFormOtherDeviceData:(NSString *)undisturbData {
#if DEBUG
    NSLog(@"multiDevicesUndisturbEventNotifyFormOtherDeviceData::: %@",[self dictionaryWithJsonString:undisturbData]);
#endif
    [[EMClient sharedClient].pushManager getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions * _Nonnull aOptions, EMError * _Nonnull aError) {
        if (!aError) {
            [[EaseIMKitManager shared] cleanMemoryUndisturbMaps];
            [self.tableView reloadData];
        }
    }];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
{
    self.isSearching = YES;

}

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    self.isSearching = NO;
    
    [self.searchResultArray removeAllObjects];
    [self.tableView reloadData];
    self.noDataPromptView.hidden = YES;
}


- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}

- (void)searchTextDidChangeWithString:(NSString *)aString {
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataAry searchText:aString collationStringSelector:@selector(showName) resultBlock:^(NSArray *results) {
         dispatch_async(dispatch_get_main_queue(), ^{
            weakself.searchResultArray = [results mutableCopy];
            [weakself.tableView reloadData];
             self.noDataPromptView.hidden = weakself.searchResultArray.count >0 ? YES : NO;
        });
    }];
    
}



#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [EaseConversationCell heightWithModel:self.dataAry[indexPath.row]];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching) {
        return self.searchResultArray.count;
    }
    return [self.dataAry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:cellForRowAtIndexPath:)]) {
//        UITableViewCell *cell = [self.delegate easeTableView:tableView cellForRowAtIndexPath:indexPath];
//        if (cell) {
//            return cell;
//        }
//    }
    
    EaseConversationCell *cell = [EaseConversationCell tableView:tableView cellViewModel:_viewModel];
    
    EaseConversationModel *model =  nil;
    
    if (self.isSearching) {
        model = self.searchResultArray[indexPath.row];
    }else {
        model = self.dataAry[indexPath.row];
    }
    
    
    cell.model = model;
    
    return cell;
}

#pragma mark - Table view delegate

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    
    EaseConversationModel *model = [self.dataAry objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakself = self;
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:EaseLocalizableString(@"delete", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _deleteConversation:indexPath];
        [weakself refreshTabView];
    }];
    
//    UIContextualAction *topAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
//                                                                            title:!model.isTop ? EaseLocalizableString(@"top", nil) : EaseLocalizableString(@"cancelTop", nil)
//                                                                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
//                                     {
//        EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:model.easeId
//                                                                                     type:model.type
//                                                                         createIfNotExist:YES];
//        [conversation setTop:!model.isTop];
//        [weakself refreshTabView];
//    }];
//
//    topAction.backgroundColor = [UIColor colorWithHexString:@"CB7D32"];
    
    NSArray *swipeActions = @[deleteAction];
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:trailingSwipeActionsForRowAtIndexPath:actions:)]) {
        swipeActions = [self.delegate easeTableView:tableView trailingSwipeActionsForRowAtIndexPath:indexPath actions:swipeActions];
    }
    
    if (swipeActions == nil) {
        return nil;
    }
    
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self makeSwipeButton:tableView];
}

- (void)makeSwipeButton:(UITableView *)tableView
{
    if (@available(iOS 13.0, *))
    {
        for (UIView *subview in tableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")] )
            {
                NSArray *subviewArray=subview.subviews;
                for (UIView *sub_subview in subviewArray)
                {
                    if ([sub_subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] )
                    {
                        NSArray *subviews=sub_subview.subviews;
                        
                        UIView *topView = sub_subview.subviews[1];
                        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)];
                        
                        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage easeUIImageNamed:@"alert_error"]];
                        [view addSubview:imageView];
                        [imageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
                            make.centerX.equalTo(view.ease_centerX);
                            make.bottom.equalTo(view.ease_centerY);
                            make.height.width.equalTo(@30);
                        }];
                        
                        UILabel *titleLable = [[UILabel alloc]init];
                        titleLable.text = @"stick";
                        titleLable.textAlignment = NSTextAlignmentCenter;
                        [view addSubview:titleLable];
                        [titleLable Ease_makeConstraints:^(EaseConstraintMaker *make) {
                            make.left.right.equalTo(view);
                            make.top.equalTo(view.ease_centerY);
                            make.height.equalTo(@30);
                        }];
                        view.backgroundColor = [UIColor colorWithHexString:@"CB7D32"];
                        view.userInteractionEnabled = NO;
                        
                        [sub_subview insertSubview:view aboveSubview:topView];
                        
                    }
                }
            }
        }
    } else if (@available(iOS 11.0, *))
    {
        for (UIView *subview in tableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] )
            {
                UIButton*addButton = subview.subviews[0];
                [addButton setImage:[UIImage easeUIImageNamed:@"alert_error"] forState:UIControlStateNormal];
            }
        }
    }else{
        //     ios 8-10
        // UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        //       UITableViewCell*  cell = [self.FULTable cellForRowAtIndexPath:_indexPath];
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    EaseConversationModel *model = [self.dataAry objectAtIndex:indexPath.row];
    __weak typeof(self) weakself = self;
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:EaseLocalizableString(@"delete", nil)
                                                                          handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)
    {
        [weakself _deleteConversation:indexPath];
        [weakself refreshTabView];
    }];
    
//    UITableViewRowAction *topAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
//                                                                            title:!model.isTop ? EaseLocalizableString(@"top", nil) : EaseLocalizableString(@"cancelTop", nil)
//                                                                          handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)
//    {
//        EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:model.easeId
//                                                                                     type:model.type
//                                                                         createIfNotExist:YES];
//        [conversation setTop:!model.isTop];
//        [weakself refreshTabView];
//    }];
//
//    topAction.backgroundColor = [UIColor colorWithHexString:@"CB7D32"];
    
    NSArray *swipeActions = @[deleteAction];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:editActionsForRowAtIndexPath:actions:)]) {
        swipeActions = [self.delegate easeTableView:tableView editActionsForRowAtIndexPath:indexPath actions:swipeActions];
    }
    
    return swipeActions;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        return NO;
    }
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EaseConversationModel *model = [self.dataAry objectAtIndex:indexPath.row];
    if (!model.isTop) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:didSelectRowAtIndexPath:)]) {
        return [self.delegate easeTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - EMChatManagerDelegate

- (void)messagesInfoDidRecall:(NSArray<EMRecallMessageInfo *> *)aRecallMessagesInfo
{
    [self _loadAllConversationsFromDB];
}

- (void)messagesDidReceive:(NSArray *)aMessages
{
    if (aMessages && [aMessages count] > 0) {
        EMChatMessage *msg = aMessages[0];
        if(msg.body.type == EMMessageBodyTypeText) {
                        
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:msg.conversationId type:EMConversationTypeGroupChat createIfNotExist:NO];
                        
        }
    }
    
    [self _loadAllConversationsFromDB];
}

- (void)onConversationRead:(NSString *)from to:(NSString *)to
{
    [self _loadAllConversationsFromDB];
}

//　收到已读回执
- (void)messagesDidRead:(NSArray *)aMessages
{
    [self refreshTable];
}

#pragma mark - UIMenuController

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    NSInteger row = indexPath.row;
    EaseConversationModel *model = [self.dataAry objectAtIndex:row];
    [[EMClient sharedClient].chatManager deleteServerConversation:model.easeId conversationType:model.type isDeleteServerMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
        if (aError) {
            [weakSelf showHint:aError.errorDescription];
        }
    }];
    [[EMClient sharedClient].chatManager deleteConversation:model.easeId
                                           isDeleteMessages:YES
                                                 completion:^(NSString *aConversationId, EMError *aError) {
        if (!aError) {
            [weakSelf.dataAry removeObjectAtIndex:row];
            [weakSelf.tableView reloadData];
            [weakSelf _updateBackView];
        }
    }];
}



- (void)_loadAllConversationsFromDB {
        
    __weak typeof(self) weakSelf = self;
    dispatch_async(_loadDataQueue, ^{
        NSMutableArray<id<EaseUserDelegate>> *totals = [NSMutableArray<id<EaseUserDelegate>> array];
        
        NSArray *conversations = [EMClient.sharedClient.chatManager getAllConversations];
        
        NSMutableArray *convs = [NSMutableArray array];
        NSMutableArray *topConvs = [NSMutableArray array];
        
        for (EMConversation *conv in conversations) {
                        
//            if (self.enterType == EMConversationEnterTypeExclusiveGroup) {
//                BOOL isExgroup = conv.ext[@"JiHuExGroupChat"];
//                NSLog(@"conv:%@ isExgroup:%@",conv.conversationId,@(isExgroup));
//
//                //非极狐专属群过滤
//                if (!isExgroup) {
//                    continue;
//                }else {
//                }
//            }
//
//            if (self.enterType == EMConversationEnterTypeMyChat) {
//                BOOL isExgroup = conv.ext[@"JiHuExGroupChat"];
//                //过滤极狐专属群
//                if (isExgroup) {
//                    continue;
//                }
//            }
            
            
#warning  temp note for generate local null conv
//            if (!conv.latestMessage) {
//                /*[EMClient.sharedClient.chatManager deleteConversation:conv.conversationId
//                                                     isDeleteMessages:NO
//                                                           completion:nil];*/
//                continue;
//            }
            if (conv.type == EMConversationTypeChatRoom) {
                continue;
            }
            EaseConversationModel *item = [[EaseConversationModel alloc] initWithConversation:conv];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(easeUserDelegateAtConversationId:conversationType:)]) {
                item.userDelegate = [weakSelf.delegate easeUserDelegateAtConversationId:conv.conversationId conversationType:conv.type];
            }
            
            if (item.isTop) {
                [topConvs addObject:item];
            }else {
                [convs addObject:item];
            }
        }
        
        NSArray *normalConvList = [convs sortedArrayUsingComparator:
                                   ^NSComparisonResult(EaseConversationModel *obj1, EaseConversationModel *obj2)
                                   {
            if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        NSArray *topConvList = [topConvs sortedArrayUsingComparator:
                                ^NSComparisonResult(EaseConversationModel *obj1, EaseConversationModel *obj2)
                                {
            if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        [totals addObjectsFromArray:topConvList];
        [totals addObjectsFromArray:normalConvList];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([self.tableView.refreshControl isRefreshing]) {
                [self.tableView.refreshControl endRefreshing];
            }
        });
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationReceiveMutiCallLoadConvsationDB object:self.mutiCallMsgId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
             weakSelf.dataAry = (NSMutableArray *)totals;
             [weakSelf.tableView reloadData];
             [weakSelf _updateBackView];
        });
    });
}

- (void)refreshTabView
{
    [self _loadAllConversationsFromDB];
}

- (void)_updateBackView {
    if (self.dataAry.count == 0) {
        [self.tableView.backgroundView setHidden:NO];
    }else {
        [self.tableView.backgroundView setHidden:YES];
    }
}


#pragma mark getter and setter
- (NSMutableArray *)searchResultArray {
    if (_searchResultArray == nil) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (EaseNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = EaseNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:[UIImage easeUIImageNamed:@"jihu_search_nodata"]];
        _noDataPromptView.prompt.text = @"搜索无结果";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

- (EaseNetworkErrorView *)networkErrorView {
    if (_networkErrorView == nil) {
        _networkErrorView = [[EaseNetworkErrorView alloc] init];
        
    }
    return _networkErrorView;
}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 40.0)];
        [_headerView addSubview:self.networkErrorView];
        [self.networkErrorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView);
        }];
    }
    return _headerView;
}

@end
