//
//  EaseChatViewController+EaseCall.h
//  EaseIMKit
//
//  Created by liu001 on 2022/8/1.
//

#import "EaseChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatViewController (EaseCall)
- (void)insertCallMsgFrom:(NSString *)from
                       to:(NSString *)to
                     text:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
