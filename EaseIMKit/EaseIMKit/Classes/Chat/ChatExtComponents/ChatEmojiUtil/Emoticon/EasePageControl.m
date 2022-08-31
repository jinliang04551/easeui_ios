//
//  EasePageControl.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/31.
//

#import "EasePageControl.h"
#import "EaseHeaders.h"

@interface EasePageControl ()
@property (nonatomic, strong) UIImage* activeImage;
@property (nonatomic, strong) UIImage* inactiveImage;

@end

@implementation EasePageControl
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.activeImage = [UIImage easeUIImageNamed:@"jh_activeImage"];
        self.inactiveImage = [UIImage easeUIImageNamed:@"jh_inactiveImage"];

    }
    return self;
}

- (void)updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        if (i == self.currentPage){
            dot.image = self.activeImage;
        }else {
             dot.image = self.inactiveImage;
        }
    }
}


- (void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    [self updateDots];
}

- (void)updateWithCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    [self updateDots];

}

@end

