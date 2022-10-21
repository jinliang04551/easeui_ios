//
//  EasePrivacyAlertView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/11.
//

#import "EasePrivacyAlertView.h"
#import <Masonry/Masonry.h>
#import "EasePreLoginAccountCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EaseHeaders.h"


@interface EasePrivacyAlertViewContentView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)void (^cancelBlock)(void);
@property (nonatomic,copy)void (^confirmBlock)(void);
@property (nonatomic,copy)void (^privacyURLBlock)(NSString *urlString);

@property (nonatomic,strong) UIView *alphaView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *confirmButton;
@property (nonatomic,strong) UITextView *privacyTextView;
@property (nonatomic,strong) UIButton *cancelButton;


@end

@implementation EasePrivacyAlertViewContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutAllSubviews];
    }
    return self;
}
 
- (void)layoutAllSubviews {
    
    [self addSubview:self.alphaView];
    [self addSubview:self.contentView];
    
    [self.alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(22.0);
        make.right.equalTo(self).offset(-22.0);
        make.centerY.equalTo(self);
    }];

}
  

#pragma mark private method
- (void)hideButtonAction {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

#pragma mark textview delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL
         inRange:(NSRange)characterRange
     interaction:(UITextItemInteraction)interaction{
    NSString *urlString = @"";
    if ([URL.scheme isEqualToString:@"privacy"]) {
        urlString = EaseUserPrivacyURL;
        if (self.privacyURLBlock) {
            self.privacyURLBlock(urlString);
        }
    }
    
    if ([URL.scheme isEqualToString:@"sevice"]) {
        urlString = EaseUserServiceURL;
        if (self.privacyURLBlock) {
            self.privacyURLBlock(urlString);
        }
    }
    
    return NO;
}

#pragma mark getter and setter
- (UIView *)alphaView {
    if (_alphaView == nil) {
        _alphaView = UIView.new;
        _alphaView.alpha = 0.5;
        _alphaView.backgroundColor = [UIColor blackColor];
    }
    return _alphaView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = UIView.new;
        _contentView.backgroundColor = UIColor.whiteColor;
        _contentView.layer.cornerRadius = 10.0f;
        _contentView.clipsToBounds = YES;
        
        [_contentView addSubview:self.titleLabel];
        [_contentView addSubview:self.privacyTextView];
        [_contentView addSubview:self.cancelButton];
        [_contentView addSubview:self.confirmButton];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(24.0);
            make.left.equalTo(_contentView).offset(24.0);
            make.right.equalTo(_contentView);
        }];
        
        [self.privacyTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(14.0);
            make.left.equalTo(_contentView).offset(24.0);
            make.right.equalTo(_contentView).offset(-24.0);
            make.height.equalTo(@(48.0));
        }];
        
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.privacyTextView.mas_bottom).offset(28.0);
            make.width.equalTo(@(46.0));
            make.height.equalTo(@(16.0));
            make.right.equalTo(self.confirmButton.mas_left).offset(-50.0);
            make.bottom.equalTo(_contentView).offset(-18.0);
        }];
        
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.cancelButton);
            make.size.equalTo(self.cancelButton);
            make.right.equalTo(_contentView).offset(-34.0);
        }];
        
    }
    return _contentView;;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = UILabel.new;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.text = @"服务协议及隐私保护";
    }
    return _titleLabel;
}

- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:@"不同意" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = EaseIMKit_NFont(14.0);

        [_cancelButton setTitleColor:EaseIMKit_COLOR_HEX(0x037BFD) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = UIButton.new;
        _confirmButton.titleLabel.font = EaseIMKit_NFont(14.0);
        [_confirmButton setTitle:@"同意" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:EaseIMKit_COLOR_HEX(0x037BFD) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (void)cancelButtonAction {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)confirmButtonAction {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

- (UITextView *)privacyTextView {
    if (_privacyTextView == nil) {
        _privacyTextView = UITextView.new;
        _privacyTextView.editable = NO;
        _privacyTextView.textAlignment = NSTextAlignmentLeft;
        _privacyTextView.linkTextAttributes = @{NSForegroundColorAttributeName:EaseIMKit_COLOR_HEX(0x4461F2),
                                   NSUnderlineColorAttributeName:EaseIMKit_COLOR_HEX(0x4461F2),
                                   NSUnderlineStyleAttributeName:@(NO)
                                   };
        _privacyTextView.delegate = self;
        _privacyTextView.scrollEnabled = NO;
        _privacyTextView.font = EaseIMKit_NFont(14.0);
        
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"同意《环信服务条款》与《环信隐私协议》，未注册手机号登录成功后将自动注册。"];
        [att addAttribute:NSLinkAttributeName value:@"sevice://" range:[att.string rangeOfString:@"《环信服务条款》"]];
        [att addAttribute:NSLinkAttributeName value:@"privacy://" range:[att.string rangeOfString:@"《环信隐私协议》"]];
        [att addAttribute:NSForegroundColorAttributeName value:EaseIMKit_COLOR_HEX(0x232F34) range:NSMakeRange(0, att.string.length)];

        _privacyTextView.attributedText = att;
        _privacyTextView.backgroundColor = UIColor.clearColor;
        _privacyTextView.textContainerInset = UIEdgeInsetsZero;
        _privacyTextView.textContainer.lineFragmentPadding = 0;
    }
    return _privacyTextView;
}

@end


static id g_instance = nil;
@interface EasePrivacyAlertView()
@property (nonatomic, strong) EasePrivacyAlertViewContentView* chooseUserView;
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIWindow* currentWindow;
@property (nonatomic, weak) UIViewController* controller;
@property (nonatomic, copy) void(^okBlock)(void);

@end

@implementation EasePrivacyAlertView
- (instancetype)init {
    self = [super init];
    if (self) {
        g_instance = self;
    }
    return self;
}


- (EasePrivacyAlertViewContentView *)chooseUserView {
    if (_chooseUserView == nil) {
        _chooseUserView = [[EasePrivacyAlertViewContentView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        EaseIMKit_WS
        _chooseUserView.cancelBlock = ^{
            [weakSelf hide];
        };
        _chooseUserView.confirmBlock = ^{
            [weakSelf hide];
            if (weakSelf.confirmBlock) {
                weakSelf.confirmBlock();
            }
        };
        
        _chooseUserView.privacyURLBlock = ^(NSString *urlString) {
            if (weakSelf.privacyURLBlock) {
                weakSelf.privacyURLBlock(urlString);
            }
        };
        
    }
    return _chooseUserView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight)];
        _bgView.backgroundColor = EaseIMKit_COLOR_HEXA(0x000000, 0.5);
    }
    return _bgView;
}


- (UIWindow*)currentWindow {
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }


    NSArray *windows = [UIApplication sharedApplication].windows;
    if ([windows count] == 1) {
        return [windows firstObject];
    } else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }

    return nil;
}


- (void)showWithCompletion:(void(^)(void))completion {
    //block
    self.okBlock = completion;
    
    [self show];
}

/*指定 view controller 显示*/
- (void)showinViewController:(UIViewController *)viewController
                  completion:(void(^)(void))completion {
    //block
    self.okBlock = completion;
    self.controller = viewController;
    
    [self showInView:viewController.view];
}

- (void)showInView:(UIView *)view {
    //check to add
    if (self.bgView.superview == nil) {
        [view addSubview:self.bgView];
        [view addSubview:self.chooseUserView];
        [self.chooseUserView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
            make.left.equalTo(view);
            make.right.equalTo(view);
            make.height.equalTo(view);
        }];
    }
    
    //show now
    self.chooseUserView.alpha = 0.0;
    self.bgView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseUserView.alpha = 1.0;
        self.bgView.alpha = 1.0;
    }];
}

- (void)show {
    //check to add
    if (self.bgView.superview == nil) {
        [self.currentWindow addSubview:self.bgView];
        [self.currentWindow addSubview:self.chooseUserView];
        [self.chooseUserView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.center.equalTo(self.currentWindow);
             make.left.equalTo(self.currentWindow);
             make.right.equalTo(self.currentWindow);
             make.height.equalTo(self.currentWindow);
         }];
    }
    
    //show now
    self.chooseUserView.alpha = 0.0;
    self.bgView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseUserView.alpha = 1.0;
        self.bgView.alpha = 1.0;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseUserView.alpha = 0.0;
        self.bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self.chooseUserView removeFromSuperview];
        
        g_instance = nil;
    }];
}

@end


