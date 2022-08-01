//
//  EMConversationsViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshViewController.h"
NS_ASSUME_NONNULL_BEGIN

//会话列表入口类型
typedef NS_ENUM(NSUInteger, EMConversationEnterType) {
    EMConversationEnterTypeExclusiveGroup,
    EMConversationEnterTypeMyChat,
};

@interface EMConversationsViewController : EMRefreshViewController

@property (nonatomic, copy) void (^deleteConversationCompletion)(BOOL isDelete);


- (instancetype)initWithEnterType:(EMConversationEnterType)enterType;

@end

NS_ASSUME_NONNULL_END
