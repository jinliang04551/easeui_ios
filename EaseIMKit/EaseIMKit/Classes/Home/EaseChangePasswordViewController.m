//
//  EaseChangePasswordViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/11.
//

#import "EaseChangePasswordViewController.h"
#import "EasePasswordView.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"

@interface EaseChangePasswordViewController ()
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) EasePasswordView *oldPwdView;
@property (nonatomic, strong) EasePasswordView *newPwdView;
@property (nonatomic, strong) EasePasswordView *confirmPwdView;


@end

@implementation EaseChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#171717"];
    }else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    }
    
    [self placeAndLayoutSubviews];
}


#pragma mark - Subviews
- (void)placeAndLayoutSubviews {

    self.titleView = [self customNavWithTitle:@"账号与安全" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];
    
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];
    
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.confirmButton];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
        
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).offset(32.0);
        make.left.equalTo(self.view).offset(16.0);
        make.right.equalTo(self.view).offset(-16.0);
        make.height.equalTo(@(44.0));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    [self.view addGestureRecognizer:tap];
    
}
  
- (void)handleTapAction:(UITapGestureRecognizer *)aTap {
    [self.view endEditing:YES];
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

#pragma mark private method
- (void)confirmButtonAction {
    [self.newPwdView updateHintLabelState:YES];
    [self.confirmPwdView updateHintLabelState:NO];

}

#pragma mark getter and setter
- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_confirmButton setTitle:@"保存" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.backgroundColor = EaseIMKit_COLOR_HEX(0x4461F2);
        _confirmButton.layer.cornerRadius = 4.0;
        _confirmButton.clipsToBounds = YES;
    }
    return _confirmButton;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = UIColor.whiteColor;
        [_contentView addSubview:self.oldPwdView];
        [_contentView addSubview:self.newPwdView];
        [_contentView addSubview:self.confirmPwdView];

        [self.oldPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(24.0);
            make.left.equalTo(_contentView);
            make.right.equalTo(_contentView);
        
        }];
           
        [self.newPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.oldPwdView.mas_bottom);
            make.left.equalTo(_contentView);
            make.right.equalTo(_contentView);
        }];
        
        [self.confirmPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.newPwdView.mas_bottom);
            make.left.equalTo(_contentView);
            make.right.equalTo(_contentView);
            make.bottom.equalTo(_contentView);
        }];
        
    }
    return _contentView;
}

- (EasePasswordView *)oldPwdView {
    if (_oldPwdView == nil) {
        _oldPwdView = [[EasePasswordView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _oldPwdView.titleLabel.text = @"原密码";
    }
    return _oldPwdView;
}

- (EasePasswordView *)newPwdView {
    if (_newPwdView == nil) {
        _newPwdView = [[EasePasswordView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _newPwdView.titleLabel.text = @"新密码";

    }
    return _newPwdView;
}

- (EasePasswordView *)confirmPwdView {
    if (_confirmPwdView == nil) {
        _confirmPwdView = [[EasePasswordView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _confirmPwdView.titleLabel.text = @"确认密码";

    }
    return _confirmPwdView;
}

@end

