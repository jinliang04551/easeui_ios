//
//  EasePrivacyAlertView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/10/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EasePrivacyAlertView : UIView
@property (nonatomic,copy)void (^confirmBlock)(void);
@property (nonatomic,copy)void (^privacyURLBlock)(NSString *urlString);

/*显示 在 window 上*/
- (void)showWithCompletion:(void(^)(void))completion;

/*指定 view controller 显示*/
- (void)showinViewController:(UIViewController *)viewController
                  completion:(void(^)(void))completion;


@end

NS_ASSUME_NONNULL_END
