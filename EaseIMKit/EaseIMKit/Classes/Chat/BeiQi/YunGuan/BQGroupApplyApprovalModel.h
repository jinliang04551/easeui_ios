//
//  BQEaseJoinGroupApplyModel.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//created = "2022-07-28T08:43:17.000+00:00";
//groupId = 188301542752257;
//groupName = Lg2;
//id = 36;
//inviter = 13671151230;
//modified = "2022-07-28T09:22:41.000+00:00";
//role = customer;
//state = fail;
//userName = 13671151231;


@interface BQGroupApplyApprovalModel : NSObject
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *groupId;
@property (nonatomic, strong, readonly) NSString *groupName;

//fail是拒绝 success 是同意 wait是邀请加入的初始状态
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, strong, readonly) NSString *inviter;
@property (nonatomic, strong, readonly) NSString *approvalId;


- (instancetype)initWithDic:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
