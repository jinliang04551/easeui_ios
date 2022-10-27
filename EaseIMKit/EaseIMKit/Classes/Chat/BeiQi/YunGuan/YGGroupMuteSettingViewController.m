//
//  YGGroupBanSettingViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupMuteSettingViewController.h"
#import "YGGroupOperateMemberCell.h"
#import "YGGroupAddUserCell.h"
#import "YGGroupAddMuteViewController.h"
#import "EaseHeaders.h"
#import "EaseAlertController.h"


@interface YGGroupMuteSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSMutableArray *unMuteArray;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation YGGroupMuteSettingViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup {
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;

    [self placeAndLayoutSubviews];
    
    [self updateUI];
    
    [self _fetchGroupMutesWithIsHeader:YES isShowHUD:YES];
}


- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)placeAndLayoutSubviews {
    self.titleView = [self customNavWithTitle:@"群禁言设置" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.right.equalTo(self.view);
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


- (void)_fetchGroupMutesWithIsHeader:(BOOL)aIsHeader
                           isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchingMuteList...", nil)];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupMuteListFromServerWithId:self.group.groupId pageNumber:0 pageSize:50 completion:^(NSArray *aList, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (aError) {
            [self showHint:aError.errorDescription];
        } else {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            [weakself.dataArray addObjectsFromArray:aList];
            
//            if ([aList count] == 0) {
//                weakself.showRefreshFooter = NO;
//            } else {
//                weakself.showRefreshFooter = YES;
//            }
            
            [weakself.tableView reloadData];
        }
        
//        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
    }];
    
}



- (void)goAddMutePage {
    YGGroupAddMuteViewController *vc = [[YGGroupAddMuteViewController alloc] init];
    vc.navTitle = @"添加禁言人员";
    vc.dataArray = self.unMuteArray;
    EaseIMKit_WS
    vc.doneCompletion = ^(NSArray * _Nonnull selectedArray) {
        [weakSelf updateUIWithAddMutes:selectedArray];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateUIWithAddMutes:(NSArray *)mutes {
    [[EMClient sharedClient].groupManager muteMembers:mutes muteMilliseconds:-1 fromGroup:self.group.groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        if (aError == nil) {
            [self.dataArray addObjectsFromArray:mutes];
            [self.unMuteArray removeObjectsInArray:mutes];
            [self.tableView reloadData];
        }else {
            [self showHint:@"禁言失败"];
        }
    }];
}

- (void)updateUI {
    NSMutableArray *memberArray = [NSMutableArray array];
    if (self.group.adminList.count > 0) {
        [memberArray addObjectsFromArray:self.group.adminList];
    }
    if (self.group.memberList.count > 0) {
        [memberArray addObjectsFromArray:self.group.memberList];
    }

    NSMutableSet *memberSet = [NSMutableSet setWithArray:memberArray];
    
    NSMutableSet *muteSet = [NSMutableSet setWithArray:self.group.muteList];
    
    [memberSet minusSet:muteSet];
    
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [memberSet sortedArrayUsingDescriptors:sortDesc];

    self.unMuteArray = [sortSetArray mutableCopy];
    
    for (NSString *userId in self.unMuteArray) {
        if ([userId isEqualToString:[EMClient sharedClient].currentUsername]) {
            [self.unMuteArray removeObject:userId];
            break;
        }
    }
    
    self.dataArray = [self.group.muteList mutableCopy];
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YGGroupOperateMemberCell height];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGGroupAddUserCell *addBanCell = [tableView dequeueReusableCellWithIdentifier:[YGGroupAddUserCell reuseIdentifier]];
    
    YGGroupOperateMemberCell *banMemberCell = [tableView dequeueReusableCellWithIdentifier:[YGGroupOperateMemberCell reuseIdentifier]];
    
    EaseIMKit_WS
    if (indexPath.row == 0) {
        addBanCell.tapCellBlock = ^{
            [weakSelf goAddMutePage];
        };
        
        return addBanCell;
    }
   
    id obj = self.dataArray[indexPath.row - 1];
    [banMemberCell updateWithObj:obj];
    banMemberCell.removeMemberBlock = ^(NSString * _Nonnull userId) {
        [weakSelf updateUIWithUnBanUserId:userId];
    };
    return banMemberCell;
}
 
- (void)updateUIWithUnBanUserId:(NSString *)userId {
    if (userId == nil) {
        return;
    }
    
    [[EMClient sharedClient].groupManager unmuteMembers:@[userId] fromGroup:self.group.groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {

        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.dataArray containsObject:userId]) {
                    [self.dataArray removeObject:userId];
                }
                
                [self.unMuteArray addObject:userId];
                [self.tableView reloadData];
            });
        }else {
            [EaseAlertController showErrorAlert:aError.debugDescription];
        }
        
    }];
}

#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[YGGroupAddUserCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupAddUserCell class])];
        
        [_tableView registerClass:[YGGroupOperateMemberCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupOperateMemberCell class])];

        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            _tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        }else {
                _tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        }

    }
    return _tableView;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray *)unMuteArray {
    if (_unMuteArray == nil) {
        _unMuteArray = [[NSMutableArray alloc] init];
    }
    return _unMuteArray;
}

@end
