//
//  YGSearchGroup.m
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGSearchGroupModel.h"
#import "EaseHeaders.h"

@interface YGSearchGroupModel ()
@property (nonatomic, strong) NSString *aid;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *bussinessRemark;
@property (nonatomic, strong) NSString *sysDesc;
@property (nonatomic, assign) BOOL isJoined;

@end

@implementation YGSearchGroupModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.groupName = dic[@"groupName"];
        self.groupId = dic[@"groupId"];
        self.isJoined = NO;
        
        if ([EaseIMKitMessageHelper shareMessageHelper].joinedGroupIdArray.count > 0) {
            if ([[EaseIMKitMessageHelper shareMessageHelper].joinedGroupIdArray containsObject:self.groupId]) {
                self.isJoined = YES;
            }
        }
        
        
    }
    return self;
}


@end
