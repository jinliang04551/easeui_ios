//
//  EaseMeViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/11.
//

#import "EaseMeViewController.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"
#import "BQTitleAvatarCell.h"
#import "BQTitleValueAccessCell.h"

@interface EaseMeViewController ()
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation EaseMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//
//    [self.view addSubview:self.logoutButton];
//    [self.logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.view);
//        make.left.equalTo(self.view).offset(30.0);
//        make.right.equalTo(self.view).offset(-30.0);
//        make.height.equalTo(@(44.0));
//    }];
    
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
    self.titleView = [self customNavWithTitle:@"我的" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];
    
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [self footerView];

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
- (void)logoutButtonAction {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [[EMClient sharedClient] logout:YES completion:^(EMError * _Nullable aError) {
            if (aError == nil) {
                EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:nil message:@"退出登录成功"];
                [alertView show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];

            }else {
                EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:nil message:aError.errorDescription];
                [alertView show];
                
                NSLog(@"err:%@",aError.errorDescription);
            }
            
        }];
        
    }else {
        [EaseIMKitManager.shared logoutWithCompletion:^(BOOL success, NSString * _Nonnull errorMsg) {
            if (success) {
                EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:nil message:@"退出登录成功"];
                [alertView show];
            }else {
                EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:nil message:errorMsg];
                [alertView show];
                
                NSLog(@"err:%@",errorMsg);
            }
            
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BQTitleAvatarCell *titleAvatarCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleAvatarCell reuseIdentifier]];
    
    BQTitleValueAccessCell *titleValueAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueAccessCell reuseIdentifier]];


    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            titleAvatarCell.nameLabel.text = @"群头像";
            [titleAvatarCell.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_group_icon"]];
            return titleAvatarCell;
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            titleValueAccessCell.nameLabel.text = @"账号与安全";
            titleValueAccessCell.tapCellBlock = ^{
                
            };
            return titleAvatarCell;
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


#pragma mark getter and setter
- (UIButton *)logoutButton {
    if (_logoutButton == nil) {
        _logoutButton = [[UIButton alloc] init];
        _logoutButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
        [_logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_logoutButton addTarget:self action:@selector(logoutButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _logoutButton.backgroundColor = UIColor.blueColor;
    }
    return _logoutButton;
}

- (UIView *)footerView {
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 72.0 + 44.0)];
                
    [_footerView addSubview:self.logoutButton];
    [self.logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_footerView).offset(72.0);
        make.left.equalTo(_footerView).offset(16.0);
        make.right.equalTo(_footerView).offset(-16.0);
        make.height.equalTo(@(44.0));
    }];

    }
    return _footerView;
}


@end

