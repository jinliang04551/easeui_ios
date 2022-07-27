//
//  Util.h
//  EaseIM
//
//  Created by liu001 on 2022/7/22.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseKitUtil : NSObject
+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font;

+ (void)saveLoginUserToken:(NSString *)token userId:(NSString *)userId;

+ (NSString *)getLoginUserToken;

+ (void )removeLoginUserToken;

@end

NS_ASSUME_NONNULL_END
