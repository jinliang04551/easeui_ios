//
//  EMLoginViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/11.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EaseLoginViewController.h"

#import "MBProgressHUD.h"
#import "EaseIMKitOptions.h"
#import "EaseAlertController.h"
#import "EMRightViewToolView.h"
#import "EaseHeaders.h"


@interface EaseLoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *backImageBtn;


@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) EMRightViewToolView *pswdRightView;
@property (nonatomic, strong) EMRightViewToolView *userIdRightView;
@property (nonatomic, strong) UIButton *loginButton;//授权操作视图


@property (nonatomic, strong) UIButton *loginTypeButton;
@property (nonatomic) BOOL isLogin;

@property (nonatomic, strong) UIImageView* titleTextImageView;
@property (nonatomic, strong) UIImageView* sdkVersionBackView;
@property (nonatomic, strong) UILabel* sdkVersionLable;
@property (nonatomic, strong) UILabel* wellcomeLabel;
@property (nonatomic, strong) UILabel* bottomMsgLabel;

@end

@implementation EaseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.isLogin = false;
    [self _setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:imageView atIndex:0];
    
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    
    self.backImageBtn = [[UIButton alloc]init];
    [self.backImageBtn setImage:[UIImage easeUIImageNamed:@"jh_backleft"] forState:UIControlStateNormal];
    [self.backImageBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backView addSubview:self.backImageBtn];
    [self.backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView.mas_top).offset(EaseIMKit_StatusBarHeight);
        make.width.height.equalTo(@35);
        make.left.equalTo(self.view).offset(16);
    }];
    
    
    self.titleImageView = [[UIImageView alloc]init];
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backView addSubview:self.titleImageView];
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView.mas_top).offset(96);
        make.centerX.equalTo(self.backView);
        make.width.equalTo(@(48.0));
        make.height.equalTo(@(42.0));
    }];
    
    self.titleTextImageView = [[UIImageView alloc]init];
    [self.backView addSubview:self.titleTextImageView];
    [self.titleTextImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleImageView.mas_bottom).offset(12);
        make.centerX.equalTo(self.backView);
        make.width.equalTo(@(184.0));
        make.height.equalTo(@(34.0));
    }];
    
    [self.backView addSubview:self.wellcomeLabel];
    [self.wellcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.titleTextImageView.mas_bottom).offset(40);
    }];
    
    self.userIdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
    [self.userIdRightView.rightViewBtn addTarget:self action:@selector(clearUserIdAction) forControlEvents:UIControlEventTouchUpInside];
    self.nameField.rightView = self.userIdRightView;
    self.userIdRightView.hidden = YES;
    
    [self.backView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.wellcomeLabel.mas_bottom).offset(24.0);
        make.height.equalTo(@55);
    }];
    
    
    self.pswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backView addSubview:self.pswdField];
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.nameField.mas_bottom).offset(32.0);
        make.height.equalTo(@55);
    }];
    
    [self.backView addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.top.equalTo(self.pswdField.mas_bottom).offset(56.0);
        make.height.equalTo(@(48.0));
    }];

    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        imageView.image = [UIImage imageNamed:@"BootPage"];
        self.titleTextImageView.image = [UIImage imageNamed:@"titleTextImage"];
        self.titleImageView.image = [UIImage imageNamed:@"titleImage"];

    }else {
        imageView.image = [UIImage imageNamed:@"yg_BootPage"];
        self.titleTextImageView.image = [UIImage imageNamed:@"yg_titleTextImage"];
        self.titleImageView.image = [UIImage imageNamed:@"yg_titleImage"];

        [self.backView addSubview:self.bottomMsgLabel];
        [self.bottomMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backView).offset(30);
            make.right.equalTo(self.backView).offset(-30);
            make.bottom.equalTo(self.backView.mas_bottom).offset(-74.0);
        }];
    }
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.backView endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.nameField.text.length > 0 && self.pswdField.text.length > 0){
//        [self.authorizationView setupAuthBtnBgcolor:YES];
        [self updateLoginState:YES];
        self.isLogin = true;
        [self loginAction];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    textField.layer.borderColor = kColor_Blue.CGColor;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if (textField == self.nameField && [self.nameField.text length] == 0)
        self.userIdRightView.hidden = YES;
    if (textField == self.pswdField && [self.pswdField.text length] == 0)
        self.pswdRightView.hidden = YES;
    if(self.nameField.text.length > 0 && self.pswdField.text.length > 0){
        
        [self updateLoginState:YES];

        self.isLogin = true;
        return;
    }
    [self updateLoginState:NO];
    self.isLogin = false;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField == self.nameField) {
        self.userIdRightView.hidden = NO;
        if ([self.nameField.text length] <= 1 && [string isEqualToString:@""])
            self.userIdRightView.hidden = YES;
    }
    if (textField == self.pswdField) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = updatedString;
        self.pswdRightView.hidden = NO;
        if ([self.pswdField.text length] <= 0 && [string isEqualToString:@""]) {
            self.pswdRightView.hidden = YES;
            self.pswdField.secureTextEntry = YES;
            [self.pswdRightView.rightViewBtn setSelected:NO];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField
{
    UITextRange *rang = textField.markedTextRange;
    if (rang == nil) {
        if(![self.nameField.text isEqualToString:@""] && ![self.pswdField.text isEqualToString:@""]){
//            [self.authorizationView setupAuthBtnBgcolor:YES];
            [self updateLoginState:YES];
            self.isLogin = true;
            return;
        }
        [self updateLoginState:NO];
        self.isLogin = false;
    }
}

#pragma mark - Action

//清除用户名
- (void)clearUserIdAction
{
    self.nameField.text = @"";
    self.userIdRightView.hidden = YES;
}


- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}

- (void)loginAction
{
    if(!self.isLogin) {
        return;
    }
    [self.backView endEditing:YES];
    
    BOOL isTokenLogin = self.loginTypeButton.selected;
    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;

    __weak typeof(self) weakself = self;
    void (^finishBlock) (NSString *aName, EMError *aError) = ^(NSString *aName, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
            options.isAutoLogin = YES;
            options.loggedInUsername = aName;
            options.loggedInPassword = pswd;
            [options archive];

            //发送自动登录状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:[NSNumber numberWithBool:YES]];
            
            return ;
        }
        
        NSString *errorDes = NSLocalizedString(@"loginFailPrompt", nil);
        switch (aError.code) {
            case EMErrorUserNotFound:
                errorDes = NSLocalizedString(@"userNotFount", nil);
                break;
            case EMErrorNetworkUnavailable:
                errorDes = NSLocalizedString(@"offlinePrompt", nil);
                break;
            case EMErrorServerNotReachable:
                errorDes = NSLocalizedString(@"notReachServer", nil);
                break;
            case EMErrorUserAuthenticationFailed:
                errorDes = NSLocalizedString(@"userIdOrPwdError", nil);
                break;
            case EMErrorUserLoginTooManyDevices:
                errorDes = NSLocalizedString(@"devicesExceedLimit", nil);
                break;
            case EMErrorUserLoginOnAnotherDevice:
                errorDes = NSLocalizedString(@"loginOnOtherDevice", nil);
                break;
                case EMErrorUserRemoved:
                errorDes = NSLocalizedString(@"userRemovedByServer", nil);
            break;
            default:
                break;
        }
        [EaseAlertController showErrorAlert:errorDes];
    };
    
    if (isTokenLogin) {
        [[EMClient sharedClient] loginWithUsername:[name lowercaseString] token:pswd completion:finishBlock];
        return;
    }
    [[EMClient sharedClient] loginWithUsername:[name lowercaseString] password:pswd completion:finishBlock];
}


- (void)loginTypeChangeAction
{
    [self.backView endEditing:YES];
    
    self.loginTypeButton.selected = !self.loginTypeButton.selected;
    if (self.loginTypeButton.selected) {
        self.pswdField.text = @"";
        self.pswdField.placeholder = @"token";
        self.pswdField.secureTextEntry = NO;
        self.pswdField.rightView = nil;
        self.pswdField.rightViewMode = UITextFieldViewModeNever;
        self.pswdField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.loginTypeButton setTitle:NSLocalizedString(@"loginWithPwd", nil) forState:UIControlStateNormal];
        return;
    }
    self.pswdField.placeholder = NSLocalizedString(@"password", nil);
    self.pswdField.secureTextEntry = !self.pswdRightView.rightViewBtn.selected;
    self.pswdField.rightView = self.pswdRightView;
    self.pswdRightView.hidden = YES;
    self.pswdField.rightViewMode = UITextFieldViewModeAlways;
    self.pswdField.clearButtonMode = UITextFieldViewModeNever;
    [self.loginTypeButton setTitle:NSLocalizedString(@"loginWithToken", nil) forState:UIControlStateNormal];
}

- (UILabel *)wellcomeLabel {
    if (_wellcomeLabel == nil) {
        _wellcomeLabel = [[UILabel alloc] init];
        _wellcomeLabel.textAlignment = NSTextAlignmentLeft;
        _wellcomeLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
        _wellcomeLabel.font = [UIFont systemFontOfSize:24.0];
        _wellcomeLabel.text = @"欢迎登录";
    }
    return _wellcomeLabel;
}

- (UITextField *)nameField {
    if (_nameField == nil) {
        _nameField = [[UITextField alloc] init];
        _nameField.backgroundColor = [UIColor whiteColor];
        _nameField.delegate = self;
        _nameField.borderStyle = UITextBorderStyleNone;
        _nameField.placeholder = NSLocalizedString(@"userId", nil);
        _nameField.returnKeyType = UIReturnKeyGo;
        _nameField.font = [UIFont systemFontOfSize:17];
        _nameField.rightViewMode = UITextFieldViewModeWhileEditing;
        _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
                
        UIView *iconBgView = [[UIView alloc] init];
        UIImageView *iconImageView = [[UIImageView alloc] init];
        [iconImageView setImage:[UIImage easeUIImageNamed:@"yg_usr_input_icon"]];
        [iconBgView addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(iconBgView).insets(UIEdgeInsetsMake(0, 8.0, 0, 0));
        }];
        _nameField.leftView = iconBgView;
        _nameField.leftViewMode = UITextFieldViewModeAlways;
        
        _nameField.layer.cornerRadius = 4.0;
        _nameField.layer.borderWidth = 1;
        _nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
    }
    return _nameField;
}

- (UITextField *)pswdField {
    if (_pswdField == nil) {

        _pswdField = [[UITextField alloc] init];
        _pswdField.backgroundColor = [UIColor whiteColor];
        _pswdField.delegate = self;
        _pswdField.borderStyle = UITextBorderStyleNone;
        _pswdField.placeholder = NSLocalizedString(@"password", nil);
        _pswdField.font = [UIFont systemFontOfSize:17];
        _pswdField.returnKeyType = UIReturnKeyGo;
        _pswdField.secureTextEntry = YES;
        _pswdField.clearsOnBeginEditing = NO;
        
        _pswdField.layer.cornerRadius = 4.0;
        _pswdField.layer.borderWidth = 1;
        _pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        UIView *iconBgView = [[UIView alloc] init];
        UIImageView *iconImageView = [[UIImageView alloc] init];
        [iconImageView setImage:[UIImage easeUIImageNamed:@"yg_pwd_input_icon"]];
        [iconBgView addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(iconBgView).insets(UIEdgeInsetsMake(0, 8.0, 0, 0));
        }];
        
        _pswdField.leftView = iconBgView;
        _pswdField.leftViewMode = UITextFieldViewModeAlways;

        _pswdField.rightView = self.pswdRightView;
        _pswdField.rightViewMode = UITextFieldViewModeWhileEditing;

    }
    return _pswdField;
}


- (UIButton *)loginButton {
    if (_loginButton == nil) {
        _loginButton = [[UIButton alloc] init];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitle:@"登 录" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = EaseIMKit_NFont(16.0);
        
        [_loginButton addTarget:self action:@selector(agreeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.backgroundColor = [UIColor colorWithHexString:@"#4390C0"];
        _loginButton.layer.cornerRadius = 4.0;
        
    }
    return _loginButton;

}

- (void)agreeButtonAction {
    [self loginAction];
}

- (void)updateLoginState:(BOOL)isEdit {
    if (isEdit) {
        [self.loginButton setBackgroundColor:[UIColor colorWithHexString:@"#4798CB"]];
    }else {
        [self.loginButton setBackgroundColor:[UIColor colorWithHexString:@"#4390C0"]];
    }

}


- (UILabel *)bottomMsgLabel {
    if (_bottomMsgLabel == nil) {
        _bottomMsgLabel = [[UILabel alloc] init];
        _bottomMsgLabel.textAlignment = NSTextAlignmentCenter;
        _bottomMsgLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _bottomMsgLabel.font = [UIFont systemFontOfSize:12.0];
        _bottomMsgLabel.text = @"© 2022 极狐ARCFOX 运管端";
    }
    return _bottomMsgLabel;
}


@end
