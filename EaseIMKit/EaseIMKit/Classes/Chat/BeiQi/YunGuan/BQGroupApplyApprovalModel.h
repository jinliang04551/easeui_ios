//
//  BQEaseJoinGroupApplyModel.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//"userName": "0718003",
//            "groupId": "187794528993281",
//            "state": "wait",
//            "role": "customer",
//            "inviter": "15811252011",
//            "created": "2022-07-25T01:34:17.000+00:00",
//            "modified": "2022-07-25T01:34:17.000+00:00",
//            "id": 11

@interface BQGroupApplyApprovalModel : NSObject
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *groupId;
//fail是拒绝 success 是同意 wait是邀请加入的初始状态
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, strong, readonly) NSString *inviter;
@property (nonatomic, strong, readonly) NSString *approvalId;


- (instancetype)initWithDic:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
