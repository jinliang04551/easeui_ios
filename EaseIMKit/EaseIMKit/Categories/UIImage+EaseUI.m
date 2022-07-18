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
    
    
//    NSBundle* bundle = [NSBundle bundleForClass:[EMChatBar class]];
//    NSString* path = [NSString stringWithFormat:@"EaseIMKit.bundle/%@",name];
//    NSString *file = [bundle pathForResource:path ofType:@"png"];
//    UIImage *image = [UIImage imageWithContentsOfFile:file];
//
    return image;
     
    
}

@end
