//
//  EMRemindManager.m
//  EaseIM
//
//  Created by 杜洁鹏 on 2019/8/21.
//  Copyright © 2019 杜洁鹏. All rights reserved.
//

#import "EMRemindManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>
#import <AudioToolbox/AudioToolbox.h>
#import "EaseIMKitOptions.h"
#import "EaseKitUtil.h"
#import "EaseHeaders.h"


// 提示音时间间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
SystemSoundID soundID = 1007;

@interface EMRemindManager () {
    
}

@property (nonatomic, strong) AVAudioPlayer *player;
@property (strong, nonatomic) NSDate *lastPlaySoundDate; // 最后一次提醒的时间
@end

@implementation EMRemindManager
+ (void)remindMessage:(EMChatMessage *)aMessage {
    [[EMRemindManager shared] remindMessage:aMessage];
}

+ (void)updateApplicationIconBadgeNumber:(NSInteger)aBadgeNumber {
    [[EMRemindManager shared] updateApplicationIconBadgeNumber:aBadgeNumber];
}

// 播放等待铃声
+ (void)playWattingSound {
    [[EMRemindManager shared] _playWattingSound];
}

// 播放铃声
+ (void)playRing:(BOOL)playVibration{
    [[EMRemindManager shared] _playRing:playVibration];
}

// 停止铃声
+ (void)stopSound {
    [[EMRemindManager shared] _stopSound];
}

// 振动
+ (void)playVibration {
    [[EMRemindManager shared] _playVibration:NULL];
}

#pragma - mark private
+ (EMRemindManager *)shared {
    static EMRemindManager *remindManager_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remindManager_ = [[EMRemindManager alloc] init];
    });
    
    return remindManager_;
}

- (void)updateApplicationIconBadgeNumber:(NSInteger)aBadgeNumber {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:aBadgeNumber];
    });
}

- (void)remindMessage:(EMChatMessage *)aMessage {
    if ([aMessage.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        //多设备收到自己消息不提醒震动
        return;
    }
        
    EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
    if (!options.isReceiveNewMsgNotice)
        return;
    // 小于最小间隔时间
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    
    // 是否是免打扰的消息(聊天室没有免打扰消息)
    BOOL unremindChat = [self _unremindChat:aMessage.conversationId];//单聊免打扰
    BOOL unremindGroup = [self _unremindGroup:aMessage.conversationId];//群组免打扰
    if (aMessage.chatType != EMChatTypeChatRoom) {
        if (unremindGroup && aMessage.chatType == EMChatTypeGroupChat) {
            return;
        }
        if (aMessage.chatType == EMChatTypeChat && unremindChat) {
            return;
        }
    }
        
    BOOL isBackground = NO;
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground) {
        isBackground = YES;
    }
    
    // App 是否在后台
    if (isBackground) {
        if (options.isAlertMsg){
        [self _localNotification:aMessage
                needInfo:EMClient.sharedClient.pushOptions.displayStyle != EMPushDisplayStyleSimpleBanner];
        }
    } else {
        if (options.isAlertMsg) {
            //仅仅震动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
//            AudioServicesPlaySystemSound(soundID);
        }
    }
}

// 本地通知 needInfo: 是否显示通知详情
- (void)_localNotification:(EMChatMessage *)message
                  needInfo:(BOOL)isNeed {
    NSString *alertTitle = @"";
    NSString *alertBody = @"";
    
    if (message.chatType == EMChatTypeChat) {
        alertTitle = [EaseKitUtil fetchUserDicWithUserId:message.from][EaseUserNicknameKey];
        alertBody = [EaseKitUtil getContentWithMsg:message];
    }
    
    if (message.chatType == EMChatTypeGroupChat) {
        EMGroup *group = [EMGroup groupWithId:message.conversationId];
        alertTitle = group.groupName;
        
        NSString *nickname = [EaseKitUtil fetchUserDicWithUserId:message.from][EaseUserNicknameKey];
        alertBody = [NSString stringWithFormat:@"%@: %@",nickname,[EaseKitUtil getContentWithMsg:message]];
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    BOOL playSound = NO;
    
    //前台不要铃声
    
    if (!self.lastPlaySoundDate || timeInterval >= kDefaultPlaySoundInterval) {
        self.lastPlaySoundDate = [NSDate date];
        playSound = YES;
    }

    //发送本地推送
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (playSound) {
            content.sound = [UNNotificationSound defaultSound];
        }
        content.body = alertBody;
        content.title = alertTitle;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.alertTitle = alertTitle;
        notification.alertAction = NSLocalizedString(@"open", nil);
        notification.timeZone = [NSTimeZone defaultTimeZone];
        
        EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
        playSound = options.isAlertMsg ? YES : NO;
        
        if (playSound) {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (BOOL)_unremindGroup:(NSString *)fromChatter {
    return [[[EMClient sharedClient].pushManager noPushGroups] containsObject:fromChatter];
}

- (BOOL)_unremindChat:(NSString *)conversationId {
    return [[[EMClient sharedClient].pushManager noPushUIds] containsObject:conversationId];
}

// 播放等待铃声
- (void)_playWattingSound {
    
    [self _stopSound];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                   error:nil];
    
    [session setActive:YES error:nil];
    
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"music" withExtension:@".mp3"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_player setNumberOfLoops:-1];
    [_player prepareToPlay];
    [_player play];
}

// 播放铃声
- (void)_playRing:(BOOL)playVibration {
    
    [self _stopSound];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
    
    [session setActive:YES error:nil];
    
    
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"music" withExtension:@".mp3"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_player setNumberOfLoops:-1];
    [_player prepareToPlay];
    [_player play];
    
    if (playVibration) {
        [self _playVibration:_systemAudioCallback];
    }
}

void _systemAudioCallback()
{
    if ([EMRemindManager shared].player) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)_playVibration:(AudioServicesSystemSoundCompletionProc)inCompletionRoutine {
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, inCompletionRoutine, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

// 停止铃声
- (void)_stopSound {
    if (_player || _player.isPlaying) {
        [_player stop];
    }
    
    _player = nil;
}

@end
