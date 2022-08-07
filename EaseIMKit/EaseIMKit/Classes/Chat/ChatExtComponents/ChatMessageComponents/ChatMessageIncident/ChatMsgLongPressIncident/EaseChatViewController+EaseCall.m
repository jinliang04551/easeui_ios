//
//  EaseChatViewController+EaseCall.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/1.
//

#import "EaseChatViewController+EaseCall.h"

@implementation EaseChatViewController (EaseCall)

- (void)insertMsgWithCMDMessage:(EMChatMessage  *)cmdMessage {
    
    NSString *callState = cmdMessage.ext[MutiCallCallState];
    NSString *callUser = cmdMessage.ext[MutiCallCallUser];

    NSString *msgText = @"";
    if ([callState isEqualToString:MutiCallCreateCall]) {
        msgText = [NSString stringWithFormat:@"%@ 发起了语音通话",callUser];
    }else {
        msgText = @"语音通话已经结束";
    }
    NSLog(@"%s msgText:%@",__func__,msgText);
       
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:msgText];
        
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:cmdMessage.conversationId from:cmdMessage.from to:cmdMessage.to body:body ext:cmdMessage.ext];
    
    message.chatType = (EMChatType)self.currentConversation.type;
    message.isRead = YES;
    message.timestamp = message.timestamp;
    message.localTime = message.localTime;
    [self.currentConversation insertMessage:message error:nil];
    
    EaseMessageModel *model = [[EaseMessageModel alloc] initWithEMMessage:message];
    model.type = EMMessageTypeExtCallState;

//    [self.dataArray addObject:model];
//    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataArray addObject:model];
        [self refreshTableView:YES];
    });
}


@end
