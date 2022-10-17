//
//  YGGroupManageViewController.h
//  EaseIMKit
//
//  Created by liu001 on 2022/10/12.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"
#import "EasePublicHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface YGGroupManageViewController : EMRefreshViewController
@property (nonatomic, copy) void (^transferOwnerBlock)(BOOL success);

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
