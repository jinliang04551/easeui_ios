//
//  EMGroupChatViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMGroupChatViewController.h"
#import "EaseMessageModel.h"
#import "EMConversation+EaseUI.h"
#import "EaseAlertController.h"
#import "EaseAlertView.h"
#import "EaseTextView.h"
#import "EaseMessageCell.h"
#import "EaseChatViewController+EaseUI.h"
#import "BQGroupATMemberViewController.h"

@interface EMGroupChatViewController () <EMGroupManagerDelegate>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *conversationId;


@end

@implementation EMGroupChatViewController

- (instancetype)initGroupChatViewControllerWithCoversationid:(NSString *)conversationId
                                               chatViewModel:(EaseChatViewModel *)viewModel
{
    self.conversationId = conversationId;
    return [super initChatViewControllerWithCoversationid:conversationId
                       conversationType:EMConversationTypeGroupChat
                          chatViewModel:(EaseChatViewModel *)viewModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//@群成员
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"@"]) {
        [self _willInputAt:textView];
    }
    return YES;
}

//@群成员
- (void)_willInputAt:(UITextView *)aInputView
{
    do {
        NSString *text = [NSString stringWithFormat:@"%@%@",aInputView.text,@"@"];
        EMGroup *group = [EMGroup groupWithId:self.conversationId];
        if (!group) {
            break;
        }
        [self.view endEditing:YES];
        //选择 @ 某群成员
        BQGroupATMemberViewController *controller = [[BQGroupATMemberViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:controller animated:NO];
        controller.selectedAtMemberBlock = ^(NSString * _Nonnull userId) {
            NSString *newStr = [NSString stringWithFormat:@"%@%@ ", text, userId];
            [aInputView setText:newStr];
            aInputView.selectedRange = NSMakeRange(newStr.length, 0);
            if ([text isEqualToString:@"@"]) {
                [self clearTextViewPlaceHolder];
            }
            
            [aInputView becomeFirstResponder];
        };
        
    } while (0);
}


#pragma mark - EaseMessageCellDelegate

//阅读回执详情
- (void)messageReadReceiptDetil:(EaseMessageCell *)aCell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupMessageReadReceiptDetail:groupId:)]) {
        [self.delegate groupMessageReadReceiptDetail:aCell.model.message groupId:self.currentConversation.conversationId];
    }
}

#pragma mark - ACtion

- (void)sendReadReceipt:(EMChatMessage *)msg
{
    if (msg.isNeedGroupAck && !msg.isReadAcked) {
        [[EMClient sharedClient].chatManager sendGroupMessageReadAck:msg.messageId toGroup:msg.conversationId content:@"123" completion:^(EMError *error) {
            if (error) {
               
            }
        }];
    }
}

#pragma mark - EMChatManagerDelegate

//收到群消息已读回执
- (void)groupMessageDidRead:(EMChatMessage *)aMessage groupAcks:(NSArray *)aGroupAcks
{
    EaseMessageModel *msgModel;
    EMGroupMessageAck *msgAck = aGroupAcks[0];
    for (int i=0; i<[self.dataArray count]; i++) {
        if([self.dataArray[i] isKindOfClass:[EaseMessageModel class]]){
            msgModel = (EaseMessageModel *)self.dataArray[i];
        }else{
            continue;
        }
        if([msgModel.message.messageId isEqualToString:msgAck.messageId]){
            [self.dataArray setObject:msgModel atIndexedSubscript:i];
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself refreshTableView:YES];
            });
            break;
        }
    }
}

#pragma mark - EMGroupManagerDelegate

//有用户加入群组
- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
}

@end
