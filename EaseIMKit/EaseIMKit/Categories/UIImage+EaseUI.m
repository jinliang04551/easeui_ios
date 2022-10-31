//
//  UIImage+EaseUI.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/15.
//

#import "UIImage+EaseUI.h"
#import <objc/runtime.h>
#import "EaseIMKitManager.h"
#import "EMChatBar.h"

@implementation UIImage (EaseUI)
+ (UIImage *)easeUIImageNamed:(NSString *)name {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"EaseIMKit" ofType:@"bundle"];
//    NSString *imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",name]];
//    return [UIImage imageWithContentsOfFile:imagePath];

    NSBundle *tBundle = [NSBundle bundleForClass:[EMChatBar class]];
    NSString* absolutePath = [tBundle pathForResource:@"EaseIMKit" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:absolutePath];
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",bundle.bundlePath,name]];
    
    return image;
}

+ (UIImage*)emojiImageWithName:(NSString*)imageName
{
    NSBundle* bundle = [NSBundle bundleForClass:[EMChatBar class]];
    NSString* path = [NSString stringWithFormat:@"EaseKitEmoji.bundle/%@",imageName];
    NSString *file1 = [bundle pathForResource:path ofType:@"png"];
    UIImage *image1 = [UIImage imageWithContentsOfFile:file1];

    return image1;
}

@end
