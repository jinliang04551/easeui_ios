//
//  EaseIMKitAppStyle.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseIMKitAppStyle : NSObject
@property (nonatomic, assign) BOOL isJiHuApp;
+ (instancetype)shareAppStyle;
- (void)defaultStyle;
- (void)updateNavAndTabbarWithIsJihuApp:(BOOL)isJihuApp;

@end

NS_ASSUME_NONNULL_END
