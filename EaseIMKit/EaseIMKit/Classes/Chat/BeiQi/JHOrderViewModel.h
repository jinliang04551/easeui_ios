//
//  JHOrderViewModel.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//"aid": "222600",
//"orderId": "AFVRMT20220606155524474a",
//"orderType": "MAIN",
//"productName": "维保订单",
//"orderDate": "2022-06-06 15:55:24"

@interface JHOrderViewModel : NSObject
@property (nonatomic, strong, readonly) NSString *aid;
@property (nonatomic, strong, readonly) NSString *orderId;
@property (nonatomic, strong, readonly) NSString *orderType;
@property (nonatomic, strong, readonly) NSString *productName;
@property (nonatomic, strong, readonly) NSString *orderDate;
@property (nonatomic, strong, readonly) NSString *messageInfo;


- (instancetype)initWithDic:(NSDictionary *)dic;

- (void)displayOrderMessage:(NSString *)msgInfo;

@end

NS_ASSUME_NONNULL_END
