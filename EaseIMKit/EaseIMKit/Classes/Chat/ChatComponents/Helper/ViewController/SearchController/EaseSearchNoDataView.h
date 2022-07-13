//
//  EaseSearchNOdataView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseSearchNoDataView : UIView
/// 无数据占位图
@property (nonatomic,strong,readonly) UIImageView *noDataImageView;

/**
 提示语
 */
@property (nonatomic,strong,readonly) UILabel *prompt;

@end

NS_ASSUME_NONNULL_END
