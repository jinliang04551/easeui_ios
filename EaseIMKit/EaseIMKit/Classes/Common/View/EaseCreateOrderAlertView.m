//
//  EaseCreateOrderAlertView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/12.
//

#import "EaseCreateOrderAlertView.h"
#import <Masonry/Masonry.h>
#import "EasePreLoginAccountCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EaseHeaders.h"
#import "EMTextView.h"

@interface EaseCreateOrderAlertContentView : UIView<UITextViewDelegate>
@property (nonatomic,copy)void (^cancelBlock)(void);
@property (nonatomic,copy)void (^confirmBlock)(void);

@property (nonatomic,strong) UIView *alphaView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIView *contentFooterView;
@property (nonatomic, strong) UIButton *accessButton;
@property (nonatomic, strong) EMTextView *textView;

@end

@implementation EaseCreateOrderAlertContentView

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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    [self addGestureRecognizer:tap];
    
}
  
- (void)handleTapAction:(UITapGestureRecognizer *)aTap {
    [self.textView resignFirstResponder];
}

#pragma mark private method
- (void)hideButtonAction {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
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
        [_contentView addSubview:self.subTitleLabel];
        [_contentView addSubview:self.accessButton];
        [_contentView addSubview:self.textView];
        [_contentView addSubview:self.contentFooterView];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(20.0);
            make.left.right.equalTo(_contentView);
            make.height.equalTo(@16.0);
        }];
        
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(25.0);
            make.left.equalTo(_contentView).offset(20.0);
            make.right.equalTo(self.accessButton.mas_left);
        }];
                
        [self.accessButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.subTitleLabel);
            make.right.equalTo(_contentView).offset(-20.0);
            make.size.equalTo(@(20.0));
        }];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subTitleLabel.mas_bottom).offset(20.0);
            make.left.equalTo(_contentView).offset(20.0);
            make.right.equalTo(_contentView).offset(-20.0);
            make.height.equalTo(@(118.0));
        }];
        
        [self.contentFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(28.0);
            make.left.right.equalTo(_contentView);
            make.height.mas_equalTo(58.0);
            make.bottom.equalTo(_contentView);
        }];
    }
    return _contentView;;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = UILabel.new;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = EaseIMKit_COLOR_HEX(0x333333);
        _titleLabel.text = @"账号信息";
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (_subTitleLabel == nil) {
        _subTitleLabel = UILabel.new;
        _subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        _subTitleLabel.textColor = EaseIMKit_COLOR_HEX(0x333333);
        _subTitleLabel.text = @"反馈消息记录";
    }
    return _subTitleLabel;
}


- (UIButton *)accessButton {
    if (_accessButton == nil) {
        _accessButton = [[UIButton alloc] init];
        [_accessButton setImage:[UIImage easeUIImageNamed:@"jh_right_access"] forState:UIControlStateNormal];
        
        [_accessButton addTarget:self action:@selector(hideButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessButton;
}

- (UIView *)contentFooterView {
    if (_contentFooterView == nil) {
        _contentFooterView = [[UIView alloc] init];
        
        UIView *widthLine = [[UIView alloc] init];
        widthLine.backgroundColor = EaseIMKit_COLOR_HEX(0xCFCFCF);
        
        UIView *vLine = [[UIView alloc] init];
        vLine.backgroundColor = EaseIMKit_COLOR_HEX(0xCFCFCF);
        
        UIButton *cancelButton = [[UIButton alloc] init];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:EaseIMKit_COLOR_HEX(0x333333) forState:UIControlStateNormal];

        [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmButton = [[UIButton alloc] init];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:EaseIMKit_COLOR_HEX(0x4461F2) forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];

        
        [_contentFooterView addSubview:widthLine];
        [_contentFooterView addSubview:vLine];
        [_contentFooterView addSubview:cancelButton];
        [_contentFooterView addSubview:confirmButton];

        
        [widthLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentFooterView);
            make.left.right.equalTo(_contentFooterView);
            make.height.equalTo(@(EaseIMKit_ONE_PX));
        }];
        
        [vLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(widthLine.mas_bottom);
            make.centerX.equalTo(_contentFooterView);
            make.width.equalTo(@(EaseIMKit_ONE_PX));
            make.bottom.equalTo(_contentFooterView);
        }];
    
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(widthLine.mas_bottom);
            make.left.equalTo(_contentFooterView);
            make.right.equalTo(vLine.mas_left);
            make.bottom.equalTo(_contentFooterView);
        }];
        
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(widthLine.mas_bottom);
            make.left.equalTo(vLine.mas_right);
            make.right.equalTo(_contentFooterView);
            make.bottom.equalTo(_contentFooterView);
            
        }];
        
    }
    return _contentFooterView;
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

- (EMTextView *)textView {
    if (_textView == nil) {
        _textView = [[EMTextView alloc] init];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _textView.placeholder = @"添加留言";
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.editable = YES;
        
        _textView.backgroundColor = EaseIMKit_COLOR_HEX(0xF5F5F5);
        _textView.layer.cornerRadius = 4.0;
        _textView.layer.borderColor = EaseIMKit_COLOR_HEX(0xDCDFE6).CGColor;
        _textView.layer.borderWidth = EaseIMKit_ONE_PX;
        
    }
    return _textView;
}

@end


static id g_instance = nil;
@interface EaseCreateOrderAlertView()
@property (nonatomic, strong) EaseCreateOrderAlertContentView* chooseUserView;
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIWindow* currentWindow;
@property (nonatomic, weak) UIViewController* controller;
@property (nonatomic, copy) void(^okBlock)(void);

@end

@implementation EaseCreateOrderAlertView
- (instancetype)init {
    self = [super init];
    if (self) {
        g_instance = self;
    }
    return self;
}


- (EaseCreateOrderAlertContentView *)chooseUserView {
    if (_chooseUserView == nil) {
        _chooseUserView = [[EaseCreateOrderAlertContentView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        EaseIMKit_WS
        _chooseUserView.cancelBlock = ^{
            [weakSelf hide];
            if (weakSelf.confirmBlock) {
                weakSelf.confirmBlock();
            }
        };
        _chooseUserView.confirmBlock = ^{
            [weakSelf hide];
            if (weakSelf.confirmBlock) {
                weakSelf.confirmBlock();
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
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
//        [view addGestureRecognizer:tap];
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


