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
#import "EaseLocationResultModel.h"

#define kSearchTypeKey @"kSearchTypeKey"
#define kSearchTypeValue @"kSearchTypeValue"

@interface EaseLocationSearchResultTableView ()<UITableViewDelegate,UITableViewDataSource,EMSearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EMSearchBar *searchBar;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray    *searchDataArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *placeBlackView;

@end



@implementation EaseLocationSearchResultTableView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self placeAndLayoutSubviews];
        [self.tableView registerClass:[EaseLocationResultCell class] forCellReuseIdentifier:NSStringFromClass([EaseLocationResultCell class])];
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            self.tableView.backgroundColor = EaseIMKit_ViewBgBlackColor;
            self.placeBlackView.backgroundColor = EaseIMKit_ViewBgBlackColor;
            
        }else {
            self.tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
            self.placeBlackView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        }
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    [self addSubview:self.placeBlackView];
    [self addSubview:self.contentView];

    [self.placeBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(100, 0, 0, 0));
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
 
}

- (void)updateWithSearchResultArray:(NSMutableArray *)tArray {
    self.dataArray = tArray;
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

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
    [cell updateWithObj:obj];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EaseLocationResultModel *model = self.dataArray[indexPath.row];
    if (self.selectedBlock) {
        self.selectedBlock(model);
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
    [self.tableView reloadData];
    
}

- (void)searchBarSearchButtonClicked:(EMSearchBar *)searchBar
{
    
}


- (void)searchTextDidChangeWithString:(NSString *)aString {
    if (self.searchLocationBlock) {
        self.searchLocationBlock(aString);
    }
}


#pragma mark getter and setter
- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeHolder = @"搜索地点";
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}




- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)placeBlackView {
    if (_placeBlackView == nil) {
        _placeBlackView = [[UIView alloc] init];
    }
    return _placeBlackView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 8.0;
        _contentView.clipsToBounds = YES;
        
        [_contentView addSubview:self.searchBar];
        [_contentView addSubview:self.tableView];

        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView);
            make.left.equalTo(_contentView);
            make.right.equalTo(_contentView);
            make.height.equalTo(@(48.0));
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).offset(0.0);
            make.left.equalTo(_contentView);
            make.right.equalTo(_contentView);
            make.bottom.equalTo(_contentView);
        }];
        
        
        
    }
    return _contentView;
}


@end


#undef kSearchTypeKey
#undef kSearchTypeValue
