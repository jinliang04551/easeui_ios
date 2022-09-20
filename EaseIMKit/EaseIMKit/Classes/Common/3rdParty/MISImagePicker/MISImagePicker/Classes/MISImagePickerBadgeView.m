//
//  MISBadageLabel.m
//  LNJXT
//
//  Created by Mao on 3/12/15.
//  Copyright (c) 2015 Eduapp. All rights reserved.
//

#import "MISImagePickerBadgeView.h"
#import <Masonry/Masonry.h>

@interface MISImagePickerBadgeView()
@property(nonatomic, strong) UILabel* label;
@end

@implementation MISImagePickerBadgeView


- (instancetype)init {
	if ((self = [super init])) {
        self.backgroundColor = [UIColor colorWithRed:0xE9/255.0f green:0x5A/255.0f blue:0x5A/255.0f alpha:1.0];
		self.hidden = YES;
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
        
		_label = [UILabel new];
		_label.backgroundColor = UIColor.clearColor;
		_label.font = [UIFont systemFontOfSize:14.0f];
		_label.textColor = [UIColor whiteColor];
		_label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_label];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.height.equalTo(@20.0f);
            make.width.greaterThanOrEqualTo(@20.0f);
        }];
	}
	return self;
}

- (void)setBadgeValue:(NSInteger )badgeValue {
	if (_badgeValue != badgeValue) {
		
		_badgeValue = badgeValue;
		
		if (_badgeValue > 0 && _badgeValue <= 99) {
			self.label.text = @(_badgeValue).stringValue;
			self.hidden = NO;
		}
		else if(_badgeValue > 99) {
			self.label.text = @"99+";
			self.hidden = NO;
		}
		else {
			self.hidden = YES;
		}
	}
}

/**
 *  设置徽标值
 *
 *  @param badgeValue 0 时隐藏
 *  @param flag       是否有动画
 */
- (void)setBadgeValue:(NSInteger)badgeValue animated:(BOOL)flag {
	self.badgeValue = badgeValue;
	
	if (flag) {
		//动画
		CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
		k.values = @[@(0.1),@(1.0),@(1.2)];
		k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
		k.calculationMode = kCAAnimationLinear;
		[self.layer addAnimation:k forKey:@"SHOW"];
	}
}


@end
