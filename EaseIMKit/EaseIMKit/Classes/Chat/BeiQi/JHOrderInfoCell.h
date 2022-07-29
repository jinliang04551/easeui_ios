//
//  JHOrderInfoCell.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import "BQCustomCell.h"
@class JHOrderViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface JHOrderInfoCell : BQCustomCell
@property (nonatomic, copy) void (^sendOrderBlock)(JHOrderViewModel *orderModel);

@end

NS_ASSUME_NONNULL_END
