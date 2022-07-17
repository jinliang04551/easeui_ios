//
//  BQGroupATMemberViewController.h
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseSearchViewController.h"
#import "EaseHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface BQGroupATMemberViewController : EaseSearchViewController
@property (nonatomic, copy) void (^selectedAtMemberBlock)(NSString *userId);

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
