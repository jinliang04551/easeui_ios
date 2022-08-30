//
//  BQEaseUserModel.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/27.
//

#import "BQEaseUserModel.h"

@interface BQEaseUserModel ()
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;


@end

@implementation BQEaseUserModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
//        NSNull
        self.avatar = dic[@"avatar"];
        self.nickName = dic[@"nickName"];
        
        self.phone = dic[@"phone"];
        self.type = dic[@"type"];
        self.userId = dic[@"userId"];
        self.userName = dic[@"userName"];

    }
    return self;
}

- (NSString *)displayName {
    
    return self.userName;
}


@end
