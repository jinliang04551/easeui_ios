//
//  BQEaseJoinGroupApplyModel.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/28.
//

#import "BQGroupApplyApprovalModel.h"
@interface BQGroupApplyApprovalModel ()
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *inviter;
@property (nonatomic, strong) NSString *approvalId;

@end


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

@implementation BQGroupApplyApprovalModel
- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.userName = dic[@"userNickName"];
        self.groupId = dic[@"groupId"];
        self.groupName = dic[@"groupName"];
        self.state = dic[@"state"];
        self.role = dic[@"role"];
        self.inviter = dic[@"inviterNickName"];
        self.approvalId = dic[@"id"];
    }
    return self;
}


@end
