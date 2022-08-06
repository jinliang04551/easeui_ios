//
//  YGGroupApplyController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupApplyApprovalController.h"
#import "YGGroupApplyApprovalCell.h"
#import "EaseHeaders.h"
#import "BQGroupApplyApprovalModel.h"
#import "EaseHeaders.h"

@interface YGGroupApplyApprovalController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation YGGroupApplyApprovalController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self addPopBackLeftItem];
//    self.title = @"群组申请";
    
    
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    
    [self.tableView registerClass:[YGGroupApplyApprovalCell class] forCellReuseIdentifier:NSStringFromClass([YGGroupApplyApprovalCell class])];

    [self placeAndLayoutSubviews];
    
    [self fetchGroupApplyList];
    
}

- (void)fetchGroupApplyList {
    
    [[EaseHttpManager sharedManager] fetchGroupApplyListWithPageNumber:self.pageNumber pageSize:20 completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        [self hideHud];
        
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSDictionary *entity = responsedict[@"entity"];
                NSArray *appvovalArray = entity[@"data"];
                NSMutableArray *tArray = [NSMutableArray array];
                for (int i = 0; i < appvovalArray.count; ++i) {
                    BQGroupApplyApprovalModel *model = [[BQGroupApplyApprovalModel alloc] initWithDic:appvovalArray[i]];
                    if (model) {
                        [tArray addObject:model];
                    }
                }
                self.dataArray = tArray;
                [self.tableView reloadData];
                
            }else {
                [EaseAlertController showErrorAlert:errorDescription];
            }
        }
        
        
    }];
    
}



- (void)placeAndLayoutSubviews {

    self.titleView = [self customNavWithTitle:@"群组申请" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EMVIEWBOTTOMMARGIN);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
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


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YGGroupApplyApprovalCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YGGroupApplyApprovalCell class]) forIndexPath:indexPath];
    id obj = self.dataArray[indexPath.row];
    [cell updateWithObj:obj];
    
    EaseIMKit_WS
    cell.approvalBlock = ^(BQGroupApplyApprovalModel * _Nonnull model) {
        [weakSelf approvalJoinGroupApplyWithModel:model];
    };
    
    return cell;
}

- (void)approvalJoinGroupApplyWithModel:(BQGroupApplyApprovalModel *)model {
    [[EaseHttpManager sharedManager] approvalGroupWithGroupId:model.groupId username:model.userName role:model.role option:model.state completion:^(NSInteger statusCode, NSString * _Nonnull response) {
            
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                if ([model.state isEqualToString:@"success"]) {
                    [self showHint:@"已同意"];
                }
                
                if ([model.state isEqualToString:@"fail"]) {
                    [self showHint:@"已拒绝"];
                }
                
                [self fetchGroupApplyList];
                
            }else {
                [EaseAlertController showErrorAlert:errorDescription];
            }
        }
        

    }];
}

#pragma mark getter and setter
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;        
        _tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }

    return _tableView;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.array;
    }
    return _dataArray;
}

@end
