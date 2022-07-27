//
//  Util.m
//  EaseIM
//
//  Created by liu001 on 2022/7/22.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "EaseKitUtil.h"
#import <HyphenateChat/HyphenateChat.h>

@implementation EaseKitUtil

+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font {
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:content attributes:
        @{NSForegroundColorAttributeName:color,
          NSFontAttributeName:font
        }];
    return attrString;
}

+ (void)saveLoginUserToken:(NSString *)token userId:(NSString *)userId {

    NSString *key = [NSString stringWithFormat:@"login_token_%@",userId];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


+ (NSString *)getLoginUserToken {

    NSString *key = [NSString stringWithFormat:@"login_token_%@",[EMClient sharedClient].currentUsername];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (token == nil) {
        token = @"";
    }
    return token;
    
}

+ (void )removeLoginUserToken {

    NSString *key = [NSString stringWithFormat:@"login_token_%@",[EMClient sharedClient].currentUsername];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


@end
