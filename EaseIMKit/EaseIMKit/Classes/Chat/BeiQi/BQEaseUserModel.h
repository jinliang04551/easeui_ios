//
//  BQEaseUserModel.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//activated = 1;
//avatar = "<null>";
//created = "2022-07-27T03:06:54.000+00:00";
//modified = "2022-07-27T03:06:54.000+00:00";
//nickName = "<null>";
//password = "<null>";
//phone = 13671151230;
//type = user;
//userId = "2ae7d400-0d59-11ed-b3c8-b7cc530dab79";
//userName = 13671151230;


@interface BQEaseUserModel : NSObject

@property (nonatomic, strong, readonly) NSString *avatar;
@property (nonatomic, strong, readonly) NSString *nickName;
@property (nonatomic, strong, readonly) NSString *phone;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *displayName;


- (instancetype)initWithDic:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
