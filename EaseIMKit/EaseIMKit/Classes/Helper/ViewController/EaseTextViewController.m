//
//  EMTextViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/17.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseTextViewController.h"
#import "EMTextView.h"
#import "EaseHeaders.h"

@interface EaseTextViewController ()<UITextViewDelegate>

@property (nonatomic, strong) NSString *originalString;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) BOOL isEditable;

@property (nonatomic, strong) EMTextView *textView;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, assign) BOOL isEditMode;

@end

@implementation EaseTextViewController

- (instancetype)initWithString:(NSString *)aString
                   placeholder:(NSString *)aPlaceholder
                    isEditable:(BOOL)aIsEditable
{
    self = [super init];
    if (self) {
        _originalString = aString;
        _placeholder = aPlaceholder;
        _isEditable = aIsEditable;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{    
    if (self.isEditable) {
        if (_originalString.length > 0) {
            //编辑时
            if (self.isEditMode) {
                self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"保存" rightBarAction:@selector(doneAction)];
                
            }else {
                self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"编辑" rightBarAction:@selector(editAction)];
            }
        }else {
            //新建时
            self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"保存" rightBarAction:@selector(doneAction)];
            self.textView.editable = YES;
        }
    
    }else {
        self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];
    }

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EMVIEWBOTTOMMARGIN);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];

    UIView *bgView = [[UIView alloc] init];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(self.view.frame.size.height/2));
    }];
    
 

if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    bgView.backgroundColor = EaseIMKit_ViewBgBlackColor;
    self.textView.backgroundColor = EaseIMKit_ViewBgBlackColor;
}else {
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    bgView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    self.textView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    
}
    
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (void)editAction {
    self.isEditMode = YES;
    self.textView.editable = YES;
    
    for (UIView *subView in self.view.subviews) {
        if (subView) {
            [subView removeFromSuperview];
        }
    }
    
    [self _setupSubviews];
}


- (void)doneAction
{
    [self.view endEditing:YES];
    
    BOOL isPop = YES;
    if (_doneCompletion) {
        isPop = _doneCompletion(self.textView.text);
    }
    
    if (isPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (EMTextView *)textView {
    if (_textView == nil) {
        _textView = [[EMTextView alloc] init];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _textView.placeholder = self.placeholder;

        _textView.returnKeyType = UIReturnKeyDone;
        if (self.originalString && ![self.originalString isEqualToString:@""]) {
            _textView.text = self.originalString;
        }
        _textView.editable = NO;
    }
    return _textView;
}
@end
