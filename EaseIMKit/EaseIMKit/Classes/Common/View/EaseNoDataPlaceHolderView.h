//
//  EaseNoDataPlaceHolderView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseNoDataPlaceHolderView : UIView
/// 无数据占位图
@property (nonatomic,strong,readonly) UIImageView *noDataImageView;
/**
 提示语
 */
@property (nonatomic,strong,readonly) UILabel *prompt;

@end

NS_ASSUME_NONNULL_END
