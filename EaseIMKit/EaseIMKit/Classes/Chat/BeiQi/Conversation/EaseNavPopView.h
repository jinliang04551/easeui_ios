//
//  EaseNavPopView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/8/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseNavPopView : UIView
@property (nonatomic,copy) void(^actionBlock)(NSInteger index);
- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
