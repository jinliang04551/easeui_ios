//
//  EMUserDataModel.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/12/3.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMUserDataModel.h"
#import "EaseHeaders.h"

@implementation EMUserDataModel

- (instancetype)initWithEaseId:(NSString *)easeId
{
    if (self = [super init]) {
        _easeId = easeId;
        _defaultAvatar = [UIImage easeUIImageNamed:@"jh_user_icon"];
        _showName = easeId;
    }
    return self;
}

- (NSString *)showName {
    return _easeId;
}

@end
