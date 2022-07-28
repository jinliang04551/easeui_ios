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
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *inviter;
@property (nonatomic, strong) NSString *approvalId;

@end



@implementation BQGroupApplyApprovalModel
- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.userName = dic[@"userName"];
        self.groupId = dic[@"groupId"];
        self.state = dic[@"state"];
        self.role = dic[@"role"];
        self.inviter = dic[@"inviter"];
        self.approvalId = dic[@"id"];
    }
    return self;
}


@end
