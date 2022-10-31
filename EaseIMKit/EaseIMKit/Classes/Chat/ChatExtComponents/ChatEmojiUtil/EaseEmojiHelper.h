//
//  EaseEmojiHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/31.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseEmojiHelper : NSObject

@property (nonatomic, strong) NSMutableDictionary *convertEmojiDic;

@property (nonatomic, strong) NSMutableArray *convertEmojiArray;

@property (nonatomic, strong) NSMutableDictionary *emojiAttachDic;

+ (instancetype)sharedHelper;

//+ (NSArray<NSString *> *)getAllEmojis;

+ (BOOL)isStringContainsEmoji:(NSString *)aString;

+ (NSString *)convertEmoji:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
