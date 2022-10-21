//
//  YGGroupManagerSettingViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/12.
//

#import "YGGroupManagerSettingViewController.h"
#import "YGGroupOperateMemberCell.h"
#import "YGGroupAddUserCell.h"
#import "YGGroupAddMuteViewController.h"
#import "EaseHeaders.h"
#import "EaseAlertController.h"


@interface YGGroupManagerSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSMutableArray *unMuteArray;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation YGGroupManagerSettingViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup {
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//        self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }else {
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }

    [self placeAndLayoutSubviews];
    
    [self updateUI];
    
}


- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)placeAndLayoutSubviews {
    self.titleView = [self customNavWithTitle:@"群管理员设置" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

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


- (void)goAddManagePage {
    
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.group.groupId fetchMembers:YES completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        if (aError == nil) {
            
            YGGroupAddMuteViewController *vc = [[YGGroupAddMuteViewController alloc] init];
            vc.navTitle = @"添加管理人员";
            vc.dataArray = [aGroup.memberList mutableCopy];
            EaseIMKit_WS
            vc.doneCompletion = ^(NSArray * _Nonnull selectedArray) {
                [weakSelf updateUIWithAddManagers:selectedArray];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];

}


- (void)updateUIWithAddManagers:(NSArray *)managers {
    for (int i = 0; i < managers.count; ++i) {
        NSString *manager = managers[i];
        [[EMClient sharedClient].groupManager addAdmin:manager toGroup:self.group.groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
            if (aError == nil) {
                self.dataArray = [aGroup.adminList mutableCopy];
                [self.tableView reloadData];
            }else {
                [self showHint:@"添加管理员失败"];
            }
        }];
    }
}

- (void)updateUI {
    self.dataArray = [self.group.adminList mutableCopy];
    
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
    
    YGGroupAddUserCell *addManagerCell = [tableView dequeueReusableCellWithIdentifier:[YGGroupAddUserCell reuseIdentifier]];
    
    YGGroupOperateMemberCell *banMemberCell = [tableView dequeueReusableCellWithIdentifier:[YGGroupOperateMemberCell reuseIdentifier]];
    
    EaseIMKit_WS
    if (indexPath.row == 0) {
        addManagerCell.iconImageView.image = [UIImage easeUIImageNamed:@"yg_add_manage"];
        addManagerCell.nameLabel.text = @"添加管理人员";

        addManagerCell.tapCellBlock = ^{
            [weakSelf goAddManagePage];
        };
        
        return addManagerCell;
    }
   
    id obj = self.dataArray[indexPath.row - 1];
    [banMemberCell updateWithObj:obj];
    [banMemberCell.operateButton setTitle:@"移除管理员" forState:UIControlStateNormal];
    banMemberCell.removeMemberBlock = ^(NSString * _Nonnull userId) {
        [weakSelf updateUIWithRemoveAdminUserId:userId];
    };
    return banMemberCell;
}
 
- (void)updateUIWithRemoveAdminUserId:(NSString *)userId {
    if (userId == nil) {
        return;
    }
    
//    [[EMClient sharedClient].groupManager unmuteMembers:@[userId] fromGroup:self.group.groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
//
//        if (aError == nil) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if ([self.dataArray containsObject:userId]) {
//                    [self.dataArray removeObject:userId];
//                }
//
//                [self.unMuteArray addObject:userId];
//                [self.tableView reloadData];
//            });
//        }else {
//            [EaseAlertController showErrorAlert:aError.debugDescription];
//        }
//
//    }];
    
    [[EMClient sharedClient].groupManager removeAdmin:userId fromGroup:self.group.groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.dataArray containsObject:userId]) {
                    [self.dataArray removeObject:userId];
                }

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
//              _tableView.backgroundColor = EaseIMKit_ViewBgBlackColor;
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
