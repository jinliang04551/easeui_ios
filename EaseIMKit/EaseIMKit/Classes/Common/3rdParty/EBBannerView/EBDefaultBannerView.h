//
//  EBDefaultBannerView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/9/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EBDefaultBannerView : UIView
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, copy) void (^tapCellBlock)(void);

@end

NS_ASSUME_NONNULL_END
