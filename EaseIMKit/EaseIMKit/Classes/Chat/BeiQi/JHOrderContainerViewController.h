//
//  JHOrderContainerViewController.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JHOrderViewModel;
@interface JHOrderContainerViewController : UIViewController
@property (nonatomic, copy) void (^sendOrderBlock)(JHOrderViewModel *orderModel);

@end

NS_ASSUME_NONNULL_END
