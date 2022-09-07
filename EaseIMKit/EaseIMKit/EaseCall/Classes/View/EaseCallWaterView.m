//
//  EaseCallFloatingView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/23.
//

#import "EaseCallWaterView.h"
#import "EaseHeaders.h"


#define ColorWithAlpha(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
@implementation EaseCallWaterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _multiple = 1.5;
        
        [UIView animateWithDuration:4 animations:^{

            self.transform = CGAffineTransformScale(self.transform, 1.5, 1.5);
            self.alpha = 0;

        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    CALayer *animationLayer = [CALayer layer];
    
    //这里同时创建[缩放动画/背景色渐变/边框色渐变]三个简单动画
    NSArray *animationArray = [self animationArray];
    
    //将三个动画合并为n一个动画组
    CAAnimationGroup *animationGroup = [self animationGroupAnimations:animationArray];
    
    //添加动画组
    CALayer *pulsingLayer = [self pulsingLayer:rect animation:animationGroup];
    
    //将动画 Layer添加到 animationLayer
    [animationLayer addSublayer:pulsingLayer];
    
    //加入动画
    [self.layer addSublayer:animationLayer];
    
}

- (NSArray *)animationArray {
    NSArray *animationArray = nil;
    CABasicAnimation *scaleAnimation = [self scaleAnimation];
    CAKeyframeAnimation *borderColorAnimation = [self backgroundColorAnimation];
    CAKeyframeAnimation *backGroundColorAnimation = [self backgroundColorAnimation];
    animationArray = @[scaleAnimation, backGroundColorAnimation, borderColorAnimation];
    
    return animationArray;
}


- (CAAnimationGroup *)animationGroupAnimations:(NSArray *)array {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.beginTime = CACurrentMediaTime();
    animationGroup.duration = 3;
    animationGroup.repeatCount = HUGE;
    animationGroup.animations = array;
    animationGroup.removedOnCompletion = NO;
    return animationGroup;
}

- (CABasicAnimation *)scaleAnimation {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1;
    scaleAnimation.toValue = @(_multiple);
    return scaleAnimation;
}

// 使用关键帧动画，使得颜色动画不要那么的线性变化
- (CAKeyframeAnimation *)backgroundColorAnimation {
    CAKeyframeAnimation *backgroundColorAnimation = [CAKeyframeAnimation animation];
    backgroundColorAnimation.keyPath = @"backgroundColor";
    
//    backgroundColorAnimation.values = @[(__bridge id)EaseIMKit_COLOR_HEX(0x969696).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x646464).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x242424).CGColor];
//    backgroundColorAnimation.keyTimes = @[@0.4,@0.7,@1];

    backgroundColorAnimation.values = @[(__bridge id)EaseIMKit_COLOR_HEX(0x808080).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x4B4B4B).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x242424).CGColor];
    backgroundColorAnimation.keyTimes = @[@0.4,@0.7,@1];
    
    return backgroundColorAnimation;
}

- (CAKeyframeAnimation *)borderColorAnimation {
    CAKeyframeAnimation *borderColorAnimation = [CAKeyframeAnimation animation];
    borderColorAnimation.keyPath = @"borderColor";
      
//    borderColorAnimation.values = @[(__bridge id)EaseIMKit_COLOR_HEX(0xB9B9B9).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x252525).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x171717).CGColor];
//    borderColorAnimation.keyTimes = @[@0.4,@0.7,@1];

    borderColorAnimation.values = @[(__bridge id)EaseIMKit_COLOR_HEX(0x808080).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x4B4B4B).CGColor,(__bridge id)EaseIMKit_COLOR_HEX(0x242424).CGColor];
    borderColorAnimation.keyTimes = @[@0.4,@0.7,@1];

    
    return borderColorAnimation;
}
    

- (CALayer *)pulsingLayer:(CGRect)rect animation:(CAAnimationGroup *)animation {
    CALayer *pulsingLayer = [CALayer layer];
//    pulsingLayer.borderWidth = 0.5;
//    pulsingLayer.borderColor = ColorWithAlpha(1.0, 1.0, 1.0, 0.5).CGColor;
    pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    pulsingLayer.cornerRadius = rect.size.height / 2;
    [pulsingLayer addAnimation:animation forKey:@"plulsing"];
    return pulsingLayer;
}

@end
