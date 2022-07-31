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
        
        
    }
    return self;
}

- (void)receiveJoinGroupApply {
    self.hasJoinGroupApply = YES;
}

- (void)clearJoinGroupApply {
    self.hasJoinGroupApply = NO;
}

@end
