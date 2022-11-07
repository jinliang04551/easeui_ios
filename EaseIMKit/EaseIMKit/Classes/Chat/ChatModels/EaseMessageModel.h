//
//  EaseMessageModel.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasePublicHeaders.h"
#import "EaseUserDelegate.h"

typedef NS_ENUM(NSInteger, EMMessageType) {
    EMMessageTypeText = 1,
    EMMessageTypeImage,
    EMMessageTypeVideo,
    EMMessageTypeLocation,
    EMMessageTypeVoice,
    EMMessageTypeFile,
    EMMessageTypeCmd,
    EMMessageTypeCustom,
    EMMessageTypeExtGif,
    EMMessageTypeExtRecall,
    EMMessageTypeExtCall,
    EMMessageTypeExtNewFriend,
    EMMessageTypePictMixText,
    EMMessageTypeExtAddGroup,
    EMMessageTypeExtCallState,
    EMMessageTypeExtGroupInsertHint
};


NS_ASSUME_NONNULL_BEGIN
@class EaseMessageCell;
@interface EaseMessageModel : NSObject

@property (nonatomic) id<EaseUserDelegate> userDataDelegate;

@property (nonatomic, weak) EaseMessageCell *weakMessageCell;

@property (nonatomic, strong) EMChatMessage *message;

@property (nonatomic) EMMessageDirection direction;

@property (nonatomic) EMMessageType type;

@property (nonatomic) BOOL isPlaying;

//是否选中
@property (nonatomic) BOOL isSelected;


- (instancetype)initWithEMMessage:(EMChatMessage *)aMsg;

@end

NS_ASSUME_NONNULL_END
