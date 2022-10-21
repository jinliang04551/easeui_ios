//
//  YGGroupManageViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/12.
//

#import "YGGroupManageViewController.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"
#import "BQTitleAvatarCell.h"
#import "BQTitleValueAccessCell.h"
#import "EaseChangePasswordViewController.h"
#import "YGGroupMuteSettingViewController.h"
#import "YGGroupManagerSettingViewController.h"
#import "YGTransferOwnerViewController.h"

@interface YGGroupManageViewController ()
@property (nonatomic, strong) UIButton *transferOwnerButton;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) EMGroup *group;

@end

@implementation YGGroupManageViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup {
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registeCell];
    [self placeAndLayoutSubviews];
}


- (void)registeCell {
    
    [self.tableView registerClass:[BQTitleAvatarCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleAvatarCell class])];
    [self.tableView registerClass:[BQTitleValueAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
}

#pragma mark - Subviews
- (void)placeAndLayoutSubviews
{

    self.titleView = [self customNavWithTitle:@"群管理" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];
    
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];
    
    
    self.tableView.rowHeight = 64;
    self.tableView.tableFooterView = nil;

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

#pragma mark private method
- (void)transferOwnerButtonAction {
    [self goTransferOwnerPage];
}

//禁言
- (void)goManageMutePage {
    YGGroupMuteSettingViewController *controller = [[YGGroupMuteSettingViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:controller animated:YES];
}

//管理员
- (void)goManagerPage {
    YGGroupManagerSettingViewController *controller = [[YGGroupManagerSettingViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:controller animated:YES];
}

//转让群主
- (void)goTransferOwnerPage {
    YGTransferOwnerViewController *controller = [[YGTransferOwnerViewController alloc] initWithGroup:self.group];
    controller.navTitle = @"转让群主";
    controller.dataArray = [self.group.memberList mutableCopy];
    controller.transferOwnerBlock = ^(BOOL success) {
        if (success) {
            if (self.transferOwnerBlock) {
                self.transferOwnerBlock(success);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    BQTitleValueAccessCell *titleValueAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueAccessCell reuseIdentifier]];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            titleValueAccessCell.nameLabel.text = @"设置管理员";
            titleValueAccessCell.tapCellBlock = ^{
                [self goManagerPage];
            };
            return titleValueAccessCell;
        }
        
        if (indexPath.row == 1) {
            titleValueAccessCell.nameLabel.text = @"群内禁言";
            titleValueAccessCell.tapCellBlock = ^{
                [self goManageMutePage];
            };
            return titleValueAccessCell;
        }
    }
    
    return nil;
}
 

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80.0;
    }
    
    return 64.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 0.001;
    }
    return 12.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] init];
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//        hView.backgroundColor = [UIColor colorWithHexString:@"#171717"];
        hView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }else {
        hView.backgroundColor = EaseIMKit_ViewBgWhiteColor;

    }

    return hView;
}



#pragma mark getter and setter
- (UIButton *)transferOwnerButton {
    if (_transferOwnerButton == nil) {
        _transferOwnerButton = [[UIButton alloc] init];
        _transferOwnerButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_transferOwnerButton setTitle:@"转让群主" forState:UIControlStateNormal];
        [_transferOwnerButton setTitleColor:EaseIMKit_COLOR_HEX(0x4461F2) forState:UIControlStateNormal];
        [_transferOwnerButton addTarget:self action:@selector(transferOwnerButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _transferOwnerButton.backgroundColor = EaseIMKit_RGBACOLOR(68, 97, 242, 0.2);
        _transferOwnerButton.layer.cornerRadius = 4.0;
        _transferOwnerButton.layer.borderColor = EaseIMKit_COLOR_HEX(0x4461F2).CGColor;
        _transferOwnerButton.layer.borderWidth = EaseIMKit_ONE_PX;

    }
    return _transferOwnerButton;
}

- (UIView *)footerView {
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 72.0 + 44.0)];
                
    [_footerView addSubview:self.transferOwnerButton];
    [self.transferOwnerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_footerView).offset(72.0);
        make.left.equalTo(_footerView).offset(16.0);
        make.right.equalTo(_footerView).offset(-16.0);
        make.height.equalTo(@(44.0));
    }];

    }
    return _footerView;
}


@end

