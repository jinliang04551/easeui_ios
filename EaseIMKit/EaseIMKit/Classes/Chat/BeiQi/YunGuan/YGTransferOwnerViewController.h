//
//  YGTransferOwnerViewController.h
//  EaseIMKit
//
//  Created by liu001 on 2022/10/17.
//

#import <UIKit/UIKit.h>
#import "EasePublicHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface YGTransferOwnerViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) void (^transferOwnerBlock)(BOOL success);

@property (nonatomic, strong) NSString *navTitle;

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
