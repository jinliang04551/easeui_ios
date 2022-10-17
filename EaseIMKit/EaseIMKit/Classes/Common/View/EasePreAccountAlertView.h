//
//  EasePreLoginAccountView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/10/10.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface EasePreAccountAlertView : UIView
@property (nonatomic,copy)void (^confirmBlock)(NSDictionary *selectedDic);

/*显示 在 window 上*/
- (void)showWithCompletion:(void(^)(void))completion;

/*指定 view controller 显示*/
- (void)showinViewController:(UIViewController *)viewController
                  completion:(void(^)(void))completion;


@end

NS_ASSUME_NONNULL_END

