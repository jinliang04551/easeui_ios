//
//  YGGroupSearchViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/18.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupSearchViewController.h"
#import "YGGroupSearchView.h"

#import "EMSearchBar.h"
#import "EMRealtimeSearch.h"
#import "YGAvatarTitleAccessCell.h"
#import "EaseNoDataPlaceHolderView.h"
#import "YGGroupSearchTypeTableView.h"
#import "YGSearchGroupModel.h"
#import "EMChatViewController.h"
#import "EaseHeaders.h"


@interface YGGroupSearchViewController ()<UITableViewDelegate,UITableViewDataSource,YGGroupSearchViewDelegate>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) YGGroupSearchView *groupSearchView;
@property (nonatomic, strong) EaseNoDataPlaceHolderView *noDataPromptView;
@property (nonatomic, strong) YGGroupSearchTypeTableView *searchTypeTableView;
@property (nonatomic, assign) YGSearchGroupType searchGroupType;


@property (nonatomic, strong) NSString *searchkeyword;

//search keyword
@property (nonatomic, strong) NSString *searchGroupName;
@property (nonatomic, strong) NSString *searchMobile;
@property (nonatomic, strong) NSString *searchOrderId;
@property (nonatomic, strong) NSString *searchVin;

@end

@implementation YGGroupSearchViewController

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

    self.searchGroupType = self.searchTypeTableView.searchGroupType;
    
    [self placeAndLayoutSubviews];
    
    [self.tableView reloadData];
}

//searchGroupListWithAid:@"" mobile:@"" orderId:@"" vin:@"" groupname:@""

- (void)updateSearchKeyword {
    self.searchGroupName = @"";
    self.searchOrderId = @"";
    self.searchMobile = @"";
    self.searchVin = @"";

    if (self.searchGroupType == YGSearchGroupTypeGroupName) {
        self.searchGroupName = self.searchkeyword;
    }
    
    if (self.searchGroupType == YGSearchGroupTypeOrderId) {
        self.searchOrderId = self.searchkeyword;
    }

    if (self.searchGroupType == YGSearchGroupTypePhone) {
        self.searchMobile = self.searchkeyword;
    }

    if (self.searchGroupType == YGSearchGroupTypeVINCode) {
        self.searchVin = self.searchkeyword;
    }
    
}

- (void)searchGroupChat {
    [self updateSearchKeyword];
    
    NSString *aid = @"";
    
    [[EaseHttpManager sharedManager] searchGroupListWithAid:aid mobile:self.searchMobile orderId:self.searchOrderId vin:self.searchVin groupname:self.searchGroupName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
    
        NSLog(@"%s\n response:%@",__func__,response);
        
        if (response && response.length > 0) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSArray *dataArray = responsedict[@"data"];

                NSMutableArray *tArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; ++i) {
                    YGSearchGroupModel *model = [[YGSearchGroupModel alloc] initWithDic:dataArray[i]];
                    if (model) {
                        [tArray addObject:model];
                    }
                }
                self.dataArray = tArray;
                [self.tableView reloadData];

                self.noDataPromptView.hidden = self.dataArray.count > 0 ? YES : NO;
                
            }else {
                self.dataArray = [@[] mutableCopy];
                [self.tableView reloadData];

                self.noDataPromptView.hidden = self.dataArray.count > 0 ? YES : NO;

            }
        }

        
    }];
    
}

- (void)tapAction {
    self.searchTypeTableView.hidden = YES;
}

#pragma mark - Subviews

- (void)placeAndLayoutSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
        
    [self.view addSubview:self.groupSearchView];
    [self.view addSubview:self.tableView];

    [self.groupSearchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_StatusBarHeight +52.0));
    }];

    [self.view addSubview:self.noDataPromptView];
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchView.mas_bottom).offset(kNoDataPlaceHolderViewTopPadding);
        make.centerX.left.right.equalTo(self.view);
    }];

    
    [self.view addSubview:self.searchTypeTableView];
    [self.searchTypeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchView.mas_bottom).offset(-10.0);
        make.left.equalTo(self.groupSearchView.leftBackButton.mas_right);
        make.right.equalTo(self.groupSearchView.vLineImageView.mas_right);
//        make.width.equalTo(@(110.0));
        make.height.equalTo(@(144.0));
    }];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupSearchView.mas_bottom);
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
    return  [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"YGAvatarTitleAccessCell";
    YGAvatarTitleAccessCell *cell = (YGAvatarTitleAccessCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row];
   
    [cell updateWithObj:obj];
    EaseIMKit_WS
    cell.accessBlock = ^(NSString * _Nonnull groupId) {
        [weakSelf goGroupChatPageWithGroupId:groupId];
    };
    
    return cell;
}

- (void)goGroupChatPageWithGroupId:(NSString *)groupId {
    EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:groupId conversationType:EMConversationTypeGroupChat];
    
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - YGGroupSearchViewDelegate
- (void)showSearchGroupTypeTable {
    self.searchTypeTableView.hidden = !self.searchTypeTableView.hidden;
}


- (void)hiddenSearchGroupTypeTable {
    self.searchTypeTableView.hidden = YES;
    self.noDataPromptView.hidden = YES;
}


- (void)searchButtonClickedWithKeyword:(NSString *)keyword {
    [self searchGroupWithKeyword:keyword];
}

- (void)searchViewShouldBeginEditing:(YGGroupSearchView *)searchView{
    self.searchTypeTableView.hidden = YES;

}

- (void)clearSearchText {
    self.noDataPromptView.hidden = YES;
    
}

#pragma mark private method
- (void)searchGroupWithKeyword:(NSString *)keyword {
    if (keyword.length == 0) {
        return;
    }
    
    self.searchkeyword = keyword;
    [self searchGroupChat];
}



#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 64.0;
    
        [_tableView registerClass:[YGAvatarTitleAccessCell class] forCellReuseIdentifier:NSStringFromClass([YGAvatarTitleAccessCell class])];
                
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tap.numberOfTapsRequired = 1;
        [_tableView addGestureRecognizer:tap];

    }
    return _tableView;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (YGGroupSearchView *)groupSearchView {
    if (_groupSearchView == nil) {
        _groupSearchView = [[YGGroupSearchView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_StatusBarHeight + 52.0)];
        _groupSearchView.delegate = self;
        
        EaseIMKit_WS
        _groupSearchView.backActionBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
    }
    return _groupSearchView;
}

- (EaseNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = EaseNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:[UIImage easeUIImageNamed:@"jihu_search_nodata"]];
        _noDataPromptView.prompt.text = @"搜索无结果";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}


- (YGGroupSearchTypeTableView *)searchTypeTableView {
    if (_searchTypeTableView == nil) {
        _searchTypeTableView = [[YGGroupSearchTypeTableView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _searchTypeTableView.hidden = YES;

        EaseIMKit_WS
        _searchTypeTableView.selectedBlock = ^(NSString * _Nonnull selectedName, NSInteger selectedType) {
            weakSelf.groupSearchView.searchTypeLabel.text = selectedName;
            weakSelf.searchGroupType = selectedType;
            weakSelf.searchTypeTableView.hidden = YES;
//            [weakSelf.groupSearchView clearSearchContent];
        };
        
    }
    return _searchTypeTableView;
}


@end


