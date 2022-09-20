//
//  MISBadageLabel.h
//  LNJXT
//
//  Created by Mao on 3/12/15.
//  Copyright (c) 2015 Eduapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MISImagePickerBadgeView : UIView
/*
 *It's hiden when badgeValue as 0
 *It's show 99+ when badgeValue > 99
 */
@property(nonatomic, assign)NSInteger badgeValue;

/**
 *  设置徽标值
 *
 *  @param badgeValue 0 时隐藏
 *  @param flag       是否有动画
 */
- (void)setBadgeValue:(NSInteger)badgeValue animated:(BOOL)flag;

@end
