//
//  EaseIMKitMessageHelper.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseIMKitMessageHelper : NSObject
//收到申请加入群组
@property (nonatomic, assign, readonly) BOOL  hasJoinGroupApply;

@property (nonatomic, strong, readonly) NSMutableArray *joinedGroupIdArray;

+ (instancetype)shareMessageHelper;

- (void)clearMemeryCache;


@end

NS_ASSUME_NONNULL_END
