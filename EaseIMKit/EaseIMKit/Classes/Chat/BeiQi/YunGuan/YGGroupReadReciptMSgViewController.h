//
//  YGGroupReadReciptMSgViewController.h
//  EaseIM
//
//  Created by liu001 on 2022/7/25.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@interface YGGroupReadReciptMSgViewController : UIViewController
- (instancetype)initWithMessage:(EMChatMessage *)message
                        groupId:(NSString *)groupId;

@end

NS_ASSUME_NONNULL_END
