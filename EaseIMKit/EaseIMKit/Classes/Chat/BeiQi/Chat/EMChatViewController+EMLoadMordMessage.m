//
//  EMChatViewController+EMLoadMordMessage.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/16.
//

#import "EMChatViewController+EMLoadMordMessage.h"

@implementation EMChatViewController (EMLoadMordMessage)

- (void)loadMoreMessageWithMsgId:(NSString *)msgId {
    __weak typeof(self) weakself = self;
    void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [weakself.chatController refreshTableViewWithData:aMessages isInsertBottom:NO isScrollBottom:NO];
        });
    };
    
    [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:self.conversation.conversationId conversationType:self.conversation.type startMessageId:msgId pageSize:20 completion:^(EMCursorResult *aResult, EMError *aError) {
        [self.conversation loadMessagesStartFromId:msgId count:10 searchDirection:EMMessageSearchDirectionUp completion:block];
     }];

}



@end
