//
//  EaseIMKitMessageHelper.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/30.
//

#import "EaseIMKitMessageHelper.h"
#import "EaseHeaders.h"

@interface EaseIMKitMessageHelper ()
@property (nonatomic, assign) BOOL  hasJoinGroupApply;
//极狐专属服务群id列表
@property (nonatomic, strong) NSMutableArray *exGroupIds;

@end


@implementation EaseIMKitMessageHelper
+ (instancetype)shareMessageHelper {
    static EaseIMKitMessageHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = EaseIMKitMessageHelper.new;
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveJoinGroupApply) name:EaseNotificationRequestJoinGroupEvent object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearJoinGroupApply) name:EaseNotificationClearRequestJoinGroupEvent object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChanged:) name:ACCOUNT_LOGIN_CHANGED object:nil];
    }
    return self;
}

- (void)receiveJoinGroupApply {
    self.hasJoinGroupApply = YES;
}

- (void)clearJoinGroupApply {
    self.hasJoinGroupApply = NO;
}


- (void)loginStateChanged:(NSNotification *)notify {
    BOOL loginSuccess = [notify.object boolValue];
    if (loginSuccess) {
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            [self fetchJiHuExGroupList];
        }
    }
}


- (void)fetchJiHuExGroupList {
    //极狐需要调接口
    [[EaseHttpManager sharedManager] fetchExclusiveServerGroupListWithCompletion:^(NSInteger statusCode, NSString * _Nonnull response) {
       
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSArray *groups = responsedict[@"entity"];
                NSMutableArray *tGroupIds = [NSMutableArray array];
                for (int i = 0; i< groups.count; ++i) {
                    NSDictionary *groupDic = groups[i];
                    NSString *groupId = groupDic[@"groupId"];
                    if (groupId) {
                        [tGroupIds addObject:groupId];
                    }
                }
                self.exGroupIds = tGroupIds;
                [self createExGroupsConversations];
                
            }else {
                NSLog(@"%s errorDescription:%@",__func__,errorDescription);
            }
            
        }
        
    }];

}


- (void)createExGroupsConversations {
    NSArray *exGroupIds = self.exGroupIds;
    for (int i = 0; i < exGroupIds.count; ++i) {
        NSString *groupId = exGroupIds[i];
       EMConversation *groupConv =  [[EMClient sharedClient].chatManager getConversation:groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
        groupConv.ext = @{@"JiHuExGroupChat":@(YES)};
    }
    
}

- (NSMutableArray *)exGroupIds {
    if (_exGroupIds == nil) {
        _exGroupIds = [NSMutableArray array];
    }
    return _exGroupIds;
}



@end
