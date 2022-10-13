//
//  EasePasswordView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EasePasswordView : UIView
@property (nonatomic, strong, readonly) UITextField *pswdField;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

- (void)updateHintLabelState:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
