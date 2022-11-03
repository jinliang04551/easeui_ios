//
//  JHOrderViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import "JHOrderViewController.h"
#import "JHOrderInfoCell.h"
#import "MISScrollPage.h"
#import "JHOrderViewModel.h"
#import "EaseIMKitManager.h"

@interface JHOrderViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) EaseJHOrderType orderType;
@property (nonatomic, strong) NSString  *orderTypeName;


@end

@implementation JHOrderViewController
- (instancetype)initWithOrderType:(EaseJHOrderType)orderType {
    self = [super init];
    if (self) {
        self.orderType = orderType;
        [self getOrderTypeName];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:[JHOrderInfoCell class] forCellReuseIdentifier:NSStringFromClass([JHOrderInfoCell class])];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    self.view.backgroundColor = UIColor.whiteColor;
    self.tableView.backgroundColor = UIColor.whiteColor;

//    [self fetchOrderList];
    [self buildTestData];
}

- (void)getOrderTypeName {
    NSString *name = @"";
    switch (self.orderType) {
        case 1:
            name = @"MAIN";
            break;
        case 2:
            name = @"PICKCAR";
            break;
        case 3:
            name = @"FINE";
            break;
        case 4:
            name = @"PACKAGE";
            break;
    }
    self.orderTypeName = name;
}

- (void)fetchOrderList {
    [[EaseHttpManager sharedManager] searchCustomOrderWithOrderType:self.orderTypeName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {

                NSDictionary *entity = responsedict[@"entity"];
                NSArray *appvovalArray = entity[@"data"];
                NSMutableArray *tArray = [NSMutableArray array];
                for (int i = 0; i < appvovalArray.count; ++i) {
                    JHOrderViewModel *model = [[JHOrderViewModel alloc] initWithDic:appvovalArray[i]];
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


//"aid": "222600",
//"orderId": "AFVRMT20220606155524474a",
//"orderType": "MAIN",
//"productName": "维保订单",
//"orderDate": "2022-06-06 15:55:24"

- (void)buildTestData {
    NSMutableArray *tArray = [NSMutableArray array];
    for (int i = 0; i < 3; ++i) {
        JHOrderViewModel *model = [[JHOrderViewModel alloc] init];
        model.aid = @"1113543768458";
        model.orderId = model.aid;
        model.orderType = @"MAIN";

        NSArray *titleArray = [self getOrderTitleArray];
        if (self.orderType == 1) {
            
            switch (i) {
                case 0:
                    model.productName = titleArray[0];
                    break;
                case 1:
                    model.productName = titleArray[1];;
                    break;
                case 2:
                    model.productName = titleArray[2];;
                    break;
                default:
                    break;
            }
            
        }
        if (self.orderType == 2) {
            switch (i) {
                case 0:
                    model.productName = titleArray[3];
                    break;
                case 1:
                    model.productName = titleArray[4];;
                    break;
                case 2:
                    model.productName = titleArray[5];;
                    break;
                default:
                    break;
            }

        }
                
        model.orderDate = @"2022-09-21 18:30:23";

        if (model) {
            [tArray addObject:model];
        }
    }
    self.dataArray = tArray;
    [self.tableView reloadData];
    
}


- (NSArray *)getOrderTitleArray {
    NSArray *titles = @[@"即时通讯尊享版",@"即时推送",@"内容审核",@"新客户专享套餐",@"维保延长套餐",@"服务升级套餐"];
    return titles;
}

    
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHOrderInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JHOrderInfoCell class])];
    
    id obj = self.dataArray[indexPath.row];
    [cell updateWithObj:obj];
    cell.sendOrderBlock = ^(JHOrderViewModel * _Nonnull orderModel) {
        [self sendOrderInfoWithModel:orderModel];
    };
    
    return cell;
    
}

- (void)sendOrderInfoWithModel:(JHOrderViewModel *)orderModel {
    if (self.sendOrderBlock) {
        self.sendOrderBlock(orderModel);
    }
}

#pragma mark getter and setter
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.array;
    }
    return _dataArray;
}


#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{

}

- (void)viewDidAppearForIndex:(NSUInteger)index{
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    self.editing = NO;
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    
}


@end
