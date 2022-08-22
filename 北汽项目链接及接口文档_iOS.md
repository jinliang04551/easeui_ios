# 项目相关地址

## IMKit地址（sdk）
https://github.com/jinliang04551/easeui_ios  branch: EaseIMKit_beiqi_sdk


## Demo地址
https://github.com/jinliang04551/chat-ios  branch:
dev_beiqi_sdk


## 注意事项：
目前打包的IMSDK是本地打包的 需要自己导入一下
导入的目录为：easeui_ios/EaseIMKit/HyphenateChat.framework
下载地址为：
https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/BeiQi_SDK/iOS_SDK/HyphenateChat.framework.zip

#极狐App
1.  初始化
    EaseIMKitOptions *demoOptions = [EaseIMKitOptions sharedOptions];
    demoOptions.appkey = @"1100220704109048#arcfox-server";
    demoOptions.apnsCertName = @"jihu_product";
    demoOptions.apnsCertName = @"jihu_developer";
    demoOptions.restServer = @"http://baidu.com";
    [EaseIMKitManager managerWithEaseIMKitOptions:demoOptions];
    
1.1 注册推送
    //注册推送
    [self _registerRemoteNotification];
1.2 绑定证书
// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%s deviceToken:%@",__func__,deviceToken);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}
    

2. 配置UI入口，是否是极狐
 [EaseIMKitManager.shared configuationIMKitIsJiHuApp:[EaseIMKitOptions sharedOptions].isJiHuApp];
 
3. 登录接口
    [self showHudInView:self.view hint:@"登录中"];
    
    [EaseIMKitManager.shared loginWithUserName:[name lowercaseString] password:pswd completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        [self hideHud];
        if (statusCode == 200) {
            [self showHint:@"登录成功"];
        }else {
            [EaseAlertController showErrorAlert:response];
        }
    }];

4. 我的会话
EMConversationsViewController * conversationsVC= [[EMConversationsViewController alloc] initWithEnterType:EMConversationEnterTypeMyChat];
[self.navigationController pushViewController:conversationsVC animated:YES];

5. 我的专属群
  [EaseIMKitManager.shared enterJihuExGroup];

6. 未读总数 
- (void)conversationsUnreadCountUpdate:(NSInteger)unreadCount;
 
7. 专属群未读数
    NSInteger exclusivegroupUnReadCount = EaseIMKitManager.shared.exclusivegroupUnReadCount;
    
8. 退出登录
    [EaseIMKitManager.shared logoutWithCompletion:^(BOOL success, NSString * _Nonnull errorMsg) {
        if (success) {
            EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:@"退出登录成功"];
            [alertView show];
        }else {
            EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:errorMsg];
            [alertView show];
            
            NSLog(@"err:%@",errorMsg);
        }        
    }];
 9. 单聊会话入口
    [EaseIMKitManager.shared enterSingleChatPageWithUserId:@"userid"];


10.极狐Uid 用于查询订单信息
    EaseIMKitManager.shared.jihuCurrentUid = @"jihuAid";
    EaseIMKitManager.shared.jihuToken = @"jihuToken";

    
#运管App
1.  初始化
       EaseIMKitOptions *demoOptions = [EaseIMKitOptions sharedOptions];
    demoOptions.appkey = @"您的appkey";
    [EaseIMKitManager initWithEaseIMKitOptions:demoOptions];


2. 配置UI入口，是否是极狐
  [EaseIMKitManager.shared configuationIMKitIsJiHuApp:[EaseIMKitOptions sharedOptions].isJiHuApp];
 
3. 登录
EaseLoginViewController *controller = [[EaseLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];

4. 会话列表
EMConversationsViewController * conversationsVC=  [[EMConversationsViewController alloc]init];
[self.navigationController pushViewController:conversationsVC animated:YES];

5. 退出登录
    [EaseIMKitManager.shared logoutWithCompletion:^(BOOL success, NSString * _Nonnull errorMsg) {
        if (success) {
            EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:@"退出登录成功"];
            [alertView show];
        }else {
            EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:nil message:errorMsg];
            [alertView show];
            
            NSLog(@"err:%@",errorMsg);
        }        
    }];
    
6. 未读总数 
- (void)conversationsUnreadCountUpdate:(NSInteger)unreadCount;

    
