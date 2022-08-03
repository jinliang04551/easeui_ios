//
//  YGSearchGroup.h
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@interface YGSearchGroupModel : NSObject
@property (nonatomic, strong, readonly) NSString *groupName;
@property (nonatomic, strong, readonly) NSString *groupId;
@property (nonatomic, strong, readonly) NSString *bussinessRemark;
@property (nonatomic, strong, readonly) NSString *sysDesc;
@property (nonatomic, assign, readonly) BOOL isJoined;


- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
