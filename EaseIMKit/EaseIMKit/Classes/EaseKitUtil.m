//
//  Util.m
//  EaseIM
//
//  Created by liu001 on 2022/7/22.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "EaseKitUtil.h"
#import "EaseIMKitOptions.h"
#import "EaseHeaders.h"
#import "UserInfoStore.h"
#import "MBProgressHUD.h"

@implementation EaseKitUtil

+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font {
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:content attributes:
        @{NSForegroundColorAttributeName:color,
          NSFontAttributeName:font
        }];
    return attrString;
}

+ (void)saveLoginUserToken:(NSString *)token userId:(NSString *)userId {

    NSString *key = [NSString stringWithFormat:@"login_token_%@",userId];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


+ (NSString *)getLoginUserToken {

    NSString *key = [NSString stringWithFormat:@"login_token_%@",[EMClient sharedClient].currentUsername];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (token == nil) {
        token = @"";
    }
    return token;
    
}

+ (void )removeLoginUserToken {
    NSString *key = [NSString stringWithFormat:@"login_token_%@",[EMClient sharedClient].currentUsername];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


+ (UIView *)customNavViewWithTitle:(NSString *)title backAction:(SEL)backAction {
    UIView *contentView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:18];

    UIButton *backImageBtn = [[UIButton alloc]init];
    [backImageBtn addTarget:self action:backAction forControlEvents:UIControlEventTouchUpInside];

    [contentView addSubview:titleLabel];
    [contentView addSubview:backImageBtn];
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//        titleLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
//        [backImageBtn setImage:[UIImage easeUIImageNamed:@"jh_backleft"] forState:UIControlStateNormal];
        
        titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"yg_backleft"] forState:UIControlStateNormal];
        
    }else {
        titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        
        [backImageBtn setImage:[UIImage easeUIImageNamed:@"yg_backleft"] forState:UIControlStateNormal];
    }
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.centerY.equalTo(contentView);
        make.height.equalTo(@25);
    }];

    
    [backImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.centerY.equalTo(titleLabel);
        make.left.equalTo(contentView).offset(16);
    }];
    
    return contentView;
}


+ (UIViewController*)atPersentViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
         
        
        return [self atPersentViewController:vc.presentedViewController];
         
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
         
        
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self atPersentViewController:svc.viewControllers.lastObject];
        else
            return vc;
         
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
         
        
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self atPersentViewController:svc.topViewController];
        else
            return vc;
         
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
         
        
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self atPersentViewController:svc.selectedViewController];
        else
            return vc;
         
    } else {
        return vc;
         
    }
     
}

+ (UIViewController*)currentViewController {
    
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self atPersentViewController:viewController];
     
}

+ (NSBundle *)easeIMBundle {
    NSBundle *tBundle = [NSBundle bundleForClass:self.class];
    NSString* absolutePath = [tBundle pathForResource:@"EaseIMKit" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:absolutePath];
    return bundle;
}

+ (NSDictionary *)fetchUserDicWithUserId:(NSString *)aUid {
    NSString *nickname = @"";
    NSString *avatarUrl = @"";
    
    if (aUid == nil) {
        nickname = @"";
    }else {
        nickname = aUid;
    }
   
    
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUid];
    if(userInfo) {
        if(userInfo.avatarUrl.length > 0) {
            avatarUrl = userInfo.avatarUrl;
        }
        nickname = userInfo.nickname.length > 0 ? userInfo.nickname: userInfo.userId;
        
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[nickname]];
    }
    
    return @{EaseUserNicknameKey:nickname,EaseUserAvatarUrlKey:avatarUrl};
}


+ (NSString *)getContentWithMsg:(EMChatMessage *)msg {
    NSString *msgStr = @"";
    switch (msg.body.type) {
        case EMMessageBodyTypeText:
        {
            EMTextMessageBody *body = (EMTextMessageBody *)msg.body;
            msgStr = body.text;
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLER_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"noRespond", nil);
            }
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"remoteCancel", nil);
            }
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            msgStr = EaseLocalizableString(@"[location]", nil);
        }
            break;
        case EMMessageBodyTypeCustom:
        {
            msgStr = EaseLocalizableString(@"[customemsg]", nil);
        }
            break;
        case EMMessageBodyTypeImage:
        {
            msgStr = EaseLocalizableString(@"[image]", nil);
        }
            break;
        case EMMessageBodyTypeFile:
        {
            msgStr = EaseLocalizableString(@"[file]", nil);
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            msgStr = EaseLocalizableString(@"[audio]", nil);
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            msgStr = EaseLocalizableString(@"[video]", nil);
        }
            break;
            
        default:
            break;
    }
        
    return msgStr;
}

//+ (void)showHint:(NSString *)hint
//{
//
//    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
//
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
//    hud.userInteractionEnabled = NO;
//    // Configure for text only and offset down
//    hud.mode = MBProgressHUDModeText;
//    hud.label.text = hint;
//    hud.margin = 10.f;
//    CGPoint offset = hud.offset;
//    hud.offset = offset;
//    hud.removeFromSuperViewOnHide = YES;
//    [hud hideAnimated:YES afterDelay:2];
//
//}


+ (void)showHint:(NSString *)hint {
    [EaseKitUtil showHint:hint yOffset:0];
}

+ (void)showHint:(NSString *)hint yOffset:(float)yOffset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
        hud.userInteractionEnabled = NO;
        hud.mode = MBProgressHUDModeText;
        hud.label.text = hint;
        hud.margin = 20.f;
        hud.label.font = EaseIMKit_NFont(14.0);
        hud.label.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.color = [UIColor colorWithHexString:@"#252525"];
    //    hud.bezelView.alpha = 0.7;
        hud.bezelView.layer.cornerRadius = 8.0;
        
        CGPoint offset = hud.offset;
        offset.y  += yOffset;
        hud.offset = offset;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:2];
    });
}

+ (CGFloat)getFileSize:(NSString *)path
{
     NSLog(@"%@",path);
     NSFileManager *fileManager = [NSFileManager defaultManager];
     float filesize = -1.0;
     if ([fileManager fileExistsAtPath:path]) {
      NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
      unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
      filesize = 1.0*size/1024;
     }else{
      NSLog(@"找不到文件");
     }
     return filesize;
}

+ (CGFloat) getVideoLength:(NSURL *)URL
{
     AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
     CMTime time = [avUrl duration];
     int second = ceil(time.value/time.timescale);
     return second;
}//此方法可以获取视频文件的时长。

+ (void)appendAPNSAndUserInfoExtWithMessage:(EMChatMessage *)msg {
    //添加自定义离线推送
    NSString *title = @"";
    NSString *content = @"";

    if (msg.chatType == EMChatTypeChat) {
        title = [EaseKitUtil fetchUserDicWithUserId:msg.from][EaseUserNicknameKey];
        content = [EaseKitUtil getContentWithMsg:msg];
    }
    
    if (msg.chatType == EMChatTypeGroupChat) {
        EMGroup *group = [EMGroup groupWithId:msg.conversationId];
        title = group.groupName;
        
        NSString *nickname = [EaseKitUtil fetchUserDicWithUserId:msg.from][EaseUserNicknameKey];
        content = [NSString stringWithFormat:@"%@: %@",nickname,[EaseKitUtil getContentWithMsg:msg]];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableDictionary *pushDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionary];

    if (msg.ext.count > 0) {
        [dic setDictionary:msg.ext];
    }
    
//    @"em_apns_ext":@{
//            @"em_alert_title": @"customTitle",
//            @"em_alert_subTitle": @"customSubTitle",
//            @"em_alert_body": @"customBody"
//        }};


    //    extObject.put("em_push_title", "custom push title");
    //       extObject.put("em_push_content", "custom push content");
    //iOS
    [pushDic setObject:title forKey:@"em_alert_title"];
    [pushDic setObject:content forKey:@"em_alert_body"];
    //andorid
    [pushDic setObject:title forKey:@"em_push_title"];
    [pushDic setObject:content forKey:@"em_push_content"];
    
    [dic setObject:pushDic forKey:@"em_apns_ext"];
    
    //添加个人信息
//    {"ext": {"userInfo": { "im_username": "xxx", "nick":"xx", "avatar":"http://xxx.png"}}}
    NSDictionary *userDic = [EaseKitUtil fetchUserDicWithUserId:[EMClient sharedClient].currentUsername];
    
    [userInfoDic setObject:[EMClient sharedClient].currentUsername forKey:@"im_username"];
    [userInfoDic setObject:userDic[EaseUserNicknameKey] forKey:@"nick"];
    [userInfoDic setObject:userDic[EaseUserAvatarUrlKey] forKey:@"avatar"];

    [dic setObject:userInfoDic forKey:@"userInfo"];

    msg.ext = [dic copy];
    
    NSLog(@"%s msg.ext:%@",__func__,msg.ext);
    
}

+ (BOOL)isValidateMobile:(NSString *)mobile {
    BOOL result = NO;
    if (mobile.length != 11)
       {
           return result;
       }else{
           /**
            * 移动号段正则表达式
            */
           NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
           /**
            * 联通号段正则表达式
            */
           NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
           /**
            * 电信号段正则表达式
            */
           NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
           NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
           BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
           NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
           BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
           NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
           BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
             
           if (isMatch1 || isMatch2 || isMatch3) {
               result = YES;
           }
       }
           return result;
}



+ (NSMutableAttributedString *)attachPictureWithText:(NSString *)text {

    NSLog(@"\n==============%s text:%@",__func__,text);

    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] init];
                    
    __block NSInteger emojiIndex = -1;
    
    NSString *emojiStart = @"[";
    NSString *emojiEnd = @"]";
    
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        NSLog(@"subSting:%@ range:%@ range:%@",substring,[NSValue valueWithRange:substringRange],[NSValue valueWithRange:enclosingRange]);
        
        [attri appendAttributedString:[[NSAttributedString alloc] initWithString:substring]];
        
        if ([substring isEqualToString:emojiStart]) {
            emojiIndex = substringRange.location;
        }
        
        if ([substring isEqualToString:emojiEnd]) {
            //[] 配对
            if (emojiIndex != -1) {
                NSTextAttachment *attch = [[NSTextAttachment alloc] init];
                
                NSRange emojiRange = NSMakeRange(emojiIndex,substringRange.location - emojiIndex + substringRange.length);

                NSString *emojiText = [text substringWithRange:emojiRange];

                NSString *imageName = [EaseEmojiHelper sharedHelper].convertEmojiDic[emojiText];
                
                if (imageName == nil) {
                    //do not exist imageName,do nothing
                }else {
                    attch.image = [UIImage emojiImageWithName:imageName];
                    attch.bounds = CGRectMake(0,0,20,20);

                    NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attch];
                    
                    NSInteger replaceIndex = attri.length - emojiText.length;
                    
                    NSRange replaceRange = NSMakeRange(replaceIndex, emojiText.length);
                    
                    [attri replaceCharactersInRange:replaceRange withAttributedString:attachString];
                    
                    [[EaseEmojiHelper sharedHelper].emojiAttachDic setObject:attch forKey:emojiText];

                    NSDictionary *dic = @{EaseEmojiTextKey:emojiText};
                    [attri addAttributes:dic range:NSMakeRange(replaceRange.location, 1)];
                }
                                
            }

        }
    }];
    
    return attri;
}

@end
