//  EMHttpRequest.m
//
//  Created by zhangchong on 2021/8/23.
//

#import "EaseHttpManager.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EaseHeaders.h"
#import "EaseIMKitOptions.h"
#import "EaseIMKitManager.h"

#define kServerHost @"http://182.92.236.214:12005"

/*
 ======================
 极狐接口
 ======================
 */

//获取专属服务群列表接口
#define kExclusiveServerGroupListURL @"/v2/group/chatgroups/users"
//查询客户订单列表信息
//URL: /v4/gov/arcfox/transport/{username}/getOrders
#define kSearchCustomOrderURL @"/v4/gov/arcfox/transport"
#define kJiHuSearchGroupMemberURL @"/v1/gov/arcfox/user"
//声网音视频生成token接口
#define kEaseCallGenerateTokenJiHuURL @"/v1/rtc/token"
//声网音视频获取一个channelName下有哪些uid接口
#define kEaseCallGetChannalUidsJiHuURL @"/v1/rtc/channle"


/*
 ======================
 运管接口
 ======================
 */
#define kLoginURL @"/v2/gov/arcfox/login"
#define kLogoutURL @"/v2/gov/arcfox/transport"
//#define kCreateGroupURL @"/v2/group/createGroup"
#define kCreateGroupURL @"/v4/users"

#define kGroupApplyListURL @"/v2/group/chatgroups/users/state"
#define kGroupApplyApprovalURL @"/v2/group/chatgroups/users"
#define kInviteGroupMemberURL @"/v4/users"
#define kSearchGroupMemberURL @"/v2/gov/arcfox/user"


#define kModifyGroupServeNoteURL @"/v2/group/chatgroups"
//#define kModifyGroupInfoURL @"/v2/group"
#define kModifyGroupInfoURL @"/v4/users"
#define kSearchGroupChatURL @"/v4/users"
//#define kFetchGroupYunGuanNoteURL @"/v2/group/chatgroups"
#define kFetchGroupYunGuanNoteURL @"/v4/users"
//声网音视频生成token接口
#define kEaseCallGenerateTokenYunGuanURL @"/v2/rtc/token"
//声网音视频获取一个channelName下有哪些uid接口
#define kEaseCallGetChannalUidsYunGuanURL @"/v2/rtc/channle"


@interface EaseHttpManager() <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString *restSeverHost;

@end

@implementation EaseHttpManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static EaseHttpManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EaseHttpManager alloc] init];
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
        if ([EaseIMKitOptions sharedOptions].restServer.length > 0) {
            self.restSeverHost = [EaseIMKitOptions sharedOptions].restServer;
        }else {
            self.restSeverHost = kServerHost;
        }
        
    }
    return self;
}

//- (void)registerToApperServer:(NSString *)uName
//                          pwd:(NSString *)pwd
//                   completion:(void (^)(NSInteger statusCode, NSString *aUsername))aCompletionBlock
//{
//    NSURL *url = [NSURL URLWithString:@"http://hk.test.easemob.com/app/chat/user/register"];
//    NSMutableURLRequest *request = [NSMutableURLRequest
//                                                requestWithURL:url];
//    request.HTTPMethod = @"POST";
//
//    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
//    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
//    request.allHTTPHeaderFields = headerDict;
//
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//    [dict setObject:uName forKey:@"userAccount"];
//    [dict setObject:pwd forKey:@"userPassword"];
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
//        if (aCompletionBlock) {
//            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
//        }
//    }];
//    [task resume];
//}


- (void)loginToApperServer:(NSString *)uName
                       pwd:(NSString *)pwd
                completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.restSeverHost,kLoginURL]];
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
    
    NSLog(@"%s url:%@ headerDict:%@ dict:%@",__func__,url,headerDict,dict);

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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/logout",self.restSeverHost,kLogoutURL,[EMClient sharedClient].currentUsername]];
    
    NSLog(@"%s url:%@",__func__,url);

    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];

    request.allHTTPHeaderFields = headerDict;

    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}



//- (void)createGroupWithGroupName:(NSString *)groupName
//                  groupInterduce:(NSString *)groupInterduce
//                 customerUserIds:(NSArray *)customerUserIds
//                   waiterUserIds:(NSArray *)waiterUserIds
//                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
//{
//
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.restSeverHost,kCreateGroupURL]];
//    NSMutableURLRequest *request = [NSMutableURLRequest
//                                                requestWithURL:url];
//    request.HTTPMethod = @"POST";
//
//    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
//    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
//    NSString *token = [EaseKitUtil getLoginUserToken];
//    [headerDict setObject:token forKey:@"Authorization"];
//    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
//
//    request.allHTTPHeaderFields = headerDict;
//
//    //"isPublic": false,//写死
//    //"allowinvites": true,//写死
//    //"groupname": "1",//群名称
//    //"owner": "15811252011",//群主
//    //"customerAids": [
//    //"fox-016"
//    //],//客户
//    //"waiterAids": [
//    //"15901016489",
//    //"0718003"
//    //],//服务人员
//    //"action": true//写死
//
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//
//    [dict setObject:@(NO) forKey:@"isPublic"];
//    [dict setObject:@(YES) forKey:@"allowinvites"];
//    [dict setObject:groupName forKey:@"groupname"];
//    [dict setObject:[EMClient sharedClient].currentUsername forKey:@"owner"];
//    [dict setObject:customerUserIds forKey:@"customerAids"];
//    [dict setObject:waiterUserIds forKey:@"waiterAids"];
//    [dict setObject:@(YES) forKey:@"action"];
//
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
//        if (aCompletionBlock) {
//            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
//        }
//    }];
//    [task resume];
//}


//"groupName":"这是调用北汽接口创的群",
//   "desc":"这是群描述",
//   "ownerAid":"15811252011",
//   "customerAids":["ceshib","ceshid","1508549872"],
//   "waiterAids":["ceshif"],
//   "groupType":"MANUAL"

- (void)createGroupWithGroupName:(NSString *)groupName
                  groupInterduce:(NSString *)groupInterduce
                 customerUserIds:(NSArray *)customerUserIds
                   waiterUserIds:(NSArray *)waiterUserIds
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock {

    //    /v4/users/{username}/group/createGroup

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/group/createGroup",self.restSeverHost,kCreateGroupURL,[EMClient sharedClient].currentUsername]];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];

    request.allHTTPHeaderFields = headerDict;

//"groupName":"这是调用北汽接口创的群",
//"desc":"这是群描述",
//"ownerAid":"15811252011",
//"customerAids":["ceshib","ceshid","1508549872"],
//"waiterAids":["ceshif"],
//"groupType":"MANUAL"
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:groupName forKey:@"groupName"];
    [dict setObject:groupInterduce forKey:@"desc"];

    [dict setObject:[EMClient sharedClient].currentUsername forKey:@"ownerAid"];
    [dict setObject:customerUserIds forKey:@"customerAids"];
    [dict setObject:waiterUserIds forKey:@"waiterAids"];
    [dict setObject:@"MANUAL" forKey:@"groupType"];
    [dict setObject:@(YES) forKey:@"action"];

    NSLog(@"%s url:%@\n headerDict:%@\n request dict:%@\n",__func__,url,headerDict,dict);

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

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.restSeverHost,kGroupApplyListURL]];
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

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/state",self.restSeverHost,kGroupApplyApprovalURL,[EMClient sharedClient].currentUsername]];
    
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
//    v4/users/{username}/group/{groupId}/addUsers/inviter/{inviter}/APP 极狐APP调用这个

    NSString *urlString = @"";

    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        urlString = [NSString stringWithFormat:@"%@%@/%@/group/%@/addUsers/inviter/%@/APP",self.restSeverHost,kInviteGroupMemberURL,[EMClient sharedClient].currentUsername,groupId,[EMClient sharedClient].currentUsername];
    }else {
        urlString = [NSString stringWithFormat:@"%@%@/%@/group/%@/addUsers/inviter/%@",self.restSeverHost,kInviteGroupMemberURL,[EMClient sharedClient].currentUsername,groupId,[EMClient sharedClient].currentUsername];
    }
    
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    
    NSString *imToken = [EMClient sharedClient].accessUserToken;
    NSString *ygToken = [EaseKitUtil getLoginUserToken];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [headerDict setObject:imToken forKey:@"Authorization"];
    }else {
        [headerDict setObject:ygToken forKey:@"Authorization"];
    }
   
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
    
    [dict setObject:customerUserIds forKey:@"customerAids"];
    [dict setObject:waiterUserIds forKey:@"waiterAids"];

    NSLog(@"%s url:%@ headerDict:%@ dict:%@",__func__,url,headerDict,dict);

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

    NSString *subString = @"";
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        subString = kJiHuSearchGroupMemberURL;
    }else {
        subString = kSearchGroupMemberURL;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",self.restSeverHost,subString,[EMClient sharedClient].currentUsername]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    
    NSString *imToken = [EMClient sharedClient].accessUserToken;
    NSString *ygToken = [EaseKitUtil getLoginUserToken];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [headerDict setObject:imToken forKey:@"Authorization"];
    }else {
        [headerDict setObject:ygToken forKey:@"Authorization"];
    }
    
//    NSString *token = [EaseKitUtil getLoginUserToken];
//    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
    [dict setObject:username forKey:@"username"];

    NSLog(@"%s url:%@ headerDict:%@ dict：%@ ",__func__,url,headerDict,dict);

    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}



//获取群服务备注接口
//URL: /v2/group/chatgroups/{groupId}/users/note
// groupId是需要查询的群id 响应结果中的noteAdmin字段是运管服务备注
//Method:GETPOST

- (void)fetchYunGuanNoteWithGroupId:(NSString *)groupId
                         completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock {

//URL: /v4/users/{username}/group/{groupId}/getGroupInfo

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/group/%@/getGroupInfo",self.restSeverHost,kFetchGroupYunGuanNoteURL,[EMClient sharedClient].currentUsername,groupId]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *token = [EaseKitUtil getLoginUserToken];
    [headerDict setObject:token forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSLog(@"%s url:%@ headerDict:%@",__func__,url,headerDict);

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}

//编辑群服务备注接口
//URL: /v2/group/chatgroups/{groupId}/users/{username}/note
// URL上的username 是登录的账号 groupId是需要查询的群id
//请求体中的note中传如内容
//Method:POSTP

- (void)editServeNoteWithGroupId:(NSString *)groupId
                            note:(NSString *)note
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/users/%@/note",self.restSeverHost,kModifyGroupServeNoteURL,groupId,[EMClient sharedClient].currentUsername]];
    
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
    [dict setObject:note forKey:@"note"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}



//URL: /v2/group/{groupId}/updateGroup
// URLgroupId是需要查询的群id
//Method:POSTPOST

//- (void)editGroupNameWithGroupId:(NSString *)groupId
//                       groupname:(NSString *)groupname
//                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
//{
//
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/updateGroup",self.restSeverHost,kModifyGroupInfoURL,groupId]];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest
//                                                requestWithURL:url];
//    request.HTTPMethod = @"POST";
//
//    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
//    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
//    NSString *token = [EaseKitUtil getLoginUserToken];
//    [headerDict setObject:token forKey:@"Authorization"];
//    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
//    request.allHTTPHeaderFields = headerDict;
//
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//    [dict setObject:groupname forKey:@"groupname"];
//
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
//        if (aCompletionBlock) {
//            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
//        }
//    }];
//    [task resume];
//}

///v4/users/{username}/group/{groupId}/modGroup
- (void)modifyGroupInfoWithGroupId:(NSString *)groupId
                       groupname:(NSString *)groupName
                 bussinessRemark:(NSString *)bussinessRemark
                      completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/group/%@/modGroup",self.restSeverHost,kModifyGroupInfoURL,[EMClient sharedClient].currentUsername,groupId]];
    
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
    [dict setObject:groupName forKey:@"groupName"];
    [dict setObject:bussinessRemark forKey:@"businessRemark"];
    [dict setObject:@"" forKey:@"desc"];

    NSLog(@"%s url:%@ headerDict:%@ dict:%@",__func__,url,headerDict,dict);

    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}

//URL: /v4/users/{username}/group/listGroup
// URL中的username是是登录的账号

//"source":"MANAGE",
//"aid":"15811252011"

//[dict setObject:groupname forKey:@"aid"];
//[dict setObject:groupname forKey:@"mobile"];
//[dict setObject:groupname forKey:@"orderId"];
//[dict setObject:groupname forKey:@"vin"];
//[dict setObject:groupname forKey:@"groupName"];

- (void)searchGroupListWithAid:(NSString *)aid
                        mobile:(NSString *)mobile
                       orderId:(NSString *)orderId
                           vin:(NSString *)vin
                     groupname:(NSString *)groupName
                    completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/group/listGroup",self.restSeverHost,kSearchGroupChatURL,[EMClient sharedClient].currentUsername]];
    
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
    [dict setObject:aid forKey:@"aid"];
    [dict setObject:mobile forKey:@"mobile"];
    [dict setObject:orderId forKey:@"orderId"];
    [dict setObject:vin forKey:@"vin"];
    [dict setObject:groupName forKey:@"groupName"];
    [dict setObject:@"MANUAL" forKey:@"groupType"];
    [dict setObject:@"MANAGE" forKey:@"source"];

    NSLog(@"%s url:%@ dict:%@",__func__,url,dict);

    NSLog(@"%s url:%@ headerDict:%@ dict:%@",__func__,url,headerDict,dict);
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


#pragma mark 极狐接口

//URL: /v2/group/chatgroups/users/{username}/action
- (void)fetchExclusiveServerGroupListWithCompletion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock {

    NSString *userName = [EMClient sharedClient].currentUsername;
    if (userName.length == 0) {
        //未登录
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/action",self.restSeverHost,kExclusiveServerGroupListURL
,[EMClient sharedClient].currentUsername]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *imToken = [EMClient sharedClient].accessUserToken;
    [headerDict setObject:imToken forKey:@"Authorization"];
    [headerDict setObject:userName forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSLog(@"%s url:%@ headerDict:%@",__func__,url,headerDict);
    
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

- (void)searchCustomOrderWithOrderType:(NSString *)orderType
                            completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/getOrders",self.restSeverHost,kSearchCustomOrderURL,[EMClient sharedClient].currentUsername]];
    
    NSLog(@"%s url:%@",__func__,url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *imToken = [EMClient sharedClient].accessUserToken;
    [headerDict setObject:imToken forKey:@"Authorization"];
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    NSString *jiHuAid = EaseIMKitManager.shared.jihuCurrentUid;
//    if (jiHuAid.length == 0) {
//        jiHuAid = @"222600";
//    }
    
    NSString *jiHuToken = EaseIMKitManager.shared.jihuToken;
//    if (jiHuToken.length == 0) {
//        jiHuToken = @"ad8s8d9adhka";
//    }
    
    // "aid":"222600",
    //    "orderType":"MAIN",
    //    "token":"ad8s8d9adhka"

    [dict setObject:jiHuAid forKey:@"aid"];
    [dict setObject:orderType forKey:@"orderType"];
    [dict setObject:jiHuToken forKey:@"token"];

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    NSLog(@"%s request dict:%@",__func__,dict);

    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}


///v2/rtc/token
///v1/rtc/token 极狐APP使用
// url中的username是当前用户的username
//Method:POSTPOST
//"channelName":
//"username":环信username
- (void)fetchRTCTokenWithChannelName:(NSString *)channelName
                          completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock
{

    NSURL *url = nil;
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.restSeverHost,kEaseCallGenerateTokenJiHuURL]];
    }else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.restSeverHost,kEaseCallGenerateTokenYunGuanURL]];
    }
    
    
    
    NSLog(@"%s url:%@",__func__,url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *imToken = [EMClient sharedClient].accessUserToken;
    NSString *ygToken = [EaseKitUtil getLoginUserToken];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [headerDict setObject:imToken forKey:@"Authorization"];
    }else {
        [headerDict setObject:ygToken forKey:@"Authorization"];
    }
    
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];
    request.allHTTPHeaderFields = headerDict;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    

//    "channelName":
//    "username":环信username
    [dict setObject:channelName forKey:@"channelName"];
    [dict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];

    NSLog(@"%s url:%@ headerDict:%@ dict:%@",__func__,url,headerDict,dict);

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseData = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (aCompletionBlock) {
            aCompletionBlock(((NSHTTPURLResponse*)response).statusCode, responseData);
        }
    }];
    [task resume];
}

//声网音视频获取一个channelName下有哪些uid接口
//URL: /v2/rtc/channle/{channleName}/show 运管端使用
///v1/rtc/channle/{channleName}/show 极狐APP使用
// url中的username是当前用户的username
//Method:GETPOST
//"channelName"

- (void)fetchRTCUidsWithChannelName:(NSString *)channelName
                 completion:(void (^)(NSInteger statusCode, NSString *response))aCompletionBlock {
        
    NSURL *url = nil;
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/show",self.restSeverHost,kEaseCallGetChannalUidsJiHuURL,channelName]];
    }else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/show",self.restSeverHost,kEaseCallGetChannalUidsYunGuanURL,channelName]];
    }
    
    NSLog(@"%s url:%@",__func__,url);

    NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
    NSString *imToken = [EMClient sharedClient].accessUserToken;
    NSString *ygToken = [EaseKitUtil getLoginUserToken];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        [headerDict setObject:imToken forKey:@"Authorization"];
    }else {
        [headerDict setObject:ygToken forKey:@"Authorization"];
    }
    
    [headerDict setObject:[EMClient sharedClient].currentUsername forKey:@"username"];

    request.allHTTPHeaderFields = headerDict;

    NSLog(@"%s url:%@ headerDict:%@",__func__,url,headerDict);

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
