//
//  BQAddGroupMemberViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/8.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQGroupEditMemberViewController.h"
#import "BQGroupSearchAddView.h"
#import "BQGroupSearchCell.h"
#import "EaseHeaders.h"
#import "BQEaseUserModel.h"


@interface BQGroupEditMemberViewController ()<UITableViewDelegate,UITableViewDataSource,BQGroupSearchAddViewDelegate>

@property (nonatomic, strong) BQGroupSearchAddView *groupSearchAddView;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) UITableView *searchResultTableView;
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) NSMutableArray *serverArray;

@property (nonatomic, strong) BQGroupSearchCell *groupSearchCell;

@end

@implementation BQGroupEditMemberViewController
- (instancetype)initWithMemberArray:(NSMutableArray *)memberArray {
    self = [super init];
    if (self) {
        self.memberArray = memberArray;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    }else {
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }

    self.title = @"选择用户";
    [self addPopBackLeftItemWithTarget:self action:@selector(backItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completionAction)];

    [self setRightNavBarItemTitleColor];

    
    [self placeAndLayoutSubviews];
    [self.groupSearchAddView updateUIWithMemberArray:self.memberArray];
}

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)completionAction {
    if (self.addedMemberBlock) {
        self.addedMemberBlock(self.userArray,self.serverArray);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)placeAndLayoutSubviews {
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.groupSearchAddView];
    [self.view addSubview:self.searchResultTableView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(48.0));
    }];
    
    [self.groupSearchAddView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(0));
    }];
    
    [self.searchResultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchAddView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}


- (void)dealloc
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark BQGroupSearchAddViewDelegate
- (void)heightForGroupSearchAddView:(CGFloat)height {
    [self.groupSearchAddView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
{
    if (!self.isSearching) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.isSearching = YES;
    }
}

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isSearching = NO;
    
    [self.searchResultArray removeAllObjects];
    [_searchResultTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}

- (void)searchTextDidChangeWithString:(NSString *)aString {
    
    [[EaseHttpManager sharedManager] searchGroupMemberWithUsername:aString completion:^(NSInteger statusCode, NSString * _Nonnull response) {
       
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSArray *tArray = responsedict[@"entities"];

                NSMutableArray *dArray = [NSMutableArray array];
                for (int i = 0 ; i < tArray.count; ++i) {
                    BQEaseUserModel *model = [[BQEaseUserModel alloc] initWithDic:tArray[i]];
                    [dArray addObject:model.displayName];
                }
                
                self.searchResultArray = dArray;
                [self.searchResultTableView reloadData];
                
            }else {
                [EaseAlertController showErrorAlert:errorDescription];
            }
        }
        
    }];
    
    
}


#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    if (!self.isSearching) {
        return;
    }
    
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [_searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(-keyBoardHeight);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}



- (void)keyBoardWillHide:(NSNotification *)note
{
    if (!self.isSearching) {
        return;
    }
    
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [_searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id obj = self.searchResultArray[indexPath.row];
    [self.groupSearchCell updateWithObj:obj];
    
    return self.groupSearchCell;
}
 
- (void)updateUIWithAddUserId:(NSString *)userId
                   isServicer:(BOOL)isServicer {
    if (userId.length == 0) {
        return;
    }
    
    if (isServicer) {
        if (![self.serverArray containsObject:userId]) {
            [self.serverArray addObject:userId];
            //去掉重复选择身份的id
            if ([self.userArray containsObject:userId]) {
                [self.userArray removeObject:userId];
            }
        }
        
    }else {
        if (![self.userArray containsObject:userId]) {
            [self.userArray addObject:userId];
            //去掉重复选择身份的id
            if ([self.serverArray containsObject:userId]) {
                [self.serverArray removeObject:userId];
            }
        }
    }
    
    if (![self.memberArray containsObject:userId]) {
        [self.memberArray addObject:userId];
    }
        
    [self.groupSearchAddView updateUIWithMemberArray:self.memberArray];

   
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchResultArray.count > 0) {
        return 24.0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView = [[UIView alloc] init];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = EaseIMKit_NFont(14.0);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.text = @"搜索结果";
    
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    hView.backgroundColor = [UIColor colorWithHexString:@"#171717"];
    titleLabel.textColor = [UIColor colorWithHexString:@"#7E7E7E"];
}else {
    hView.backgroundColor = EaseIMKit_ViewCellBgWhiteColor;
    titleLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
}
    
    [hView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(hView).insets(UIEdgeInsetsMake(0, 16.0, 0, 0));
    }];
    
    return hView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}


#pragma mark getter and setter
- (BQGroupSearchAddView *)groupSearchAddView {
    if (_groupSearchAddView == nil) {
        _groupSearchAddView = [[BQGroupSearchAddView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 100)];
        _groupSearchAddView.delegate = self;
        
        EaseIMKit_WS
        _groupSearchAddView.deleteMemberBlock = ^(NSString * _Nonnull userId) {
            if ([weakSelf.userArray containsObject:userId]) {
                [weakSelf.userArray removeObject:userId];
            }
        };
        
    }
    return _groupSearchAddView;
}


- (UITableView *)searchResultTableView {
    if (_searchResultTableView == nil) {
        _searchResultTableView = [[UITableView alloc] init];
        _searchResultTableView.tableFooterView = [[UIView alloc] init];
        _searchResultTableView.delegate = self;
        _searchResultTableView.dataSource = self;
        
        [_searchResultTableView registerClass:[BQGroupSearchCell class] forCellReuseIdentifier:NSStringFromClass([BQGroupSearchCell class])];
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        _searchResultTableView.backgroundColor = EaseIMKit_ViewBgBlackColor;

}else {

        _searchResultTableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
}

    }
    return _searchResultTableView;
}



- (NSMutableArray *)searchResultArray {
    if (_searchResultArray == nil) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}


- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
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
     
- (BQGroupSearchCell *)groupSearchCell {
    if (_groupSearchCell == nil) {
        _groupSearchCell = [self.searchResultTableView dequeueReusableCellWithIdentifier:[BQGroupSearchCell reuseIdentifier]];
                
        EaseIMKit_WS
        _groupSearchCell.customerBlock = ^(NSString * _Nonnull userId) {
            [weakSelf updateUIWithAddUserId:userId isServicer:NO];
        };
        
        _groupSearchCell.servicerBlock = ^(NSString * _Nonnull userId) {
            [weakSelf updateUIWithAddUserId:userId isServicer:YES];
        };
    }
    return _groupSearchCell;
}

@end
