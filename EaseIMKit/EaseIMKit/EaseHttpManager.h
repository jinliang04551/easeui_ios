//
//  EMHttpRequest.h
//
//  Created by zhangchong on 2021/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseHttpManager : NSObject

+ (instancetype)sharedManager;

- (void)registerToApperServer:(NSString *)uName
                          pwd:(NSString *)pwd
                   completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)loginToApperServer:(NSString *)uName
                       pwd:(NSString *)pwd
                completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)logoutWithCompletion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;


- (void)createGroupWithGroupName:(NSString *)groupName
                  groupInterduce:(NSString *)groupInterduce
                 customerUserIds:(NSArray *)customerUserIds
                   waiterUserIds:(NSArray *)waiterUserIds
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)fetchGroupApplyListWithPageNumber:(NSInteger )pageNumber
                                 pageSize:(NSInteger )pageSize
                               completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)approvalGroupWithGroupId:(NSString *)groupId
                        username:(NSString *)username
                            role:(NSString *)role
                          option:(NSString *)option
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)inviteGroupMemberWithGroupId:(NSString *)groupId
                     customerUserIds:(NSArray *)customerUserIds
                       waiterUserIds:(NSArray *)waiterUserIds
                          completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)searchGroupMemberWithUsername:(NSString *)username
                           completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;


- (void)searchCustomOrderWithUserId:(NSString *)userId
                          orderType:(NSString *)orderType
                         completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)fetchYunGuanNoteWithGroupId:(NSString *)groupId
                         completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)editServeNoteWithGroupId:(NSString *)groupId
                            note:(NSString *)note
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)editGroupNameWithGroupId:(NSString *)groupId
                       groupname:(NSString *)groupname
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

- (void)searchGroupListWithAid:(NSString *)aid
                        mobile:(NSString *)mobile
                       orderId:(NSString *)orderId
                           vin:(NSString *)vin
                     groupname:(NSString *)groupName
                    completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;


#pragma mark 极狐接口
- (void)fetchExclusiveServerGroupListWithCompletion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock;

@end

NS_ASSUME_NONNULL_END
