//
//  EMHttpRequest.m
//
//  Created by zhangchong on 2021/8/23.
//

#import "EaseHttpRequest.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EaseHeaders.h"

#define kServerHost @"http://182.92.236.214:12005"
#define kLoginURL @"/v2/gov/arcfox/login"
#define kLogoutURL @"/v2/gov/arcfox/transport"
#define kCreateGroupURL @"/v2/group/createGroup"
#define kGroupApplyListURL @"/v2/group/chatgroups/users/state"
#define kGroupApplyApprovalURL @"/v2/group/chatgroups/users"
#define kInviteGroupMemberURL @"/v2/group/chatgroups"
#define kSearchGroupMemberURL @"/v1/gov/arcfox/user"
#define kSearchCustomOrderURL @"/v4/gov/arcfox/transport"


@interface EaseHttpRequest() <NSURLSessionDelegate>
@property (readonly, nonatomic, strong) NSURLSession *session;
@end
@implementation EaseHttpRequest

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static EaseHttpRequest *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EaseHttpRequest alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 120;
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)registerToApperServer:(NSString *)uName
                          pwd:(NSString *)pwd
                   completion:(void (^)(NSInteger statusCode, NSString *aUsername))aCompletionBlock
{
    NSURL *url = [NSURL URLWithString:@"http://hk.test.easemob.com/app/chat/user/register"];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    request.allHTTPHeaderFields = headerDict;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:uName forKey:@"userAccount"];
    [dict setObject:pwd forKey:@"userPassword"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


- (void)loginToApperServer:(NSString *)uName
                       pwd:(NSString *)pwd
                completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kServerHost,kLoginURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    request.allHTTPHeaderFields = headerDict;

    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:uName forKey:@"phone"];
    [dict setObject:pwd forKey:@"password"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}

- (void)logoutWithCompletion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{
    
//URL: /v2/gov/arcfox/transport/15811252011/logout
//Method: GET
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/logout",kServerHost,kLogoutURL,[EMClient sharedClient].currentUsername]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];

    request.allHTTPHeaderFields = headerDict;

    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


- (void)createGroupWithGroupName:(NSString *)groupName
                  groupInterduce:(NSString *)groupInterduce
                 customerUserIds:(NSArray *)customerUserIds
                   waiterUserIds:(NSArray *)waiterUserIds
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kServerHost,kCreateGroupURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];

    request.allHTTPHeaderFields = headerDict;

    //"isPublic": false,//写死
    //"allowinvites": true,//写死
    //"groupname": "1",//群名称
    //"owner": "15811252011",//群主
    //"customerAids": [
    //"fox-016"
    //],//客户
    //"waiterAids": [
    //"15901016489",
    //"0718003"
    //],//服务人员
    //"action": true//写死

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:@(NO) forKey:@"isPublic"];
    [dict setObject:@(YES) forKey:@"allowinvites"];
    [dict setObject:groupName forKey:@"groupname"];
    [dict setObject:[EMClient sharedClient].currentUsername forKey:@"owner"];
    [dict setObject:customerUserIds forKey:@"customerAids"];
    [dict setObject:waiterUserIds forKey:@"waiterAids"];
    [dict setObject:@(YES) forKey:@"action"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


//群申请列表
//URL : /v2/group/chatgroups/users/state
//Method: POST
//PostBody:
//{
//"page": 0,
//"size": 10,
//"username":"223834",// 登录人的账号
//}

- (void)fetchGroupApplyListWithPageNumber:(NSInteger )pageNumber
                                 pageSize:(NSInteger )pageSize
                               completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kServerHost,kGroupApplyListURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:@(pageNumber) forKey:@"page"];
    [dict setObject:@(pageSize) forKey:@"size"];
    [dict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}

//群审批
//URL: /v2/group/chatgroups/users/${username}/state  username为登录账号
//Method: POST
//PostBody:
//{
//"groupId": "187794528993281",
//"username": "0718003",
//"role": "customer",
//"option": "success" //fail是拒绝 success 是同意 wait是邀请加入的初始状态
//}

- (void)approvalGroupWithGroupId:(NSString *)groupId
                        username:(NSString *)username
                            role:(NSString *)role
                          option:(NSString *)option
                        completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/state",kServerHost,kGroupApplyApprovalURL,[EMClient sharedClient].currentUsername]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    //"groupId": "187794528993281",
    //"username": "0718003",
    //"role": "customer",
    //"option": "success" //fail是拒绝 success 是同意 wait是邀请加入的初始状态
    //}
    
    [dict setObject:groupId forKey:@"groupId"];
    [dict setObject:username forKey:@"username"];
    [dict setObject:role forKey:@"role"];
    [dict setObject:option forKey:@"option"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


//邀请群成员
//URL:/v2/group/chatgroups/{groupid}/users/inviter/{inviter}
// inviter邀请人   群主直接拉进群，成员邀请进入审批列表
//Method:post PO
// --data-raw '{"customerUser":["0718003","17637515829"],"waiterUser":["15901016489","17637515819"]}' \

- (void)inviteGroupMemberWithGroupId:(NSString *)groupId
                     customerUserIds:(NSArray *)customerUserIds
                       waiterUserIds:(NSArray *)waiterUserIds
                          completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/users/inviter/%@",kServerHost,kInviteGroupMemberURL,groupId,[EMClient sharedClient].currentUsername]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
    [dict setObject:customerUserIds forKey:@"customerUser"];
    [dict setObject:waiterUserIds forKey:@"waiterUser"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


//创建群—搜索人员列表
//URL:/v1/gov/arcfox/user/{username}
// URL上的username 是登录的账号 请求体中的username是搜索的值

- (void)searchGroupMemberWithUsername:(NSString *)username
                           completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",kServerHost,kSearchGroupMemberURL,[EMClient sharedClient].currentUsername]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
    [dict setObject:username forKey:@"username"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


//查询客户订单列表信息
//URL: /v4/gov/arcfox/transport/{username}/getOrders

// "aid":"222600",
//    "orderType":"MAIN",
//    "token":"ad8s8d9adhka"

- (void)searchCustomOrderWithUserId:(NSString *)userId
                          orderType:(NSString *)orderType
                         completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/getOrders",kServerHost,kSearchCustomOrderURL,[EMClient sharedClient].currentUsername]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
    // "aid":"222600",
    //    "orderType":"MAIN",
    //    "token":"ad8s8d9adhka"

    [dict setObject:userId forKey:@"aid"];
    [dict setObject:orderType forKey:@"orderType"];
    [dict setObject:token forKey:@"token"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}



#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){//服务器信任证书
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];//服务器信任证书
            if(completionHandler)
                completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
}




@end