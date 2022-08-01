//
//  EaseChatViewController+EaseCall.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/1.
//

#import "EaseChatViewController+EaseCall.h"

@implementation EaseChatViewController (EaseCall)

- (void)insertCallMsgFrom:(NSString *)from
                       to:(NSString *)to
                     text:(NSString *)text {
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
        
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{MSG_EXT_RECALL:@(YES), MSG_EXT_RECALLBY:[[EMClient sharedClient] currentUsername]}];
    message.chatType = (EMChatType)self.currentConversation.type;
    message.isRead = YES;
//    message.timestamp = model.message.timestamp;
//    message.localTime = model.message.localTime;
    [self.currentConversation insertMessage:message error:nil];
    
    EaseMessageModel *model = [[EaseMessageModel alloc] initWithEMMessage:message];
//    [self.dataArray addObject:model];
//    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataArray addObject:model];
        [self refreshTableView:YES];
    });


}

@end
