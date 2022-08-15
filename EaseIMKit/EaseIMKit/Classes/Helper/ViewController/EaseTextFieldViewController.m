//
//  EMTextFieldViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseTextFieldViewController.h"
#import "EaseHeaders.h"

#define  kMaxInputLimit 16

@interface EaseTextFieldViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) NSString *originalString;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) BOOL isEditable;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation EaseTextFieldViewController

- (instancetype)initWithString:(NSString *)aString
                   placeholder:(NSString *)aPlaceholder
                    isEditable:(BOOL)aIsEditable
{
    self = [super init];
    if (self) {
        _originalString = aString;
        _placeholder = aPlaceholder;
        _isEditable = aIsEditable;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
        name:@"UITextFieldTextDidChangeNotification" object:nil];        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{    
    self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:NSLocalizedString(@"done", nil) rightBarAction:@selector(doneAction)];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];


    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom).offset(20);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.font = [UIFont systemFontOfSize:16];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.text = self.originalString;
    self.textField.enabled = self.isEditable;
    if (self.isEditable) {
        self.textField.placeholder = self.placeholder;
    }
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bgView);
        make.top.equalTo(bgView).offset(5);
        make.left.equalTo(bgView).offset(10);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}



-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange]; //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
        if (toBeString.length > kMaxInputLimit) {
        textField.text = [toBeString substringToIndex:kMaxInputLimit];
        }
        } // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
        } // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况 else{
        if (toBeString.length > kMaxInputLimit) {
        textField.text = [toBeString substringToIndex:kMaxInputLimit];
        }


}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }

    return YES;
}

#pragma mark - Action

- (void)doneAction
{
    [self.view endEditing:YES];
    
    BOOL isPop = YES;
    if (_doneCompletion) {
        isPop = _doneCompletion(self.textField.text);
    }
    
    if (isPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

#undef kMaxInputLimit
