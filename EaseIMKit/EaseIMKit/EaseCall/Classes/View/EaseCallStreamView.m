//
//  EaseCallStreamView.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallStreamView.h"
#import <Masonry/Masonry.h>
#import "UIImage+Ext.h"
#import "EaseHeaders.h"

@interface EaseCallStreamView()

@property (nonatomic, strong) UIImageView *statusView;
@property (nonatomic) NSTimer *timeTimer;
@property (nonatomic, strong) UIView *nameBgView;

@property (nonatomic, strong) NSMutableArray *talkingImageArray;
@property (nonatomic, strong) UIImageView *talkingImageView;

@end

@implementation EaseCallStreamView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableVoice = YES;
        _isTalking = NO;
        
        self.bgView = [[UIImageView alloc] init];
        self.bgView.contentMode = UIViewContentModeScaleAspectFit;
        self.bgView.userInteractionEnabled = YES;
        UIImage *image = [UIImage imageNamedFromBundle:@"call_default_user_icon"];
        self.bgView.image = image;
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
//            make.centerX.equalTo(self);
//            make.centerY.equalTo(self).with.offset(-5);
//            make.width.lessThanOrEqualTo(@70);
//            make.height.lessThanOrEqualTo(@70);
        
        }];
        
        self.backgroundColor = [UIColor blackColor];
        self.statusView = [[UIImageView alloc] init];
        self.statusView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.statusView];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-5);
            make.right.equalTo(self).offset(-5);
            make.width.height.equalTo(@20);
        }];
        
        [self addSubview:self.talkingImageView];
        [self.talkingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.statusView);
        }];
        
        
        [self addSubview:self.nameBgView];
        [self.nameBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-5);
            make.left.equalTo(self).offset(16.0);
            make.right.equalTo(self);
            make.height.equalTo(@30);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [self addGestureRecognizer:tap];
        
        
        _isLockedBgView = NO;
    }
    
    return self;
}

- (void)setEnableVoice:(BOOL)enableVoice
{
    _enableVoice = enableVoice;
    
    [self bringSubviewToFront:_statusView];
    if (enableVoice) {
        _statusView.image = nil;
    } else {
        self.isTalking = NO;
        _statusView.image = [UIImage imageNamedFromBundle:@"microphonenclose"];
    }
}

- (void)setEnableVideo:(BOOL)enableVideo
{
    _enableVideo = enableVideo;
    
    if (enableVideo) {
        _bgView.hidden = YES;
        [_displayView setHidden:NO];
    } else {
        _bgView.hidden = NO;
        [_displayView setHidden:YES];
    }
}

- (void)setIsTalking:(BOOL)isTalking
{
    if(isTalking != _isTalking) {
        if(isTalking) {
            _statusView.image = [UIImage imageNamedFromBundle:@"talking_green"];
            if(!self.timeTimer)
                self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(timeTalkingAction:) userInfo:nil repeats:NO];
            
        }else{
            if(self.timeTimer) {
                [self.timeTimer invalidate];
                self.timeTimer = nil;
            }
        }
    }
    _isTalking = isTalking;
}

- (void)timeTalkingAction:(id)sender
{
    _statusView.image = nil;
    self.isTalking = NO;
    
//    [UIView animateWithDuration:1.0 animations:^{
//        self.statusView.hidden = YES;
//        [self.talkingImageView startAnimating];
//        self.talkingImageView.hidden = NO;
//
//    } completion:^(BOOL finished) {
//        self.isTalking = NO;
//    }];
}

#pragma mark - UITapGestureRecognizer

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {

        if (_delegate && [_delegate respondsToSelector:@selector(streamViewDidTap:)]) {
            [_delegate streamViewDidTap:self];
        }
    }
}


#pragma mark getter and estter
- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UIView *)nameBgView {
    if (_nameBgView == nil) {
        _nameBgView = [[UIView alloc] init];
        _nameBgView.backgroundColor = [UIColor clearColor];
        
        [_nameBgView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_nameBgView);
        }];
        
    }
    return _nameBgView;
}


- (NSMutableArray *)talkingImageArray {
    if (_talkingImageArray == nil) {
        _talkingImageArray = [NSMutableArray new];
        for (NSInteger i = 0; i < 14; ++i) {
            NSString *imageName = [NSString stringWithFormat:@"call_talking_%@",@(i)];
            UIImage *image = [UIImage imageNamedFromBundle:imageName];
            [_talkingImageArray addObject:image];
        }
    }
    
    return _talkingImageArray;
}

- (UIImageView *)talkingImageView {
    if (!_talkingImageView) {
        _talkingImageView = [[UIImageView alloc] init];
        //图片播放一次所需时长
        _talkingImageView.animationDuration = 0.3;
        //图片播放次数,0表示无限
        _talkingImageView.animationRepeatCount = 0;

        //设置动画图片数组
        _talkingImageView.animationImages = self.talkingImageArray;
        _talkingImageView.hidden = YES;
    }
    
    return _talkingImageView;
}


- (NSTimer *)timeTimer {
    if (_timeTimer == nil) {
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeTalkingAction:) userInfo:nil repeats:NO];
    }
    return _timeTimer;
}


@end
