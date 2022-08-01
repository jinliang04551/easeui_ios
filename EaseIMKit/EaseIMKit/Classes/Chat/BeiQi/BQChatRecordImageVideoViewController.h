//
//  BQChatRecordImageVideoViewController.h
//  EaseIM
//
//  Created by liu001 on 2022/7/11.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasePublicHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BQChatRecordImageVideoViewControllererDelegate <NSObject>
@optional
- (void)didTapImageOrVideoMessage:(EMChatMessage *)message;

@end

@interface BQChatRecordImageVideoViewController : UIViewController
- (instancetype)initWithCoversationModel:(EMConversation *)conversation;

@property (nonatomic, assign) id<BQChatRecordImageVideoViewControllererDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
