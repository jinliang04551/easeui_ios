//
//  EaseCallBaseViewController.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallBaseViewController.h"
#import "EaseCallManager+Private.h"
#import <Masonry/Masonry.h>
#import "UIImage+Ext.h"
#import "UIColor+EaseCall.h"
#import "EaseDefines.h"
#import "EaseHeaders.h"
#import "EaseCallFloatingView.h"

#define kButtonItemPadding 52.0
#define kButtonItemSize 64.0

@interface EaseCallBaseViewController ()

@end

@implementation EaseCallBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHexString:@"#171717"];
    
    
    [self setubSubViews];
    
    self.speakerButton.selected = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersInfoUpdated) name:@"EaseCallUserUpdated" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)usersInfoUpdated
{
    
}

- (void)setubSubViews
{
    
    [self.view addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11,*)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }else {
            make.edges.equalTo(self.view);
         }
       
    }];
    
   
    [self.contentView addSubview:self.miniButton];
    [self.contentView addSubview:self.hangupButton];
    [self.contentView addSubview:self.answerButton];
    [self.contentView addSubview:self.switchCameraButton];
    [self.contentView addSubview:self.microphoneButton];
    [self.contentView addSubview:self.speakerButton];
    [self.contentView addSubview:self.enableCameraButton];

    
    [self.miniButton setTintColor:[UIColor whiteColor]];
    [self.miniButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.equalTo(@10);
        make.width.height.equalTo(@40);
    }];
    
    [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = 26.0 + EaseIMKit_BottomSafeHeight;
        make.bottom.equalTo(self.contentView).offset(-offset);
        make.left.equalTo(self.contentView).offset(40.0);
        make.width.height.equalTo(@(kButtonItemSize));
    }];
    
    
    [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.hangupButton);
        make.right.equalTo(self.contentView).offset(-40.0);
        make.width.height.equalTo(@(kButtonItemSize));
    }];
    
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.hangupButton);
        make.width.height.mas_equalTo(kButtonItemSize);
        make.left.equalTo(self.hangupButton.mas_right).offset(20);

    }];
    
  
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
        make.centerX.equalTo(self.contentView);
        make.width.height.equalTo(@(kButtonItemSize));
    }];

    
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.speakerButton.mas_left).offset(-kButtonItemPadding);
        make.centerY.equalTo(self.speakerButton);
        make.width.height.equalTo(@(kButtonItemSize));
    }];
    self.microphoneButton.selected = NO;
    
    
    [self.enableCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.speakerButton.mas_right).offset(kButtonItemPadding);
        make.centerY.equalTo(self.speakerButton);
        make.width.height.equalTo(@(kButtonItemSize));
    }];
    
    [self.enableCameraButton setEnabled:NO];
    [self.switchCameraButton setEnabled:NO];
    [self.microphoneButton setEnabled:NO];
    _timeLabel = nil;
    
    self.hangupLabel = [[UILabel alloc] init];
    self.hangupLabel.font = [UIFont systemFontOfSize:11];
    self.hangupLabel.textColor = [UIColor whiteColor];
    self.hangupLabel.textAlignment = NSTextAlignmentCenter;
    self.hangupLabel.text = EaseLocalizableString(@"Huangup",nil);
    self.hangupLabel.hidden = YES;
    [self.contentView addSubview:self.hangupLabel];
    [self.hangupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hangupButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.hangupButton);
    }];
    
    self.acceptLabel = [[UILabel alloc] init];
    self.acceptLabel.font = [UIFont systemFontOfSize:11];
    self.acceptLabel.textColor = [UIColor whiteColor];
    self.acceptLabel.textAlignment = NSTextAlignmentCenter;
    self.acceptLabel.text = EaseLocalizableString(@"Answer",nil);
    self.acceptLabel.hidden = YES;
    [self.contentView addSubview:self.acceptLabel];
    [self.acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.answerButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.answerButton);
    }];
    
    self.microphoneLabel = [[UILabel alloc] init];
    self.microphoneLabel.font = [UIFont systemFontOfSize:11];
    self.microphoneLabel.textColor = [UIColor whiteColor];
    self.microphoneLabel.textAlignment = NSTextAlignmentCenter;
    self.microphoneLabel.text = EaseLocalizableString(@"Mute",nil);
    [self.contentView addSubview:self.microphoneLabel];
    [self.microphoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.microphoneButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.microphoneButton);
    }];
    
    self.speakerLabel = [[UILabel alloc] init];
    self.speakerLabel.font = [UIFont systemFontOfSize:11];
    self.speakerLabel.textColor = [UIColor whiteColor];
    self.speakerLabel.textAlignment = NSTextAlignmentCenter;
    self.speakerLabel.text = EaseLocalizableString(@"Hands-free",nil);
    [self.contentView addSubview:self.speakerLabel];
    [self.speakerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.speakerButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.speakerButton);
    }];
    
    self.enableCameraLabel = [[UILabel alloc] init];
    self.enableCameraLabel.font = [UIFont systemFontOfSize:11];
    self.enableCameraLabel.textColor = [UIColor whiteColor];
    self.enableCameraLabel.textAlignment = NSTextAlignmentCenter;
    self.enableCameraLabel.text = EaseLocalizableString(@"Camera",nil);
    [self.contentView addSubview:self.enableCameraLabel];
    [self.enableCameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.enableCameraButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.enableCameraButton);
    }];
    
    self.switchCameraLabel = [[UILabel alloc] init];
    self.switchCameraLabel.font = [UIFont systemFontOfSize:11];
    self.switchCameraLabel.textColor = [UIColor whiteColor];
    self.switchCameraLabel.textAlignment = NSTextAlignmentCenter;
    self.switchCameraLabel.text = EaseLocalizableString(@"SwitchCamera",nil);
    self.switchCameraLabel.hidden = YES;
    [self.contentView addSubview:self.switchCameraLabel];
    [self.switchCameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.switchCameraButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.switchCameraButton);
    }];
}

- (UIView*)contentView
{
    if(!_contentView)
        _contentView = [[UIView alloc] init];
    return _contentView;
}

- (void)answerAction
{
    [[EaseCallManager sharedManager] acceptAction];
}

- (void)hangupAction
{
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    [[EaseCallManager sharedManager] hangupAction];
}

- (void)switchCameraAction
{
    self.switchCameraButton.selected = !self.switchCameraButton.isSelected;
    [[EaseCallManager sharedManager] switchCameraAction];
}

- (void)speakerAction
{
    self.speakerButton.selected = !self.speakerButton.isSelected;
    [[EaseCallManager sharedManager] speakeOut:self.speakerButton.selected];
}

- (void)muteAction
{
    self.microphoneButton.selected = !self.microphoneButton.isSelected;
    [[EaseCallManager sharedManager] muteAudio:self.microphoneButton.selected];
}

- (void)enableVideoAction
{
    self.enableCameraButton.selected = !self.enableCameraButton.isSelected;
    [[EaseCallManager sharedManager] enableVideo:self.enableCameraButton.selected];
}

- (void)miniAction
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.floatingView.frame = CGRectMake(self.contentView.bounds.size.width - 100, 80, 88.0, 88.0);
    [keyWindow addSubview:self.floatingView];
    [keyWindow bringSubviewToFront:self.floatingView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (EaseCallStreamView*)floatingView
{
    if(!_floatingView)
    {
        _floatingView = [[EaseCallStreamView alloc] init];
        _floatingView.backgroundColor = [UIColor grayColor];
//        _floatingView.backgroundColor = [UIColor colorWithHexString:@"#171717"];
        _floatingView.bgView.image = [UIImage imageNamedFromBundle:@"floating_voice"];
        _floatingView.nameLabel.textAlignment = NSTextAlignmentCenter;

        [_floatingView.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@55);
        }];
    }
    return _floatingView;
}

//- (EaseCallFloatingView *)floatingView {
//    if (_floatingView == nil) {
//        _floatingView = [[EaseCallFloatingView alloc] init];
//    }
//    return _floatingView;
//}

#pragma mark - timer

- (void)startTimer
{
    if(!_timeLabel) {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:14.0];
        self.timeLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.text = @"00:00";
        [self.contentView addSubview:self.timeLabel];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.speakerButton.mas_top).offset(-18.0);
            make.centerX.equalTo(self.contentView);
            make.width.equalTo(@100);
        }];
        
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
    }
    
}


- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int m = (_timeLength) / 60;
    int s = _timeLength - m * 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"通话时长 %02d:%02d", m, s];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark getter and setter
-(UIButton *)miniButton {
    if (_miniButton == nil) {
        _miniButton = [[UIButton alloc] init];
        _miniButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_miniButton setImage:[UIImage imageNamedFromBundle:@"mini"] forState:UIControlStateNormal];
        [_miniButton addTarget:self action:@selector(miniAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _miniButton;
}

- (UIButton *)hangupButton {
    if (_hangupButton == nil) {
        _hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _hangupButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_hangupButton setImage:[UIImage imageNamedFromBundle:@"hangup"] forState:UIControlStateNormal];
        [_hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _hangupButton;
}


- (UIButton *)answerButton {
    if (_answerButton == nil) {
        _answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _answerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_answerButton setImage:[UIImage imageNamedFromBundle:@"answer"] forState:UIControlStateNormal];
        [_answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerButton;
}


- (UIButton *)switchCameraButton {
    if (_switchCameraButton == nil) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraButton setImage:[UIImage imageNamedFromBundle:@"switchCamera"] forState:UIControlStateNormal];
        [_switchCameraButton addTarget:self action:@selector(switchCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

- (UIButton *)microphoneButton {
    if (_microphoneButton == nil) {
        _microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_microphoneButton setImage:[UIImage imageNamedFromBundle:@"microphone_disable"] forState:UIControlStateNormal];
        [_microphoneButton setImage:[UIImage imageNamedFromBundle:@"microphone_enable"] forState:UIControlStateSelected];
        [_microphoneButton addTarget:self action:@selector(muteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _microphoneButton;
}

- (UIButton *)speakerButton {
    if (_speakerButton == nil) {
        _speakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speakerButton setImage:[UIImage imageNamedFromBundle:@"speaker_disable"] forState:UIControlStateNormal];
        [_speakerButton setImage:[UIImage imageNamedFromBundle:@"speaker_enable"] forState:UIControlStateSelected];
        [_speakerButton addTarget:self action:@selector(speakerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerButton;
}

- (UIButton *)enableCameraButton {
    if (_enableCameraButton == nil) {
        _enableCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_enableCameraButton setImage:[UIImage imageNamedFromBundle:@"video_disable"] forState:UIControlStateNormal];
        [_enableCameraButton setImage:[UIImage imageNamedFromBundle:@"video_enable"] forState:UIControlStateSelected];
        [_enableCameraButton addTarget:self action:@selector(enableVideoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enableCameraButton;
}

@end

#undef kButtonItemPadding
#undef kButtonItemSize
