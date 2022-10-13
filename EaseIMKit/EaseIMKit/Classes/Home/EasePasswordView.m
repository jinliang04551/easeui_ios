//
//  EasePasswordView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/13.
//

#import "EasePasswordView.h"
#import "EaseHeaders.h"
#import "EMRightViewToolView.h"

#define kPwdErrorColor EaseIMKit_COLOR_HEX(0xFF4D4F)

@interface EasePasswordView ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) EMRightViewToolView *pswdRightView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintLabel;

@end


@implementation EasePasswordView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    self.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.titleLabel];
    [self addSubview:self.pswdField];
    [self addSubview:self.hintLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(0);
        make.left.equalTo(self).offset(20.0);
        make.right.equalTo(self);
    }];
    
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10.0);
        make.left.equalTo(self).offset(20.0);
        make.right.equalTo(self).offset(-20.0);
        make.height.equalTo(@(44.0));
    }];

    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pswdField.mas_bottom).offset(4.0);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self);
        make.bottom.equalTo(self).offset(-14.0);
    }];
    
}

- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}

- (void)updateHintLabelState:(BOOL)isShow {
    self.hintLabel.hidden = !isShow;

    if (isShow) {
        self.pswdField.textColor = kPwdErrorColor;
        self.pswdField.layer.borderColor = kPwdErrorColor.CGColor;

    }else {
        self.pswdField.textColor = EaseIMKit_COLOR_HEX(0x9B9FA8);
        self.pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;

    }
    
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pswdRightView.hidden = [textField.text length] == 0;
    
}

#pragma mark getter and setter
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        _titleLabel.text = @"欢迎登录";
    }
    return _titleLabel;
}

- (UILabel *)hintLabel {
    if (_hintLabel == nil) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.textAlignment = NSTextAlignmentLeft;
        _hintLabel.textColor = EaseIMKit_COLOR_HEX(0xFF4D4F);
        _hintLabel.font = [UIFont systemFontOfSize:14.0];
        _hintLabel.text = @"密码长度6～16位";
        _hintLabel.hidden = YES;
    }
    return _hintLabel;
}

- (UITextField *)pswdField {
    if (_pswdField == nil) {
        _pswdField = [[UITextField alloc] init];
        _pswdField.backgroundColor = [UIColor whiteColor];
        _pswdField.delegate = self;
        _pswdField.borderStyle = UITextBorderStyleNone;
        _pswdField.placeholder = NSLocalizedString(@"password", nil);
        _pswdField.font = [UIFont systemFontOfSize:16.0];
        _pswdField.textColor = EaseIMKit_COLOR_HEX(0x9B9FA8);
        _pswdField.returnKeyType = UIReturnKeyGo;
        _pswdField.secureTextEntry = YES;
        _pswdField.clearsOnBeginEditing = NO;
        
        _pswdField.layer.cornerRadius = 4.0;
        _pswdField.layer.borderWidth = EaseIMKit_ONE_PX;
        _pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        CGRect frame = _pswdField.frame;
           frame.size.width = 8.0f;
           UIView *leftview = [[UIView alloc] initWithFrame:frame];
        _pswdField.leftViewMode = UITextFieldViewModeAlways;
        _pswdField.leftView = leftview;
        
        _pswdField.rightView = self.pswdRightView;
        _pswdField.rightViewMode = UITextFieldViewModeWhileEditing;

    }
    return _pswdField;
}


- (EMRightViewToolView *)pswdRightView {
    if (_pswdRightView == nil) {
        _pswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
        [_pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pswdRightView;
}

@end

#undef kPwdErrorColor
