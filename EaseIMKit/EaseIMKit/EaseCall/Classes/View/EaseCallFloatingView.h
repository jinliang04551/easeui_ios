//
//  EaseCallFloatingView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/8/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseCallFloatingView : UIView
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) void (^tapViewBlock)(void);

@end

NS_ASSUME_NONNULL_END
