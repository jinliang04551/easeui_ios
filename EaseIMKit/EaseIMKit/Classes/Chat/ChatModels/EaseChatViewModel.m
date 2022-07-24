//
//  EaseChatViewModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/17.
//

#import "EaseChatViewModel.h"
#import "UIImage+EaseUI.h"
#import "UIColor+EaseUI.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"

@implementation EaseChatViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
  
    if (EaseIMKitManager.shared.isJiHuApp){
//        _chatViewBgColor = [UIColor colorWithHexString:@"#F2F2F2"];
//        _chatBarBgColor = [UIColor colorWithHexString:@"#F2F2F2"];

        //jh_setting
        _chatViewBgColor = [UIColor colorWithHexString:@"#171717"];
        _chatBarBgColor = [UIColor colorWithHexString:@"#252525"];

        _extFuncModel = [[EaseExtFuncModel alloc]init];
//        _msgTimeItemBgColor = [UIColor colorWithHexString:@"#F2F2F2"];
//        _msgTimeItemFontColor = [UIColor colorWithHexString:@"#ADADAD"];

        //jh_setting
        _msgTimeItemBgColor = [UIColor colorWithHexString:@"#171717"];
        _msgTimeItemFontColor = [UIColor colorWithHexString:@"#7F7F7F"];

        _receiveBubbleBgPicture = [UIImage easeUIImageNamed:@"msg_bg_recv"];
        _sendBubbleBgPicture = [UIImage easeUIImageNamed:@"msg_bg_send"];
        _bubbleBgEdgeInset = UIEdgeInsetsMake(8, 8, 8, 8);
//        _contentFontColor = [UIColor colorWithHexString:@"#7F7F7F"];
        //jh_setting
        _contentFontColor = [UIColor colorWithHexString:@"#B9B9B9"];
}else {
        _chatViewBgColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _chatBarBgColor = [UIColor colorWithHexString:@"#F5F5F5"];


        _extFuncModel = [[EaseExtFuncModel alloc]init];
        _msgTimeItemBgColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _msgTimeItemFontColor = [UIColor colorWithHexString:@"#A5A5A5"];

        _receiveBubbleBgPicture = [UIImage easeUIImageNamed:@"yg_msg_bg_recv"];
        _sendBubbleBgPicture = [UIImage easeUIImageNamed:@"yg_msg_bg_send"];
        _bubbleBgEdgeInset = UIEdgeInsetsMake(8, 8, 8, 8);
        _contentFontColor = [UIColor colorWithHexString:@"#171717"];
}
        
        _contentFontSize = 18.f;
        _inputBarStyle = EaseInputBarStyleAll;
        _avatarStyle = RoundedCorner;
        _avatarCornerRadius = 0;
    }
    return self;
}


- (void)setChatViewBgColor:(UIColor *)chatViewBgColor
{
    if (chatViewBgColor) {
        _chatViewBgColor = chatViewBgColor;
    }
}

- (void)setChatBarBgColor:(UIColor *)chatBarBgColor
{
    if (chatBarBgColor) {
        _chatBarBgColor = chatBarBgColor;
    }
}

- (void)setExtFuncModel:(EaseExtFuncModel *)extFuncModel
{
    if (extFuncModel) {
        _extFuncModel = extFuncModel;
    }
}

- (void)setMsgTimeItemBgColor:(UIColor *)msgTimeItemBgColor
{
    if (msgTimeItemBgColor) {
        _msgTimeItemBgColor = msgTimeItemBgColor;
    }
}

- (void)setMsgTimeItemFontColor:(UIColor *)msgTimeItemFontColor
{
    if (msgTimeItemFontColor) {
        _msgTimeItemFontColor = msgTimeItemFontColor;
    }
}

- (void)setReceiveBubbleBgPicture:(UIImage *)receiveBubbleBgPicture
{
    if (receiveBubbleBgPicture) {
        _receiveBubbleBgPicture = receiveBubbleBgPicture;
    }
}

- (void)setSendBubbleBgPicture:(UIImage *)sendBubbleBgPicture
{
    if (sendBubbleBgPicture) {
        _sendBubbleBgPicture = sendBubbleBgPicture;
    }
}

- (void)setBubbleBgEdgeInset:(UIEdgeInsets)bubbleBgEdgeInset
{
    _bubbleBgEdgeInset = bubbleBgEdgeInset;
}

- (void)setContentFontColor:(UIColor *)contentFontColor
{
    if (contentFontColor) {
        _contentFontColor = contentFontColor;
    }
}

- (void)setContentFontSize:(CGFloat)contentFontSize
{
    if (contentFontSize > 0) {
        _contentFontSize = contentFontSize;
    }
}

- (void)setInputBarStyle:(EaseInputBarStyle)inputBarStyle
{
    if (inputBarStyle >= 1 && inputBarStyle <= 5) {
        _inputBarStyle = inputBarStyle;
    }
}

- (void)setAvatarStyle:(EaseAvatarStyle)avatarStyle
{
    if (avatarStyle >= 1 && avatarStyle <= 3) {
        _avatarStyle = avatarStyle;
    }
}

- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius
{
    if (avatarCornerRadius > 0) {
        _avatarCornerRadius = avatarCornerRadius;
    }
}

@end
