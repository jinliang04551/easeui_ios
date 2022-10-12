//
//  YGGroupBanMemberCell.h
//  EaseIM
//
//  Created by liu001 on 2022/7/19.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YGGroupOperateMemberCell : BQCustomCell
@property (nonatomic, copy) void (^removeMemberBlock)(NSString *userId);

@end

NS_ASSUME_NONNULL_END
