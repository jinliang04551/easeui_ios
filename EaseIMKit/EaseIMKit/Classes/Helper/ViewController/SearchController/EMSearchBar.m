//
//  EMSearchBar.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMSearchBar.h"
#import "EaseHeaders.h"

#define kTextFieldHeight 32.0f

@interface EMSearchBar()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *operateButton;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;

@property (nonatomic, strong) UILabel *controlLabel;

@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation EMSearchBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews {
    [self addSubview:self.control];
    [self addSubview:self.textField];

    [self.control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.height.equalTo(@(kTextFieldHeight));
    }];
    
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.height.equalTo(@(kTextFieldHeight));
    }];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self addSubview:self.operateButton];
    [self.operateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-16.0);
        make.width.equalTo(@(30.0));
        make.height.equalTo(self);
    }];
    
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-50);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        [self.delegate searchBarShouldBeginEditing:self];
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.text.length == 0) {
        return NO;
    }
    
    [self searchAction];
    
    return YES;
}

#pragma mark - Action

- (void)textFieldTextDidChange
{
    if (self.textField.text.length > 0) {
        [self.operateButton setTitle:@"搜索" forState:UIControlStateNormal];
        self.rightView.hidden = NO;
    }else {
        [self.operateButton setTitle:@"取消" forState:UIControlStateNormal];
        self.rightView.hidden = YES;
    }
    
}

- (void)operateButtonAction
{
    if (self.textField.text.length > 0) {
        [self searchAction];
    }else {
        [self cancelAction];
    }
}

- (void)cancelAction {
    self.textField.hidden = YES;
    self.control.hidden = NO;
    
    [self.operateButton removeFromSuperview];
    
    [self.textField resignFirstResponder];
    self.textField.text = @"";
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarCancelButtonAction:)]) {
        [self.delegate searchBarCancelButtonAction:self];
    }
}

- (void)searchAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTextDidChangeWithString:)]) {
        NSString *trimmedString = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        [self.delegate searchTextDidChangeWithString:trimmedString];
    }
}

- (UIButton *)operateButton {
    if (_operateButton == nil) {
        _operateButton = [[UIButton alloc] init];
        _operateButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_operateButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        [_operateButton setTitleColor:EaseIMKit_TitleBlueColor forState:UIControlStateNormal];
        [_operateButton addTarget:self action:@selector(operateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operateButton;
}


- (void)searchButtonAction {
    self.control.hidden = YES;
    self.textField.hidden = NO;
    [self.textField becomeFirstResponder];
}

#pragma mark getter and setter
- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.font = [UIFont systemFontOfSize:14.0];

        

        //设置文字属性
            NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
            attrs[NSFontAttributeName] = [UIFont systemFontOfSize:14.0];
            attrs[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"#7E7E7F"];
            
            //带属性的文字（富文本技术）
            NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"搜索" attributes:attrs];
        _textField.attributedPlaceholder  = placeholder;
        
//        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.layer.cornerRadius = kTextFieldHeight * 0.5;
        _textField.leftView = self.leftView;
        
        _textField.rightViewMode = UITextFieldViewModeWhileEditing;
        _textField.rightView = self.rightView;
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//            _textField.backgroundColor = [UIColor colorWithHexString:@"#252525"];
//            [_textField setTextColor:[UIColor colorWithHexString:@"#F5F5F5"]];
//            _textField.tintColor = [UIColor colorWithHexString:@"#04D0A4"];
//            self.backgroundColor = EaseIMKit_ViewBgBlackColor;
  
            self.backgroundColor = EaseIMKit_ViewBgWhiteColor;
            _textField.backgroundColor = [UIColor whiteColor];
            [_textField setTextColor:UIColor.blackColor];

        }else {
            self.backgroundColor = EaseIMKit_ViewBgWhiteColor;
            _textField.backgroundColor = [UIColor whiteColor];
            [_textField setTextColor:UIColor.blackColor];

        }
        
        _textField.hidden = YES;
    }
    return _textField;
}


- (UIView *)leftView {
    if (_leftView == nil) {
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];

        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        leftImageView.image = [UIImage easeUIImageNamed:@"jh_search_leftIcon"];
        
        [_leftView addSubview:leftImageView];
        [leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_leftView).insets(UIEdgeInsetsMake(0, 10.0, 0, 6.0));
        }];
    
    }
    return _leftView;
}

- (UIView *)rightView {
    if (_rightView == nil) {
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        
        [_rightView addSubview:self.clearButton];
        [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_rightView).insets(UIEdgeInsetsMake(0, 0, 0, 10.0));
        }];
        
        _rightView.hidden = YES;

    }
    return _rightView;
}


- (UIControl *)control {
    if (_control == nil) {
        _control = [[UIControl alloc] initWithFrame:CGRectZero];
        _control.clipsToBounds = YES;
        _control.layer.cornerRadius = kTextFieldHeight * 0.5;
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//            _control.backgroundColor = [UIColor colorWithHexString:@"#252525"];

            _control.backgroundColor = [UIColor whiteColor];
            [_textField setTextColor:UIColor.blackColor];
        }else {
            _control.backgroundColor = [UIColor whiteColor];
            [_textField setTextColor:UIColor.blackColor];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
        [_control addGestureRecognizer:tap];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage easeUIImageNamed:@"jh_search_leftIcon"]];
        
        UIView *subView = [[UIView alloc] init];
        [subView addSubview:imageView];
        [subView addSubview:self.controlLabel];
        [_control addSubview:subView];

        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(20.0);
            make.left.equalTo(subView);
            make.top.equalTo(subView);
            make.bottom.equalTo(subView);
        }];

        [self.controlLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).offset(3);
            make.right.equalTo(subView);
            make.top.equalTo(subView);
            make.bottom.equalTo(subView);
        }];

        [subView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_control);
        }];
        
    }
    return _control;
}

- (UILabel *)controlLabel {
    if (_controlLabel == nil) {
        _controlLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _controlLabel.font = [UIFont systemFontOfSize:14.0];
        _controlLabel.text = @"搜索";
        _controlLabel.textColor = [UIColor colorWithHexString:@"#7E7E7F"];
        [_controlLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    }
    return _controlLabel;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    self.textField.placeholder = placeHolder;
    self.controlLabel.text = placeHolder;
}

- (UIButton *)clearButton {
    if (_clearButton == nil) {
        _clearButton = [[UIButton alloc] init];
        [_clearButton setImage:[UIImage easeUIImageNamed:@"jh_invite_delete"] forState:UIControlStateNormal];
        
        [_clearButton addTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (void)clearButtonAction {
    self.textField.text = @"";
    self.rightView.hidden = YES;
    [self.operateButton setTitle:@"取消" forState:UIControlStateNormal];
}


@end
#undef kTextFieldHeight

