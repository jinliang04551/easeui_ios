//
//  EaseIMHelper.h
//  EaseIM
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <HyphenateChat/HyphenateChat.h>

@class EMChatViewController;
@interface EaseIMHelper : NSObject<EMMultiDevicesDelegate, EMContactManagerDelegate, EMGroupManagerDelegate, EMChatManagerDelegate, EMClientDelegate>

@property (nonatomic, strong) EMChatViewController *currentChatVC;

+ (instancetype)shareHelper;

- (void)insertMsgWithCMDMessage:(EMChatMessage  *)cmdMessage;

- (void)sendNoDisturbCMDMessageWithExt:(NSDictionary *)ext;

@end