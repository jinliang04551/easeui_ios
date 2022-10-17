//
//  YGTransferOwnerViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/17.
//

#import "YGTransferOwnerViewController.h"
#import "EMSearchBar.h"
#import "YGGroupMuteItemCell.h"
#import "EMRealtimeSearch.h"
#import "EaseHeaders.h"

@interface YGTransferOwnerViewController ()<UITableViewDelegate,UITableViewDataSource,EMSearchBarDelegate>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EMSearchBar *searchBar;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation YGTransferOwnerViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;

    [self _setupSubviews];
    
    [self.tableView reloadData];
}

#pragma mark - Subviews

- (void)_setupSubviews{
    
    self.titleView = [self customNavWithTitle:self.navTitle rightBarIconName:@"" rightBarTitle:@"确定" rightBarAction:@selector(doneAction)];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];
        
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom).offset(8.0);
        make.left.equalTo(self.view).offset(16.0);
        make.right.equalTo(self.view).offset(-16.0);
        make.height.equalTo(@(32.0));
    }];


    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(8.0);
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? [self.searchArray count] : [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YGGroupMuteItemCell *cell = (YGGroupMuteItemCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YGGroupMuteItemCell class])];
    
    NSString *username = self.isSearching ? [self.searchArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    
    BOOL isChecked = [self userIsChecked:username];
    [cell updateWithObj:username isChecked:isChecked];
    
    EaseIMKit_WS
    cell.checkBlcok = ^(NSString * _Nonnull userId, BOOL isChecked) {
        if ([weakSelf.selectedArray containsObject:userId]) {
            [weakSelf.selectedArray removeObject:userId];
        } else {
            [weakSelf.selectedArray removeAllObjects];
            [weakSelf.selectedArray addObject:userId];
        }
        [weakSelf.tableView reloadData];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)userIsChecked:(NSString *)userId {
    return [self.selectedArray containsObject:userId];
}


#pragma mark - EMSearchBarDelegate
- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
{
    self.isSearching = YES;
}

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isSearching = NO;
    
    [self.searchArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}

- (void)searchTextDidChangeWithString:(NSString *)aString {
    
    EaseIMKit_WS
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.searchArray removeAllObjects];
            [weakSelf.searchArray addObjectsFromArray:results];
            [weakSelf.tableView reloadData];
        });
    }];
    
    
}

#pragma mark - Action

- (void)doneAction {
    if (self.selectedArray.count == 0) {
        [self showHint:@"未选择转让群主"];
        return;
    }
    
    [[EMClient sharedClient].groupManager updateGroupOwner:self.group.groupId newOwner:self.selectedArray.firstObject completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        if (aError == nil) {
            [self showHint:@"转让群主成功"];
            if (self.transferOwnerBlock) {
                self.transferOwnerBlock(YES);
            }

        }else {
            [self showHint:@"转让群主失败"];
            if (self.transferOwnerBlock) {
                self.transferOwnerBlock(NO);
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}


#pragma mark getter and setter
- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 64.0;
        
        [_tableView registerClass:[YGGroupMuteItemCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupMuteItemCell class])];
        
        _tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }
    return _tableView;
}



- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)searchArray {
    if (_searchArray == nil) {
        _searchArray = [NSMutableArray array];
    }
    return _searchArray;
}

- (NSMutableArray *)selectedArray {
    if (_selectedArray == nil) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

@end
