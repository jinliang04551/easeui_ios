//
//  EaseSwitchRoleViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/27.
//

#import "EaseSwitchRoleViewController.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"
#import "EaseLoginViewController.h"


@interface EaseSwitchRoleViewController ()

@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *serverButton;

@end

@implementation EaseSwitchRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview:self.titleImageView];
    [self.view addSubview:self.userButton];
    [self.view addSubview:self.serverButton];

    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(48.0));
        make.height.equalTo(@(42.0));
    }];

    [self.userButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleImageView.mas_bottom).offset(100);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(70.0));
        make.height.equalTo(@(40.0));
    }];
    
    [self.serverButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userButton.mas_bottom).offset(100);
        make.centerX.equalTo(self.view);
        make.size.equalTo(self.userButton);
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


#pragma mark action
- (void)userButtonAction {
    [EaseIMKitOptions sharedOptions].isJiHuApp = YES;

    [EaseIMKitManager.shared configuationIMKitIsJiHuApp:[EaseIMKitOptions sharedOptions].isJiHuApp];
    
    EaseLoginViewController *controller = [[EaseLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}



- (void)serverButtonAction {
    [EaseIMKitOptions sharedOptions].isJiHuApp = NO;

    [EaseIMKitManager.shared configuationIMKitIsJiHuApp:[EaseIMKitOptions sharedOptions].isJiHuApp];
    
    EaseLoginViewController *controller = [[EaseLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}





#pragma mark getter and setter
- (UIButton *)userButton {
    if (_userButton == nil) {
        _userButton = [[UIButton alloc] init];
        [_userButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_userButton setTitle:@"用户端" forState:UIControlStateNormal];
        _userButton.titleLabel.font = EaseIMKit_NFont(16.0);
        
        [_userButton addTarget:self action:@selector(userButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _userButton.backgroundColor = [UIColor colorWithHexString:@"#4461F2"];
        _userButton.layer.cornerRadius = 4.0;
        
    }
    return _userButton;
}

- (UIButton *)serverButton {
    if (_serverButton == nil) {
        _serverButton = [[UIButton alloc] init];
        [_serverButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_serverButton setTitle:@"客服端" forState:UIControlStateNormal];
        _serverButton.titleLabel.font = EaseIMKit_NFont(16.0);
        
        [_serverButton addTarget:self action:@selector(serverButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _serverButton.backgroundColor = [UIColor colorWithHexString:@"#4461F2"];
        _serverButton.layer.cornerRadius = 4.0;
        
    }
    return _serverButton;

}

- (UIImageView *)titleImageView {
    if (_titleImageView == nil) {

        _titleImageView = [[UIImageView alloc]init];
        _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImageView.image = [UIImage easeUIImageNamed:@"yg_titleImage"];
    }
    return _titleImageView;
}

@end

