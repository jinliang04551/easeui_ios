//
//  EMConversationsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMConversationsViewController.h"
#import "EMChatViewController.h"
#import "EMRealtimeSearch.h"
#import "PellTableViewSelect.h"
#import "EMSearchResultController.h"
#import "EMNotificationViewController.h"
#import "EMConversationUserDataModel.h"
#import "UserInfoStore.h"

#import "YGGroupSearchViewController.h"
#import "YGGroupCreateViewController.h"
#import "YGGroupApplyApprovalController.h"
#import "UIView+MISRedPoint.h"
#import "EaseIMKitOptions.h"
#import "EaseConversationsViewController.h"
#import "EaseHeaders.h"
#import "EaseConversationCell.h"
#import "EMRefreshViewController.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"
#import "UserInfoStore.h"
#import "EMSearchBar.h"
#import "EaseNoDataPlaceHolderView.h"
#import "EaseNavPopView.h"


@interface EMConversationsViewController() <EaseConversationsViewControllerDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) UIButton *backImageBtn;
@property (nonatomic, strong) UIButton *rightNavBarBtn;

@property (nonatomic, strong) EaseConversationsViewController *easeConvsVC;
@property (nonatomic, strong) EaseConversationViewModel *viewModel;
//@property (nonatomic, strong) UINavigationController *resultNavigationController;
//@property (nonatomic, strong) EMSearchResultController *resultController;
@property (nonatomic, assign) EMConversationEnterType enterType;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) EMSearchBar *searchBar;

@property (nonatomic, strong) EaseNavPopView *navPopView;


@end

@implementation EMConversationsViewController
- (instancetype)initWithEnterType:(EMConversationEnterType)enterType {
    self = [super init];
    if (self) {
        self.enterType = enterType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:CHAT_BACKOFF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:GROUP_LIST_FETCHFINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveJoinGroupApply) name:EaseNotificationRequestJoinGroupEvent object:nil];
        
    
    [EMClient.sharedClient.groupManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self _setupSubviews];
    if (![EaseIMKitOptions sharedOptions].isFirstLaunch) {
        [EaseIMKitOptions sharedOptions].isFirstLaunch = YES;
        [[EaseIMKitOptions sharedOptions] archive];
        [self refreshTableViewWithData];
    }
    [self fetchOwnUserInfo];
    
}

- (void)fetchOwnUserInfo {
    NSString *username = [EMClient sharedClient].currentUsername;
    if (username.length == 0) {
        return;
    }
    [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[username]];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.easeConvsVC refreshTabView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navPopView.hidden = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //运管端
    if (![EaseIMKitManager shared].isJiHuApp) {
        if ([EaseIMKitMessageHelper shareMessageHelper].hasJoinGroupApply) {
            self.rightNavBarBtn.MIS_redDot.hidden = NO;
        }else {
            self.rightNavBarBtn.MIS_redDot.hidden = YES;
        }
    }
   
}

- (void)dealloc
{
    [EMClient.sharedClient.groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setupSubviews {

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];
    
    
    self.viewModel = [[EaseConversationViewModel alloc] init];
    self.viewModel.canRefresh = YES;
    self.viewModel.badgeLabelPosition = EMAvatarTopRight;
    
//    //极狐专属群提示无消息
//    if ([EaseIMKitOptions sharedOptions].isJiHuApp && self.enterType == EMConversationEnterTypeExclusiveGroup) {
//        self.viewModel.noDataPrompt = @"您当前未加入任何专属服务群";
//    }

    
    self.easeConvsVC = [[EaseConversationsViewController alloc] initWithModel:self.viewModel];

    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.easeConvsVC.enterType = self.enterType;
    }
    
    self.easeConvsVC.delegate = self;
    [self addChildViewController:self.easeConvsVC];
    [self.view addSubview:self.easeConvsVC.view];
    [self.easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.navPopView];
    [self.navPopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.right.equalTo(self.view).offset(-16.0);
        make.width.equalTo(@(138));
        make.height.equalTo(@(180.0));
    }];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp && self.enterType == EMConversationEnterTypeMyChat) {
        [self _updateConversationViewTableHeader];
    }
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)_updateConversationViewTableHeader {
    self.easeConvsVC.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.easeConvsVC.tableView.tableHeaderView.backgroundColor = EaseIMKit_ViewBgBlackColor;
    
    [self.easeConvsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.easeConvsVC.tableView);
        make.width.equalTo(self.easeConvsVC.tableView);
        make.top.equalTo(self.easeConvsVC.tableView);
        make.height.mas_equalTo(52);
    }];
    
    
    [self.easeConvsVC.tableView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.easeConvsVC.tableView.tableHeaderView );
        make.height.equalTo(@(48.0));
    }];
        
}

#pragma mark Notification
- (void)receiveJoinGroupApply {
    self.rightNavBarBtn.MIS_redDot.hidden = NO;
}



- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.easeConvsVC refreshTable];
    });
}

- (void)refreshTableViewWithData
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager getConversationsFromServer:^(NSArray *aCoversations, EMError *aError) {
        if (!aError && [aCoversations count] > 0) {
            [self.easeConvsVC refreshTabView];
        }
    }];
    
    
}

#pragma mark - moreAction

- (void)moreAction
{
    [self.navPopView updateUI];
    self.navPopView.hidden = !self.navPopView.hidden;
}


- (void)messageAlertAction {
    EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
    options.isAlertMsg = !options.isAlertMsg;
    NSString *msg = [NSString stringWithFormat:@"%@消息提醒",options.isAlertMsg ? @"打开":@"关闭"];
    [self showHint:msg];
}


- (void)createGroupAction {
    YGGroupCreateViewController *vc = [[YGGroupCreateViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)searchGroupAction {
    YGGroupSearchViewController *vc = [[YGGroupSearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)groupApplyAction {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EaseNotificationClearRequestJoinGroupEvent object:nil];

    YGGroupApplyApprovalController *vc = [[YGGroupApplyApprovalController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}


#pragma mark - EaseConversationsViewControllerDelegate

- (id<EaseUserDelegate>)easeUserDelegateAtConversationId:(NSString *)conversationId conversationType:(EMConversationType)type
{
    EMConversationUserDataModel *userData = [[EMConversationUserDataModel alloc]initWithEaseId:conversationId conversationType:type];
    if(type == EMConversationTypeChat) {
        if (![conversationId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
            EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:conversationId];
            if(userInfo) {
                if([userInfo.nickName length] > 0) {
                    userData.showName = userInfo.nickName;
                }
                if([userInfo.avatarUrl length] > 0) {
                    userData.avatarURL = userInfo.avatarUrl;
                }
            }else{
                userData.showName = conversationId;
                
                [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[conversationId]];
            }
        }
    }
    return userData;
}

- (NSArray<UIContextualAction *> *)easeTableView:(UITableView *)tableView trailingSwipeActionsForRowAtIndexPath:(NSIndexPath *)indexPath actions:(NSArray<UIContextualAction *> *)actions
{
    NSMutableArray<UIContextualAction *> *array = [[NSMutableArray<UIContextualAction *> alloc]init];
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:NSLocalizedString(@"delete", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"deletePrompt", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *clearAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [tableView setEditing:NO];
            [self _deleteConversation:indexPath];
        }];
        [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
        [alertController addAction:clearAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [tableView setEditing:NO];
        }];
        [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        [alertController addAction:cancelAction];
        alertController.modalPresentationStyle = 0;
        [weakself presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    [array addObject:deleteAction];
//    [array addObject:actions[1]];
    
    return [array copy];
}

- (void)easeTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseConversationCell *cell = (EaseConversationCell*)[tableView cellForRowAtIndexPath:indexPath];
    //系统通知  
    if ([cell.model.easeId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
        EMNotificationViewController *controller = [[EMNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:cell.model];
}

#pragma mark - EMGroupManagerDelegate
- (void)didLeaveGroup:(EMGroup *)aGroup reason:(EMGroupLeaveReason)aReason {
    [self refreshTableView];
}

#pragma mark - Action

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    NSInteger row = indexPath.row;
    EaseConversationModel *model = [self.easeConvsVC.dataAry objectAtIndex:row];
    int unreadCount = [[EMClient sharedClient].chatManager getConversationWithConvId:model.easeId].unreadMessagesCount;
    [[EMClient sharedClient].chatManager deleteServerConversation:model.easeId conversationType:model.type isDeleteServerMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
        if (aError) {
            [weakSelf showHint:aError.errorDescription];
        }
        [[EMClient sharedClient].chatManager deleteConversation:model.easeId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
            [weakSelf.easeConvsVC.dataAry removeObjectAtIndex:row];
            [weakSelf.easeConvsVC refreshTabView];
            if (unreadCount > 0 && weakSelf.deleteConversationCompletion) {
                weakSelf.deleteConversationCompletion(YES);
            }
        }];
    }];
}

#pragma mark getter and setter
- (UIButton *)rightNavBarBtn {
    if (_rightNavBarBtn == nil) {
        _rightNavBarBtn = [[UIButton alloc]init];
        [_rightNavBarBtn setImage:[UIImage easeUIImageNamed:@"icon-add"] forState:UIControlStateNormal];
        [_rightNavBarBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        _rightNavBarBtn.MIS_redDot = [MISRedDot redDotWithConfig:({
            MISRedDotConfig *config = [[MISRedDotConfig alloc] init];
            config.offsetY = 2;
            config.offsetX = -2;
            config.size = CGSizeMake(8.0, 8.0);
            config.radius = 8.0 * 0.5;
            config;
        })];
        _rightNavBarBtn.MIS_redDot.hidden = YES;
    }
    
    return _rightNavBarBtn;
}


- (UIView *)titleView {
    if (_titleView == nil) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_NavBarAndStatusBarHeight)];
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            [_titleView addTransitionColorLeftToRight:UIColor.whiteColor endColor:EaseIMKit_Nav_JiHuBgColor];

        }else {
            [_titleView addTransitionColorLeftToRight:EaseIMKit_NavBgColor endColor:EaseIMKit_NavBgColor];
        }
        
        UILabel *titleLabel = [[UILabel alloc] init];

        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {

//            if (self.enterType == EMConversationEnterTypeExclusiveGroup) {
//                titleLabel.text = @"我的专属服务";
//            }
//
//            if (self.enterType == EMConversationEnterTypeMyChat) {
//                titleLabel.text = @"我的会话";
//            }
//
//
//            titleLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
//            titleLabel.font = [UIFont systemFontOfSize:16.0];
//            [_titleView addSubview:titleLabel];
//            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(_titleView);
//                make.centerY.equalTo(_titleView);
//                make.height.equalTo(@25);
//            }];

            titleLabel.text = @"会话列表";
            titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
            titleLabel.font = [UIFont systemFontOfSize:16.0];
            [_titleView addSubview:titleLabel];
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_titleView);
                make.top.equalTo(_titleView).offset(EaseIMKit_StatusBarHeight + 14.0);
//                make.height.equalTo(@25);
            }];

        }else {

            titleLabel.text = @"会话列表";
            titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
            titleLabel.font = [UIFont systemFontOfSize:16.0];
            [_titleView addSubview:titleLabel];
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_titleView);
                make.top.equalTo(_titleView).offset(EaseIMKit_StatusBarHeight + 14.0);
            }];

            [_titleView addSubview:self.rightNavBarBtn];
            [self.rightNavBarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@35);
                make.centerY.equalTo(titleLabel);
                make.right.equalTo(_titleView).offset(-16);
            }];

        }
        
    }
    return _titleView;
}

- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self.easeConvsVC;
    }
    return _searchBar;
}

- (EaseNavPopView *)navPopView {
    if (_navPopView == nil) {
        _navPopView = [[EaseNavPopView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _navPopView.hidden = YES;

        EaseIMKit_WS
        _navPopView.actionBlock = ^(NSInteger index) {
            if(index == 0) {
                [weakSelf messageAlertAction];
            } else if (index == 1) {
                [weakSelf searchGroupAction];
            }else if (index == 2) {
                [weakSelf createGroupAction];
            }else if (index == 3) {
                [weakSelf groupApplyAction];
            }
            
            weakSelf.navPopView.hidden = YES;
        };
    }
    return _navPopView;
}


@end
