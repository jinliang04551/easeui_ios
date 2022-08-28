//
//  BQEaseJoinGroupApplyModel.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//"userName": "101",
//"groupId": "189567183421441",
//"groupName": "群聊0811zqh",
//"state": "wait",
//"role": "customer",
//"inviter": "15901016199",
//"created": "2022-07-24T09:17:25.000+00:00",
//"modified": "2022-07-24T09:17:25.000+00:00",
//"inviterNickName": "岩小绪",
//"userNickName": "破界者101",
//"id": 1


@interface BQGroupApplyApprovalModel : NSObject
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *groupId;
@property (nonatomic, strong, readonly) NSString *groupName;

//fail是拒绝 success 是同意 wait是邀请加入的初始状态
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, strong, readonly) NSString *inviter;
@property (nonatomic, strong, readonly) NSString *approvalId;

@property (nonatomic, strong, readonly) NSString *inviterNickName;
@property (nonatomic, strong, readonly) NSString *userNickName;


- (instancetype)initWithDic:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
