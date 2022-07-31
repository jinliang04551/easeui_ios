//
//  EaseChatRecordImageVideoViewController.h
//  Pods
//
//  Created by liu001 on 2022/7/16.
//

#import <UIKit/UIKit.h>
#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EaseChatRecordImageVideoViewControllerDelegate <NSObject>
@optional
- (void)didTapImageOrVideoMessage:(EMChatMessage *)message;

@end


@interface EaseChatRecordImageVideoViewController : UIViewController
- (instancetype)initWithCoversationModel:(EMConversation *)conversation;

@property (nonatomic, assign) id<EaseChatRecordImageVideoViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
