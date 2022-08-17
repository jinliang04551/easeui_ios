//
//  JHOrderViewModel.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import "JHOrderViewModel.h"

@interface JHOrderViewModel ()
@property (nonatomic, strong) NSString *aid;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderType;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *orderDate;
@property (nonatomic, strong) NSString *messageInfo;


@end

@implementation JHOrderViewModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {

        self.aid = dic[@"aid"];
        self.orderId = dic[@"orderId"];
        self.orderType = [self getOrderTypeWithString:dic[@"orderType"]];
        self.productName = dic[@"productName"];
        self.orderDate = dic[@"orderDate"];

    }
    return self;
}

- (NSString *)getOrderTypeWithString:(NSString *)string {
    NSString *name = @"";
   
    if ([string isEqualToString:@"MAIN"]) {
        name = @"维保订单";
    }
    
    if ([string isEqualToString:@"PICKCAR"]) {
        name = @"取送订单";
    }
    
    if ([string isEqualToString:@"FINE"]) {
        name = @"精品订单";
    }
    
    if ([string isEqualToString:@"PACKAGE"]) {
        name = @"服务订单";
    }
    
    return name;
}


- (void)displayOrderMessage:(NSString *)msgInfo {
    self.messageInfo = msgInfo;
}

@end
