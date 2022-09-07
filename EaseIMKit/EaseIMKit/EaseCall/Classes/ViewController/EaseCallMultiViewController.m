//
//  EaseCallMultiViewController.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2020/11/19.
//  Copyright © 2020 lixiaoming. All rights reserved.
//

#import "EaseCallMultiViewController.h"
#import "EaseCallStreamView.h"
#import "EaseCallManager+Private.h"
#import "EaseCallPlaceholderView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import "UIImage+Ext.h"
#import "EaseDefines.h"
#import "UIColor+EaseCall.h"
#import "EaseCallSteamCollectionView.h"
#import "EaseHeaders.h"
#import "EaseCallWaterView.h"

#define kHeadBgAnimationViewSize 80.0

@interface EaseCallMultiViewController ()<EaseCallStreamViewDelegate>
@property (nonatomic) UIButton* inviteButton;
@property (nonatomic) UILabel* statusLabel;
@property (nonatomic) BOOL isJoined;
@property (nonatomic) EaseCallStreamView* bigView;
@property (nonatomic) NSMutableDictionary* placeHolderViewsDic;
@property (atomic) BOOL isNeedLayout;
@property (nonatomic) EaseCallSteamCollectionView* callSteamCollectionView;

@property (nonatomic) EaseCallWaterView* callWaterView;
@property (nonatomic) UIView* remoteCallView;


@end

@implementation EaseCallMultiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
    [self updateViewPos];

}

- (void)floatViewDidTap {
    self.isMini = NO;
    [self.floatingView removeFromSuperview];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    self.modalPresentationStyle = 0;
    [rootViewController presentViewController:self animated:YES completion:nil];
}

- (void)setupSubViews
{
    self.bigView = nil;
    self.isNeedLayout = NO;

    EaseIMKit_WS
    self.floatingView.tapViewBlock = ^{
        [weakSelf floatViewDidTap];
    };
    
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#171717"];

    [self.timeLabel setHidden:YES];
    
    [self.contentView addSubview:self.inviteButton];
    [self.inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.miniButton);
        make.right.equalTo(self.contentView);
        make.width.height.equalTo(@(40));
    }];
    
    [self.contentView bringSubviewToFront:self.inviteButton];
    [self.inviteButton setHidden:YES];
    [self setLocalVideoView:[UIView new] enableVideo:NO];
    {
        if([self.inviterId length] > 0) {
            NSURL* remoteUrl = [[EaseCallManager sharedManager] getHeadImageByUserName:self.inviterId];
            [self.remoteHeadView sd_setImageWithURL:remoteUrl];
            
            self.remoteNameLabel.text = [[EaseCallManager sharedManager] getNicknameByUserName:self.inviterId];
            self.remoteNameLabel.hidden = NO;

            self.answerButton.hidden = NO;
            self.acceptLabel.hidden = YES;
            
            [self.contentView addSubview:self.remoteCallView];
            [self.remoteCallView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).offset(100.0);
                make.centerX.equalTo(self.contentView);
                make.width.equalTo(self.contentView);
                make.height.equalTo(@(EaseIMKit_ScreenHeight * 0.5));
            }];

            [self startCallAnimation];

        }else{
            self.answerButton.hidden = YES;
            self.acceptLabel.hidden = YES;
            [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                CGFloat offset = 26.0 + EaseIMKit_BottomSafeHeight;
                make.bottom.equalTo(self.contentView).offset(-offset);
                make.centerX.equalTo(self.contentView);
                make.width.height.equalTo(@(64.0));

            }];
            
            [self.switchCameraButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.hangupButton.mas_right).offset(52.0);
            }];

            
            self.isJoined = YES;
            self.localView.hidden = NO;
            [self enableVideoAction];
            self.inviteButton.hidden = NO;
        }
    }

    [self.contentView addSubview:self.callSteamCollectionView];
    [self.callSteamCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inviteButton.mas_bottom);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.width.equalTo(@(0));
        make.height.equalTo(@(EaseIMKit_ScreenWidth));
    }];

    
    [self updateViewPos];
}

- (void)startCallAnimation {
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playCallAnimation) userInfo:nil repeats:YES];
}

- (void)playCallAnimation {
    EaseCallWaterView *waterView = [[EaseCallWaterView alloc]initWithFrame:CGRectMake(0, 0, kHeadBgAnimationViewSize, kHeadBgAnimationViewSize)];
    waterView.multiple = 2.5;
    waterView.backgroundColor = [UIColor clearColor];
    [self.remoteCallView addSubview:waterView];
    [self.remoteCallView insertSubview:waterView belowSubview:self.remoteHeadView];
    
    [waterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.remoteHeadView);
        make.centerX.equalTo(self.remoteHeadView);
        make.size.equalTo(@(kHeadBgAnimationViewSize));
    }];
}


- (NSMutableDictionary*)streamViewsDic
{
    if(!_streamViewsDic) {
        _streamViewsDic = [NSMutableDictionary dictionary];
    }
    return _streamViewsDic;
}

- (NSMutableDictionary*)placeHolderViewsDic
{
    if(!_placeHolderViewsDic) {
        _placeHolderViewsDic = [NSMutableDictionary dictionary];
    }
    return _placeHolderViewsDic;
}

- (void)addRemoteView:(UIView*)remoteView member:(NSNumber*)uId enableVideo:(BOOL)aEnableVideo
{
    if([self.streamViewsDic objectForKey:uId])
        return;
    
    
    EaseCallStreamView* view = [[EaseCallStreamView alloc] initWithFrame:CGRectMake(0, 0, KEaseCallStreamViewWidth, KEaseCallStreamViewWidth)];
    view.displayView = remoteView;
    view.enableVideo = aEnableVideo;
    view.delegate = self;
    [view addSubview:remoteView];
    [self.contentView addSubview:view];
    [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
    }];
    [view sendSubviewToBack:remoteView];
    [self.contentView sendSubviewToBack:view];
    [self.streamViewsDic setObject:view forKey:uId];
    [self startTimer];
    [self updateViewPos];
}

- (void)setRemoteViewNickname:(NSString*)aNickname headImage:(NSURL*)url uId:(NSNumber*)aUid
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:aUid];
    if(view) {
        view.nameLabel.text = aNickname;
        [view.bgView sd_setImageWithURL:url];
    }
}

- (void)removeRemoteViewForUser:(NSNumber*)uId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:uId];
    if(view) {
        [view removeFromSuperview];
        [self.streamViewsDic removeObjectForKey:uId];
    }
    [self updateViewPos];
}
- (void)setRemoteMute:(BOOL)aMuted uid:(NSNumber*)uId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:uId];
    if(view) {
        view.enableVoice = !aMuted;
    }
}
- (void)setRemoteEnableVideo:(BOOL)aEnabled uId:(NSNumber*)uId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:uId];
    if(view) {
        view.enableVideo = aEnabled;
    }
    if(view == self.bigView && !aEnabled)
        self.bigView = nil;
    [self updateViewPos];
}

- (void)setLocalVideoView:(UIView*)aDisplayView  enableVideo:(BOOL)aEnableVideo
{
    self.localView = [[EaseCallStreamView alloc] initWithFrame:CGRectMake(0, 0, KEaseCallStreamViewWidth, KEaseCallStreamViewWidth)];
    self.localView.displayView = aDisplayView;
    self.localView.enableVideo = aEnableVideo;
    self.localView.delegate = self;
    [self.localView addSubview:aDisplayView];
    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.localView);
    }];
    [self.localView sendSubviewToBack:aDisplayView];
    [self.contentView addSubview:self.localView];
    [self showNicknameAndAvartarForUsername:[EMClient sharedClient].currentUsername view:self.localView];
    [self.contentView sendSubviewToBack:self.localView];
    [self updateViewPos];
    self.answerButton.hidden = YES;
    self.acceptLabel.hidden = YES;
    
    [self.enableCameraButton setEnabled:YES];
    self.enableCameraButton.selected = YES;
    [self.switchCameraButton setEnabled:YES];
    [self.microphoneButton setEnabled:YES];
    if([self.inviterId length] > 0) {
//        [self.remoteNameLabel removeFromSuperview];
//        [self.statusLabel removeFromSuperview];
//        [self.remoteHeadView removeFromSuperview];
        
        [self.remoteCallView removeFromSuperview];
    }
    self.localView.hidden = YES;
    [[EaseCallManager sharedManager] enableVideo:aEnableVideo];
}

- (UIView*) getViewByUid:(NSNumber*)uId
{
    EaseCallStreamView*view =  [self.streamViewsDic objectForKey:uId];
    if(view)
        return view.displayView;
    UIView *displayview = [UIView new];
    [self addRemoteView:displayview member:uId enableVideo:YES];
    return displayview;
}


- (void)_refreshViewPos
{
    unsigned long count = self.streamViewsDic.count + self.placeHolderViewsDic.count;
    if(self.localView.displayView){
        count++;
    }
    
    int top = 40;
    int bottom = 200;

    if(self.isJoined) {
        
        self.microphoneButton.hidden = NO;
        self.microphoneLabel.hidden = NO;
        self.enableCameraButton.hidden = NO;
        self.enableCameraLabel.hidden = NO;
        self.speakerButton.hidden = NO;
        self.speakerLabel.hidden = NO;
        self.switchCameraButton.hidden = NO;
        self.switchCameraLabel.hidden = YES;

        
    
        NSMutableArray *tArray = [NSMutableArray array];

        if(self.bigView) {
            [self.bigView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
                make.top.equalTo(self.contentView).offset(top);
                make.width.equalTo(@(self.contentView.bounds.size.width));
                make.height.equalTo(@(self.contentView.bounds.size.height-top-bottom));
            }];
            
            if(self.bigView != self.localView) {
                [self.contentView sendSubviewToBack:self.localView];
            }
              
            NSLog(@"=========self.bigView=============");

            [self.contentView sendSubviewToBack:self.localView];
            [tArray addObjectsFromArray:[[self.streamViewsDic allValues] mutableCopy]];

        }else{
            
            NSLog(@"=========notself.bigView=============");
            [tArray addObject:self.localView];
            [tArray addObjectsFromArray:[[self.streamViewsDic allValues] mutableCopy]];
            [tArray addObjectsFromArray:[[self.placeHolderViewsDic allValues] mutableCopy]];
            
        }
                
        NSUInteger itemArrays = tArray.count/4;
        if (tArray.count % 4 > 0) {
            itemArrays += 1;
        }
        
        CGFloat width = itemArrays * EaseIMKit_ScreenWidth;
        
        self.callSteamCollectionView.hidden = NO;
        
        [self.callSteamCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(width));
        }];
        
        [self.callSteamCollectionView updateUIWithMemberArray:tArray];
        
        //所有被邀请的人都超时未接听 挂断电话
        if (!self.inviterId && self.isAllTimeout) {
            [self hangupAction];
        }
        
    }else{
        self.microphoneButton.hidden = YES;
        self.microphoneLabel.hidden = YES;
        self.enableCameraButton.hidden = YES;
        self.enableCameraLabel.hidden = YES;
        self.speakerButton.hidden = YES;
        self.speakerLabel.hidden = YES;
        self.switchCameraButton.hidden = YES;
        self.switchCameraLabel.hidden = YES;
        self.acceptLabel.hidden = YES;
    }
}



- (void)updateViewPos
{
    self.isNeedLayout = YES;
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if(weakself.isNeedLayout) {
            weakself.isNeedLayout = NO;
            [weakself _refreshViewPos];
        }
    });
}



- (void)inviteAction
{
    [[EaseCallManager sharedManager] inviteAction];
}

- (void)answerAction
{
    [super answerAction];
    self.answerButton.hidden = YES;
    self.acceptLabel.hidden = YES;
//    self.statusLabel.hidden = YES;
//    self.remoteNameLabel.hidden = YES;
//    self.remoteHeadView.hidden = YES;
    self.remoteCallView.hidden = YES;
    
    [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = 26.0 + EaseIMKit_BottomSafeHeight;
        make.bottom.equalTo(self.contentView).offset(-offset);  
        make.centerX.equalTo(self.contentView);
        make.width.height.equalTo(@(64.0));
    }];
    
    [self.switchCameraButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hangupButton.mas_right).offset(52.0);
        make.width.height.equalTo(@(64.0));
        make.centerY.equalTo(self.hangupButton);
    }];

    
    self.isJoined = YES;
    self.localView.hidden = NO;
    self.inviteButton.hidden = NO;
    [self enableVideoAction];
}

- (void)hangupAction
{
    [super hangupAction];
}

- (void)muteAction
{
    [super muteAction];
    self.localView.enableVoice = !self.microphoneButton.isSelected;
}

- (void)enableVideoAction
{
    [super enableVideoAction];
    self.localView.enableVideo = self.enableCameraButton.isSelected;
    if(self.localView == self.bigView && !self.localView.enableVideo) {
        self.bigView = nil;
        [self updateViewPos];
    }
}

- (void)setPlaceHolderUrl:(NSURL*)url member:(NSString*)uId
{
    EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:uId];
    if(view)
        return;
    EaseCallPlaceholderView* placeHolderView = [[EaseCallPlaceholderView alloc] init];
    [self.contentView addSubview:placeHolderView];
    [placeHolderView.nameLabel setText:[[EaseCallManager sharedManager] getNicknameByUserName:uId]];
//    NSData* data = [NSData dataWithContentsOfURL:url ];
//    [placeHolderView.placeHolder setImage:[UIImage imageWithData:data]];
    [placeHolderView.placeHolderImageView sd_setImageWithURL:url];
    [self.placeHolderViewsDic setObject:placeHolderView forKey:uId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewPos];
    });
    
}

- (void)removePlaceHolderForMember:(NSString*)aUserName
{
    EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:aUserName];
    if(view)
    {
        [view removeFromSuperview];
        [self.placeHolderViewsDic removeObjectForKey:aUserName];
        [self updateViewPos];
    }
}

- (void)streamViewDidTap:(EaseCallStreamView *)aVideoView
{
//    if(aVideoView == self.floatingView) {
//        self.isMini = NO;
//        [self.floatingView removeFromSuperview];
//        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//        UIViewController *rootViewController = window.rootViewController;
//        self.modalPresentationStyle = 0;
//        [rootViewController presentViewController:self animated:YES completion:nil];
//        return;
//    }
//
//    if(aVideoView == self.bigView) {
//        self.bigView = nil;
//        [self updateViewPos];
//    }else{
//        if(aVideoView.enableVideo)
//        {
//            self.bigView = aVideoView;
//            [self updateViewPos];
//        }
//    }
    
}


- (void)miniAction
{
    self.isMini = YES;
    [super miniAction];
    
    if(self.isJoined) {
        self.floatingView.nameLabel.text = EaseLocalizableString(@"Call in progress",nil);
    }else{
        self.floatingView.nameLabel.text = EaseLocalizableString(@"waitforanswer",nil);
    }
}


- (void)showNicknameAndAvartarForUsername:(NSString*)aUserName view:(UIView*)aView
{
    if([aView isKindOfClass:[EaseCallStreamView class]]) {
        EaseCallStreamView* streamView = (EaseCallStreamView*)aView;
        if(streamView && aUserName.length > 0) {
            streamView.nameLabel.text = [[EaseCallManager sharedManager] getNicknameByUserName:aUserName];
            NSURL* url = [[EaseCallManager sharedManager] getHeadImageByUserName:aUserName];
            NSURL* curUrl = [streamView.bgView sd_imageURL];
            if(!curUrl || (url && ![self isEquivalent:url with:curUrl])) {
                [streamView.bgView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
            }
        }
    }
    
    if([aView isKindOfClass:[EaseCallPlaceholderView class]]) {
        EaseCallPlaceholderView* placeHolderView = (EaseCallPlaceholderView*)aView;
        if(placeHolderView && aUserName.length > 0) {
            placeHolderView.nameLabel.text = [[EaseCallManager sharedManager] getNicknameByUserName:aUserName];
            NSURL* url = [[EaseCallManager sharedManager] getHeadImageByUserName:aUserName];
            if(url) {
                [placeHolderView.placeHolderImageView sd_setImageWithURL:url completed:nil];
            }
        }
    }
    
}

- (void)usersInfoUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super usersInfoUpdated];
        [self showNicknameAndAvartarForUsername:[EMClient sharedClient].currentUsername view:self.localView];
        for(NSNumber* uid in self.streamViewsDic) {
            NSString * username = [[EaseCallManager sharedManager] getUserNameByUid:uid];
            NSLog(@"%s username:%@",__func__,username);
            
            if(username.length > 0) {
                EaseCallStreamView* view = [self.streamViewsDic objectForKey:uid];
                [self showNicknameAndAvartarForUsername:username view:view];
            }
        }
        for(NSString* username in self.placeHolderViewsDic) {
            EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:username];
            [self showNicknameAndAvartarForUsername:username view:view];
        }
    });
    
//    [self updateViewPos];

}

- (BOOL)isEquivalent:(NSURL *)aURL1 with:(NSURL *)aURL2 {

    if ([aURL1 isEqual:aURL2]) return YES;
    if ([[aURL1 scheme] caseInsensitiveCompare:[aURL2 scheme]] != NSOrderedSame) return NO;
    if ([[aURL1 host] caseInsensitiveCompare:[aURL2 host]] != NSOrderedSame) return NO;

    // NSURL path is smart about trimming trailing slashes
    // note case-sensitivty here
    if ([[aURL1 path] compare:[aURL2 path]] != NSOrderedSame) return NO;

    // at this point, we've established that the urls are equivalent according to the rfc
    // insofar as scheme, host, and paths match

    // according to rfc2616, port's can weakly match if one is missing and the
    // other is default for the scheme, but for now, let's insist on an explicit match
    if ([aURL1 port] || [aURL2 port]) {
        if (![[aURL1 port] isEqual:[aURL2 port]]) return NO;
        if (![[aURL1 query] isEqual:[aURL2 query]]) return NO;
    }

    // for things like user/pw, fragment, etc., seems sensible to be
    // permissive about these.
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark getter and setter
- (EaseCallSteamCollectionView *)callSteamCollectionView {
    if (_callSteamCollectionView == nil) {
        _callSteamCollectionView = [[EaseCallSteamCollectionView alloc] init];
        _callSteamCollectionView.hidden = YES;
    }
    return _callSteamCollectionView;
}

- (UIButton *)inviteButton {
    if (_inviteButton == nil) {
        _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inviteButton setImage:[UIImage imageNamedFromBundle:@"invite"] forState:UIControlStateNormal];
        [_inviteButton addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inviteButton;
}


- (UIImageView *)remoteHeadView {
    if (_remoteHeadView == nil) {
        _remoteHeadView = [[UIImageView alloc] init];
        _remoteHeadView.layer.cornerRadius = 80 * 0.5;
        _remoteHeadView.clipsToBounds = YES;
    }
    return _remoteHeadView;
}

- (UILabel *)remoteNameLabel {
    if (_remoteNameLabel == nil) {
        _remoteNameLabel = [[UILabel alloc] init];
        _remoteNameLabel.backgroundColor = [UIColor clearColor];
        _remoteNameLabel.textColor = [UIColor whiteColor];
        _remoteNameLabel.textAlignment = NSTextAlignmentRight;
        _remoteNameLabel.font = [UIFont systemFontOfSize:16.0];
        _remoteNameLabel.hidden = YES;
    }
    return _remoteNameLabel;
}


- (EaseCallWaterView *)callWaterView {
    if (_callWaterView == nil) {
        _callWaterView = [[EaseCallWaterView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        _callWaterView.backgroundColor = UIColor.greenColor;
        
    }
    return _callWaterView;
}


- (UIView *)remoteCallView {
    if (_remoteCallView == nil) {
        _remoteCallView = [[UIView alloc] init];
        
        [_remoteCallView addSubview:self.remoteHeadView];
        [self.remoteHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_remoteCallView).offset(80.0);
            make.width.height.equalTo(@(80.0));
            make.centerX.equalTo(_remoteCallView);
        }];


        [_remoteCallView addSubview:self.remoteNameLabel];
        [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.remoteHeadView.mas_bottom).offset(100.0);
            make.centerX.equalTo(_remoteCallView);
        }];

        [_remoteCallView addSubview:self.statusLabel];
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.remoteNameLabel.mas_bottom).offset(5.0);
            make.centerX.equalTo(_remoteCallView);
        }];
                
    }
    return _remoteCallView;
}


- (UILabel *)statusLabel {
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = [UIFont systemFontOfSize:12.0];
        _statusLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.text = EaseLocalizableString(@"receiveCallInviteprompt",nil);
    }
    return _statusLabel;
}


@end

#undef kHeadBgAnimationViewSize

