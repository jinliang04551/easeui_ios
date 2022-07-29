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
        self.orderType = dic[@"orderType"];
        self.productName = dic[@"productName"];
        self.orderDate = dic[@"orderDate"];

    }
    return self;
}

- (void)displayOrderMessage:(NSString *)msgInfo {
    self.messageInfo = msgInfo;
}

@end
