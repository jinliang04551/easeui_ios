//
//  EaseLocationSearchResultTableView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/24.
//

#import "EaseLocationSearchResultTableView.h"
#import "EaseLocationResultCell.h"
#import "EaseHeaders.h"
#import "EMSearchBar.h"
#import "EMRealtimeSearch.h"


#define kSearchTypeKey @"kSearchTypeKey"
#define kSearchTypeValue @"kSearchTypeValue"

@interface EaseLocationSearchResultTableView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) EMSearchBar *searchBar;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray    *searchDataArray;


@end

@implementation EaseLocationSearchResultTableView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.tableView registerClass:[EaseLocationResultCell class] forCellReuseIdentifier:NSStringFromClass([EaseLocationResultCell class])];
        
        [self placeAndLayoutSubviews];
        [self updateUI];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    
    [self addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(8.0);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];

}

- (void)updateUI {
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EaseLocationResultCell *cell = (EaseLocationResultCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EaseLocationResultCell class])];
    
    id obj = self.dataArray[indexPath.row];
    [obj updateWithObj:obj];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id obj = self.dataArray[indexPath.row];
    if (self.selectedBlock) {
//        self.selectedBlock(dic[kSearchTypeKey], [dic[kSearchTypeValue] integerValue]);
//        self.searchGroupType = [dic[kSearchTypeValue] integerValue];
        
        
    }
    
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
    
    [self.searchDataArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}


- (void)searchTextDidChangeWithString:(NSString *)aString {
    
    EaseIMKit_WS
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.searchDataArray removeAllObjects];
//            [weakSelf.searchDataArray addObjectsFromArray:results];
//            [self.tableView reloadData];
//        });
    }];
    
    
}


#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 36.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

@end


#undef kSearchTypeKey
#undef kSearchTypeValue
