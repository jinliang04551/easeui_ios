//
//  JHOrderViewController.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, EaseJHOrderType) {
    EaseJHOrderTypeMain = 1,
    EaseJHOrderTypeGetOrSend,
    EaseJHOrderTypeGood,
    EaseJHOrderTypeServe,
};

@class JHOrderViewModel;
@interface JHOrderViewController : UITableViewController
- (instancetype)initWithOrderType:(EaseJHOrderType)orderType;
@property (nonatomic, copy) void (^sendOrderBlock)(JHOrderViewModel *orderModel);

@end

NS_ASSUME_NONNULL_END
