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
        self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:NSLocalizedString(@"save", nil) rightBarAction:@selector(doneAction)];
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
    
    self.textView = [[EMTextView alloc] init];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:14.0];
    self.textView.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    bgView.backgroundColor = EaseIMKit_ViewBgBlackColor;
    self.textView.backgroundColor = EaseIMKit_ViewBgBlackColor;
}else {
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    bgView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    self.textView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:EaseIMKit_TitleBlueColor, NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];
}
    
    
    self.textView.placeholder = self.placeholder;

    self.textView.returnKeyType = UIReturnKeyDone;
    if (self.originalString && ![self.originalString isEqualToString:@""]) {
        self.textView.text = self.originalString;
    }
    self.textView.editable = self.isEditable;
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

@end
