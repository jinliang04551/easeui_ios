//
//  AgoraCustomCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface BQCustomCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UIView* bottomLine;

@property (nonatomic, strong, readonly)UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, copy) void (^tapCellBlock)(void);

+ (NSString *)reuseIdentifier;
+ (CGFloat)height;
- (void)prepare;
- (void)placeSubViews;
- (void)updateWithObj:(id)obj;
- (void)updateCellWithUserId:(NSString *)aUid;


@end

NS_ASSUME_NONNULL_END
