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

@property (nonatomic, strong) NSString *inviterNickName;
@property (nonatomic, strong) NSString *userNickName;

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
        self.userName = dic[@"userName"];
        self.groupId = dic[@"groupId"];
        self.groupName = dic[@"groupName"];
        self.state = dic[@"state"];
        self.role = dic[@"role"];
        self.inviter = dic[@"inviter"];
        self.approvalId = dic[@"id"];
        
        id inviterNickName = dic[@"inviterNickName"];
        if ([inviterNickName isKindOfClass:[NSNull null]]) {
            self.inviterNickName = self.inviter;
        }else {
            NSString *tNickname = (NSString *)inviterNickName;
            if (tNickname.length > 0) {
                self.inviterNickName = tNickname;
            }else {
                self.inviterNickName = self.inviter;
            }
        }
        
        
        id userNickName = dic[@"userNickName"];

        if ([userNickName isKindOfClass:[NSNull null]]) {
            self.userNickName = self.userName;
        }else {
            NSString *tname = (NSString *)inviterNickName;
            if (tname.length > 0) {
                self.userNickName = tname;
            }else {
                self.userNickName = self.userName;
            }
        }
        
    }
    return self;
}


@end
