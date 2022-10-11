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
#import "EaseHttpManager.h"
#import "EaseIMKitManager.h"
#import "EaseWebViewController.h"
#import "EasePreLoginAccountView.h"

#define kTitleImageViewOffTop 96

@interface EaseLoginViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) UIView *contentView;
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

//yunguan
@property (nonatomic, strong) UIButton *preLoginAccountButton;

//jihu
@property (nonatomic,strong) UIButton *checkedButton;
@property (nonatomic,strong) UITextView *privacyTextView;
@property (nonatomic,strong) UILabel *hintLabel;

@end

@implementation EaseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.isLogin = false;
    [self _setupSubviews];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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



#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    
    CGFloat offset = 0;
    if (self.contentView.frame.size.height - keyBoardHeight <= CGRectGetMaxY(self.loginButton.frame)) {
        offset = CGRectGetMaxY(self.loginButton.frame) - (self.contentView.frame.size.height - keyBoardHeight);
    } else {
        return;
    }

    void (^animation)(void) = ^void(void) {
        [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(kTitleImageViewOffTop - offset - 20);
        }];
    };
    
    [self keyBoardWillShow:note animations:animation completion:nil];
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    void (^animation)(void) = ^void(void) {
        [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(kTitleImageViewOffTop);
        }];
    };
    [self keyBoardWillHide:note animations:animation completion:nil];
}



#pragma mark - Subviews

- (void)_setupSubviews
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:imageView atIndex:0];
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    
    self.backImageBtn = [[UIButton alloc]init];
    [self.backImageBtn setImage:[UIImage easeUIImageNamed:@"jh_backleft"] forState:UIControlStateNormal];
    [self.backImageBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.backImageBtn];
    [self.backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(EaseIMKit_StatusBarHeight);
        make.width.height.equalTo(@35);
        make.left.equalTo(self.view).offset(16);
    }];
    
    
    self.titleImageView = [[UIImageView alloc]init];
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.titleImageView];
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kTitleImageViewOffTop);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(48.0));
        make.height.equalTo(@(42.0));
    }];
    
    self.titleTextImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:self.titleTextImageView];
    [self.titleTextImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleImageView.mas_bottom).offset(2);
        make.centerX.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(56.0);
        make.right.equalTo(self.contentView).offset(-56.0);
        make.height.equalTo(@(16.0));
    }];
    
    [self.contentView addSubview:self.wellcomeLabel];
    [self.wellcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.titleTextImageView.mas_bottom).offset(40);
    }];
    
    self.userIdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
    [self.userIdRightView.rightViewBtn addTarget:self action:@selector(clearUserIdAction) forControlEvents:UIControlEventTouchUpInside];
    self.userIdRightView.hidden = YES;
    
    [self.contentView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.wellcomeLabel.mas_bottom).offset(24.0);
        make.height.equalTo(@55);
    }];
    
    
    self.pswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.pswdField];
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.nameField.mas_bottom).offset(32.0);
        make.height.equalTo(@55);
    }];
    
    [self.contentView addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.pswdField.mas_bottom).offset(56.0);
        make.height.equalTo(@(48.0));
    }];

    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        imageView.image = [UIImage easeUIImageNamed:@"BootPage"];
//        self.titleTextImageView.image = [UIImage easeUIImageNamed:@"titleTextImage"];
//        self.titleImageView.image = [UIImage easeUIImageNamed:@"titleImage"];

        self.titleTextImageView.image = [UIImage easeUIImageNamed:@"yg_titleTextImage"];
        self.titleImageView.image = [UIImage easeUIImageNamed:@"yg_titleImage"];

        
        [self.contentView addSubview:self.checkedButton];
        [self.contentView addSubview:self.privacyTextView];
        
        [self.checkedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginButton.mas_bottom).offset(17.0);
            make.left.equalTo(self.loginButton).offset(20.0);
            make.size.equalTo(@(16.0));
        }];

        
        [self.privacyTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.checkedButton).offset(-10.0);
            make.left.equalTo(self.checkedButton.mas_right).offset(12.0);
            make.right.equalTo(self.loginButton);
        }];
     
        
    }else {
        imageView.image = [UIImage easeUIImageNamed:@"yg_BootPage"];
        self.titleTextImageView.image = [UIImage easeUIImageNamed:@"yg_titleTextImage"];
        self.titleImageView.image = [UIImage easeUIImageNamed:@"yg_titleImage"];
       
        [self.contentView addSubview:self.preLoginAccountButton];
        
        [self.preLoginAccountButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginButton.mas_bottom).offset(12.0);
            make.left.equalTo(self.loginButton);
            make.right.equalTo(self.loginButton);
        }];


    }
    
    [self.contentView addSubview:self.bottomMsgLabel];
    [self.bottomMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-74.0);
    }];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.contentView endEditing:YES];
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

#pragma mark textview delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL
         inRange:(NSRange)characterRange
     interaction:(UITextItemInteraction)interaction{
    NSString *urlString = @"";
    if ([URL.scheme isEqualToString:@"privacy"]) {
        EaseWebViewController *webVC = [[EaseWebViewController alloc] initWithURLString:urlString];
        [self.navigationController pushViewController:webVC animated:YES];
        
    }
    
    if ([URL.scheme isEqualToString:@"sevice"]) {
        EaseWebViewController *webVC = [[EaseWebViewController alloc] initWithURLString:urlString];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    
    return NO;
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
    [self.contentView endEditing:YES];
    
    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;


    [self showHudInView:self.view hint:@"登录中"];
    
    [EaseIMKitManager.shared loginWithUserName:[name lowercaseString] password:pswd completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        [self hideHud];
        if (statusCode == 200) {
            [self showHint:@"登录成功"];
        }else {
            [EaseAlertController showErrorAlert:response];
        }
    }];
    
}


- (void)loginTypeChangeAction
{
    [self.contentView endEditing:YES];
    
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

- (void)checkedButtonAction {
    self.checkedButton.selected = !self.checkedButton.selected;
}

- (void)preLoginAccountButtonAction {

    EasePreLoginAccountView* alert = [[EasePreLoginAccountView alloc] init];
    
    [alert showinViewController:self completion:^{

    }];
    
    EaseIMKit_WS
    alert.confirmBlock = ^(NSDictionary * _Nonnull selectedDic) {
        NSString *account = selectedDic[kPreAccountKey];
        NSString *accountPwd = selectedDic[kPreAccountPwdKey];
        weakSelf.nameField.text = account;
        weakSelf.pswdField.text = accountPwd;
    };
    
}



#pragma mark getter and setter
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
            make.size.equalTo(@(20.0));
        }];
        _nameField.leftView = iconBgView;
        _nameField.leftViewMode = UITextFieldViewModeAlways;
        _nameField.rightView = self.userIdRightView;

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
//            make.centerY.equalTo(iconBgView);
//            make.left.equalTo(iconBgView).offset(8.0);
            make.edges.equalTo(iconBgView).insets(UIEdgeInsetsMake(0, 8.0, 0, 0));

            make.size.equalTo(@(20.0));
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
        _loginButton.backgroundColor = [UIColor colorWithHexString:@"#4461F2"];
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
        _bottomMsgLabel.text = @"© easemob 环信 私人订制";
    }
    return _bottomMsgLabel;
}


- (UIButton *)checkedButton {
    if (_checkedButton == nil) {
        _checkedButton = UIButton.new;
        [_checkedButton setImage:[UIImage easeUIImageNamed:@"user_multiple_uncheck"] forState:UIControlStateNormal];
        [_checkedButton setImage:[UIImage easeUIImageNamed:@"user_multiple_check"] forState:UIControlStateSelected];

        [_checkedButton addTarget:self action:@selector(checkedButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _checkedButton;
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
        _privacyTextView.font = EaseIMKit_NFont(12.0);
        
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"同意《环信服务条款》与《环信隐私协议》，未注册手机号登陆成功后将自动注册。"];
        [att addAttribute:NSLinkAttributeName value:@"privacy://" range:[att.string rangeOfString:@"《环信服务条款》"]];
        [att addAttribute:NSLinkAttributeName value:@"sevice://" range:[att.string rangeOfString:@"《环信隐私协议》"]];
        [att addAttribute:NSForegroundColorAttributeName value:EaseIMKit_COLOR_HEX(0xBCC2D8) range:NSMakeRange(0, att.string.length)];

        _privacyTextView.attributedText = att;
        _privacyTextView.backgroundColor = UIColor.clearColor;
        
    }
    return _privacyTextView;
}


- (UIButton *)preLoginAccountButton {
    if (_preLoginAccountButton == nil) {
        _preLoginAccountButton = [[UIButton alloc] init];
        _preLoginAccountButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_preLoginAccountButton setTitle:@"获取登录账号" forState:UIControlStateNormal];
        [_preLoginAccountButton setTitleColor:EaseIMKit_COLOR_HEX(0x4461F2) forState:UIControlStateNormal];
        [_preLoginAccountButton addTarget:self action:@selector(preLoginAccountButtonAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _preLoginAccountButton;
}

@end
#undef kTitleImageViewOffTop
