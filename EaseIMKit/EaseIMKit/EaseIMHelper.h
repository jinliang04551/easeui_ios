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


//push 出来的会话ID数组
@property (nonatomic, strong) NSMutableArray<NSString *> *pushedConvIdArray;

//当前会话Id
@property (nonatomic, strong) NSString *currentConversationId;

//群组@成员列表
@property (nonatomic, strong) NSMutableArray *grpupAtArray;
@property (nonatomic, assign) BOOL isAtAll;


+ (instancetype)shareHelper;

- (void)insertMsgWithCMDMessage:(EMChatMessage  *)cmdMessage;

- (void)sendNoDisturbCMDMessageWithExt:(NSDictionary *)ext;

- (void)clearGroupAtInfo;

@end
