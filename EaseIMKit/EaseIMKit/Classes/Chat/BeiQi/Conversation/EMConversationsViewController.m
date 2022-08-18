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
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];
    
    self.viewModel = [[EaseConversationViewModel alloc] init];
    self.viewModel.canRefresh = YES;
    self.viewModel.badgeLabelPosition = EMAvatarTopRight;
    
    
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
    

   
    
//    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
//    control.clipsToBounds = YES;
//    control.layer.cornerRadius = 18;
//    control.backgroundColor = [UIColor colorWithHexString:@"#252525"];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
//    [control addGestureRecognizer:tap];
//
//    [self.easeConvsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.easeConvsVC.tableView);
//        make.width.equalTo(self.easeConvsVC.tableView);
//        make.top.equalTo(self.easeConvsVC.tableView);
//        make.height.mas_equalTo(52);
//    }];
//
//    [self.easeConvsVC.tableView.tableHeaderView addSubview:control];
//    [control mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_offset(36);
//        make.top.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(8);
//        make.bottom.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(-8);
//        make.left.equalTo(self.easeConvsVC.tableView.tableHeaderView.mas_left).offset(17);
//        make.right.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(-16);
//    }];
//
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage easeUIImageNamed:@"jh_search_leftIcon"]];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.font = [UIFont systemFontOfSize:14.0];
//    label.text = @"搜索";
//    label.textColor = [UIColor colorWithHexString:@"#7E7E7F"];
//    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    UIView *subView = [[UIView alloc] init];
//    [subView addSubview:imageView];
//    [subView addSubview:label];
//    [control addSubview:subView];
//
//    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(20.0);
//        make.left.equalTo(subView);
//        make.top.equalTo(subView);
//        make.bottom.equalTo(subView);
//    }];
//
//    [label mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(imageView.mas_right).offset(3);
//        make.right.equalTo(subView);
//        make.top.equalTo(subView);
//        make.bottom.equalTo(subView);
//    }];
//
//    [subView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(control);
//    }];
    
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
            [weakself.easeConvsVC.dataAry removeAllObjects];
            [weakself.easeConvsVC.dataAry addObjectsFromArray:aCoversations];
            [weakself.easeConvsVC refreshTable];
        }
    }];
    
    
}

#pragma mark - moreAction

- (void)moreAction
{
    NSArray *titleArray = @[@"消息提醒",@"搜索群聊",@"创建群组",@"群组申请"];
    EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
    NSString *msgAlertName = options.isAlertMsg ? @"yg_msg_alert_on": @"yg_msg_alert_off";
    
    NSArray *imageNameArray = @[msgAlertName,@"yg_group_search",@"yg_group_create",@"yg_group_apply"];
    
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(self.view.bounds.size.width-220.0,EaseIMKit_NavBarAndStatusBarHeight, 138.0, 180) selectData:titleArray images:imageNameArray locationY:44.0 action:^(NSInteger index){
        if(index == 0) {
            [self messageAlertAction];
        } else if (index == 1) {
            [self searchGroupAction];
        }else if (index == 2) {
            [self createGroupAction];
        }else if (index == 3) {
            [self groupApplyAction];
        }
        
    } animated:YES];
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


//#pragma mark - EMSearchControllerDelegate
//
//- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
//{
//    self.resultController.searchKeyword = nil;
//}
//
//- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar
//{
//    [[EMRealtimeSearch shared] realtimeSearchStop];
//
//    if ([self.resultController.dataArray count] > 0) {
//        [self.resultController.dataArray removeAllObjects];
//    }
//    [self.resultController.tableView reloadData];
//    [self.easeConvsVC refreshTabView];
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [self.view endEditing:YES];
//}
//
//- (void)searchTextDidChangeWithString:(NSString *)aString
//{
//    self.resultController.searchKeyword = aString;
//
//    __weak typeof(self) weakself = self;
//    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.easeConvsVC.dataAry searchText:aString collationStringSelector:@selector(showName) resultBlock:^(NSArray *results) {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             if ([weakself.resultController.dataArray count] > 0) {
//                 [weakself.resultController.dataArray removeAllObjects];
//             }
//            [weakself.resultController.dataArray addObjectsFromArray:results];
//            [weakself.resultController.tableView reloadData];
//        });
//    }];
//}
   
//#pragma mark - EMSearchBarDelegate
//
//- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
//{
//    self.isSearching = YES;
//
//}
//
//- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
//{
//    [[EMRealtimeSearch shared] realtimeSearchStop];
//    
//    self.isSearching = NO;
//    
//    [self.searchResultArray removeAllObjects];
//    [self.easeConvsVC.tableView reloadData];
//    self.noDataPromptView.hidden = YES;
//}
//
//
//- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
//{
//    
//}
//
//- (void)searchTextDidChangeWithString:(NSString *)aString {
//    __weak typeof(self) weakself = self;
//    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.easeConvsVC.dataAry searchText:aString collationStringSelector:@selector(showName) resultBlock:^(NSArray *results) {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             if ([weakself.searchResultArray count] > 0) {
//                 [weakself.searchResultArray removeAllObjects];
//             }
//            [weakself.easeConvsVC.dataAry addObjectsFromArray:results];
//            [weakself.easeConvsVC.tableView reloadData];
//             self.noDataPromptView.hidden = weakself.searchResultArray.count >0 ? YES : NO;
//        });
//    }];
//    
//}

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
            config;
        })];
        _rightNavBarBtn.MIS_redDot.hidden = YES;
    }
    
    return _rightNavBarBtn;
}


- (UIView *)titleView {
    if (_titleView == nil) {
        _titleView = [[UIView alloc] init];
        
        UILabel *titleLabel = [[UILabel alloc] init];

        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            if (self.enterType == EMConversationEnterTypeExclusiveGroup) {
                titleLabel.text = @"我的专属服务";
            }
            
            if (self.enterType == EMConversationEnterTypeMyChat) {
                titleLabel.text = @"我的会话";
            }
            
            
            titleLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
            titleLabel.font = [UIFont systemFontOfSize:18];
            [_titleView addSubview:titleLabel];
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_titleView);
                make.centerY.equalTo(_titleView);
                make.height.equalTo(@25);
            }];

            self.backImageBtn = [[UIButton alloc]init];
            [self.backImageBtn setImage:[UIImage easeUIImageNamed:@"jh_backleft"] forState:UIControlStateNormal];
            [self.backImageBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            [_titleView addSubview:self.backImageBtn];
            [self.backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@35);
                make.centerY.equalTo(titleLabel);
                make.left.equalTo(_titleView).offset(16);
            }];
        }else {

            titleLabel.text = @"会话列表";
            titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
            titleLabel.font = [UIFont systemFontOfSize:18];
            [_titleView addSubview:titleLabel];
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_titleView);
                make.centerY.equalTo(_titleView);
                make.height.equalTo(@25);
            }];

            self.backImageBtn = [[UIButton alloc]init];
            [self.backImageBtn setImage:[UIImage easeUIImageNamed:@"yg_backleft"] forState:UIControlStateNormal];
            [self.backImageBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            [_titleView addSubview:self.backImageBtn];
            [self.backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@35);
                make.centerY.equalTo(titleLabel);
                make.left.equalTo(_titleView).offset(16);
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


@end
