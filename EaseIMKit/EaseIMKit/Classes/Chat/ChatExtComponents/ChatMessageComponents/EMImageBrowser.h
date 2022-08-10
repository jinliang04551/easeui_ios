//
//  EMImageBrowser.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasePhotoBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMImageBrowser : NSObject

@property (nonatomic,strong)void (^dismissBlock)();

+ (instancetype)sharedBrowser;

- (void)showImages:(NSArray<UIImage *> *)aImageArray
    fromController:(UIViewController *)aController;

- (void)dismissViewController;

@end

NS_ASSUME_NONNULL_END
