//
//  YGGroupCreateViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/18.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupCreateViewController.h"
#import "EaseTextFieldViewController.h"
#import "EaseTextViewController.h"

#import "BQTitleAvatarCell.h"
#import "BQTitleValueAccessCell.h"
#import "BQTitleValueCell.h"
#import "BQTitleSwitchCell.h"
#import "BQGroupEditMemberViewController.h"
#import "BQChatRecordContainerViewController.h"
#import "YGCreateGroupOperationMemberCell.h"
#import "BQTitleValueTapCell.h"
#import "EaseHeaders.h"


@interface YGGroupCreateViewController ()<EMMultiDevicesDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) YGCreateGroupOperationMemberCell *operationMemberCell;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupInterduce;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) NSMutableArray *serverArray;
@property (nonatomic, strong) UIView *titleView;



@end

@implementation YGGroupCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.groupName = @"";
    self.groupInterduce = @"";
    
    [self registeCell];
    [self placeAndLayoutSubviews];
    
}


- (void)registeCell {
    
    [self.tableView registerClass:[BQTitleAvatarCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleAvatarCell class])];
    [self.tableView registerClass:[BQTitleValueAccessCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueAccessCell class])];
    [self.tableView registerClass:[BQTitleSwitchCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleSwitchCell class])];
    [self.tableView registerClass:[BQTitleValueCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueCell class])];
    [self.tableView registerClass:[BQTitleValueTapCell class] forCellReuseIdentifier:NSStringFromClass([BQTitleValueTapCell class])];
    
}

#pragma mark - Subviews
- (void)placeAndLayoutSubviews
{
//    [self addPopBackLeftItem];
//    self.title = @"创建群组";
    
    self.titleView = [self customNavWithTitle:@"创建群组" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EMVIEWBOTTOMMARGIN);
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


- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BQTitleAvatarCell *titleAvatarCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleAvatarCell reuseIdentifier]];
    
    BQTitleValueAccessCell *titleValueAccessCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueAccessCell reuseIdentifier]];

    BQTitleValueCell *titleValueCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueCell reuseIdentifier]];

    BQTitleValueTapCell *titleValueTapCell = [tableView dequeueReusableCellWithIdentifier:[BQTitleValueTapCell reuseIdentifier]];

    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            titleAvatarCell.nameLabel.text = @"群头像";
            [titleAvatarCell.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_group_icon"]];
            return titleAvatarCell;
        }else {
            [self.operationMemberCell updateWithObj:self.memberArray];
            return self.operationMemberCell;
        }
        
    }else {
        if (indexPath.row == 0) {
            titleValueTapCell.nameLabel.text = @"群名称";
            titleValueTapCell.detailLabel.text = self.groupName;
            titleValueTapCell.tapCellBlock = ^{
                [self editGroupNameAction];
            };
            return titleValueTapCell;
        }else {
            titleValueAccessCell.nameLabel.text = @"群介绍";
            titleValueAccessCell.detailLabel.text = @"";
            titleValueAccessCell.tapCellBlock = ^{
                [self editGroupInterduce];
            };
            return titleValueAccessCell;
        }
    }
    
    return nil;
}
 


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1){
        return [YGCreateGroupOperationMemberCell cellHeightWithObj:self.memberArray];
    }
    
    return 64.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 0.001;
    }
    return 24.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] init];
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        hView.backgroundColor = [UIColor colorWithHexString:@"#171717"];
    }else {
        hView.backgroundColor = EaseIMKit_ViewBgWhiteColor;

    }

    return hView;
}


- (void)editGroupNameAction {
    EaseTextFieldViewController *controller = [[EaseTextFieldViewController alloc] initWithString:self.groupName  placeholder:NSLocalizedString(@"inputGroupSubject", nil) isEditable:YES];
    controller.title = NSLocalizedString(@"editGroupSubject", nil);
    [self.navigationController pushViewController:controller animated:YES];
    
    EaseIMKit_WS
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        if ([aString length] == 0) {
            [EaseAlertController showErrorAlert:NSLocalizedString(@"emtpyGroupSubject", nil)];
            return NO;
        }
        
        weakSelf.groupName = aString;
        [weakSelf.tableView reloadData];
        
        return YES;
    }];
}

- (void)editGroupInterduce
{
    __weak typeof(self) weakself = self;
    EaseTextViewController *controller = [[EaseTextViewController alloc] initWithString:self.groupInterduce placeholder:NSLocalizedString(@"inputGroupDescription", nil) isEditable:YES];
    controller.title = @"群介绍";
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        weakself.groupInterduce = aString;
        return YES;
    }];
    [self.navigationController pushViewController:controller animated:YES];
}




- (void)confirmButtonAction
{
    NSLog(@"%s",__func__);
        //包括群主
    if (self.memberArray.count < 1) {
        [self showHint:@"群组人数不得少于2人"];
        return;
    }
    
        
    if (self.userArray.count <= 0) {
        [self showHint:@"选择成员必须包含客户"];
        return;
    }
    
    if (self.groupName.length == 0) {
        [self showHint:@"请填写群名称"];
        return;
    }

    if (self.groupInterduce.length == 0) {
        [self showHint:@"请填写群介绍"];
        return;
    }

    [[EaseHttpManager sharedManager] createGroupWithGroupName:self.groupName groupInterduce:self.groupInterduce customerUserIds:self.userArray waiterUserIds:self.serverArray completion:^(NSInteger statusCode, NSString * _Nonnull response) {
          
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSDictionary *dataDic = responsedict[@"data"];
                NSString *groupId = dataDic[@"groupId"];

                if (groupId.length > 0) {
                    [self showHint:@"创建成功"];
                    [self.navigationController
                     popViewControllerAnimated:YES];
                }
                
            }else {
                [EaseAlertController showErrorAlert:errorDescription];
            }
        }
        
    }];
}


#pragma mark getter and setter
- (YGCreateGroupOperationMemberCell *)operationMemberCell {
    if (_operationMemberCell == nil) {
        _operationMemberCell =  [[YGCreateGroupOperationMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[YGCreateGroupOperationMemberCell reuseIdentifier]];
        
        EaseIMKit_WS
        _operationMemberCell.addMemberBlock = ^{
            [weakSelf addGroupMemberPage];
        };
    
    }
    return _operationMemberCell;

}

- (void)addGroupMemberPage {
    
    BQGroupEditMemberViewController *controller = [[BQGroupEditMemberViewController alloc] initWithUserArray:self.userArray serverArray:self.serverArray];
    EaseIMKit_WS
    controller.addedMemberBlock = ^(NSMutableArray * _Nonnull userArray, NSMutableArray * _Nonnull serverArray) {
        [weakSelf updateUIWithUserArray:userArray serverArray:serverArray];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)updateUIWithUserArray:(NSMutableArray *)userArray
                  serverArray:(NSMutableArray *)serverArray {
    
    NSMutableSet *oUserSet = [NSMutableSet setWithArray:self.userArray];
    [oUserSet addObjectsFromArray:userArray];
    self.userArray = [[oUserSet allObjects] mutableCopy];
    
    NSMutableSet *oSerSet = [NSMutableSet setWithArray:self.serverArray];
    [oSerSet addObjectsFromArray:serverArray];
    self.serverArray = [[oSerSet allObjects] mutableCopy];
    
    NSMutableArray *memberArray = [NSMutableArray array];
    [memberArray addObjectsFromArray:self.userArray];
    [memberArray addObjectsFromArray:self.serverArray];
    self.memberArray = memberArray;
    
//    [self updateConfirmState];
    [self.tableView reloadData];
}

- (void)updateConfirmState {
    if (self.memberArray.count <= 1) {
        //成员+群主的数量 >= 2
        NSString *alertTitle = @"群成员不得少于2人";
        [self.confirmButton setTitle:alertTitle forState:UIControlStateNormal];
        self.confirmButton.backgroundColor = [UIColor colorWithHexString:@"#C2C2C2"];
        self.confirmButton.enabled = NO;
    }else {
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
        self.confirmButton.enabled = YES;
    }
}

- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = EaseIMKit_NFont(14.0);
        
        [_confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
        _confirmButton.layer.cornerRadius = 2.0;
    }
    return _confirmButton;

}


- (UIView *)footerView {
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 72.0 + 44.0)];
                
    [_footerView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_footerView).offset(72.0);
        make.left.equalTo(_footerView).offset(16.0);
        make.right.equalTo(_footerView).offset(-16.0);
        make.height.equalTo(@(44.0));
    }];

    }
    return _footerView;
}

- (NSMutableArray *)memberArray {
    if (_memberArray == nil) {
        _memberArray = [[NSMutableArray alloc] init];
    }
    return _memberArray;
}


- (NSMutableArray *)userArray {
    if (_userArray == nil) {
        _userArray = [[NSMutableArray alloc] init];
    }
    return _userArray;
}

- (NSMutableArray *)serverArray {
    if (_serverArray == nil) {
        _serverArray = [[NSMutableArray alloc] init];
    }
    return _serverArray;
}


@end
