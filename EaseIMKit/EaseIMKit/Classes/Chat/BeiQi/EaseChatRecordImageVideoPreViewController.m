//
//  EaseChatRecordImageVideoPreViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/31.
//

#import "EaseChatRecordImageVideoPreViewController.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EaseHeaders.h"
#import "EMImageBrowser.h"
#import <AVKit/AVKit.h>


@interface EaseChatRecordImageVideoPreViewController (){
    id _observer;
}

@property (nonatomic, strong) EMChatMessage *message;

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, assign) CGFloat loadingAngle;

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avLayer;

@property (nonatomic, strong) UIView *titleView;

@end

@implementation EaseChatRecordImageVideoPreViewController
- (instancetype)initWithMessage:(EMChatMessage *)message {
    self = [super init];
    if(self){
        self.message = message;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self placeAndLayoutSubViews];
    [self displayImageOrVideo];
}


- (void)placeAndLayoutSubViews {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    }else {
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }

    
    self.titleView = [self customNavWithTitle:@"" rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];

    [self.view addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom).offset(64.0);
        make.left.equalTo(self.view).offset(64.0);
        make.size.equalTo(@(52.0));
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

- (void)displayImageOrVideo {
    if (self.message.body.type == EMMessageBodyTypeImage) {
        [self showImage];
    }
    
    if (self.message.body.type == EMMessageBodyTypeVideo) {
        [self showVideo];
    }
}

- (void)showImage {
    EMImageMessageBody *body = (EMImageMessageBody*)self.message.body;

    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        if (image) {
            [self showImageWithImages:@[image]];

            return;
        }
    }else {
        [self startAnimation];
        
        [[EMClient sharedClient].chatManager downloadMessageAttachment:self.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
            self.loadingImageView.hidden = YES;
            
            if (error) {
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"downloadImageFail", nil)];
                
            } else {
            
                NSString *localPath = [(EMImageMessageBody *)message.body localPath];
                UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                if (image) {
                    [self showImageWithImages:@[image]];
                } else {
                    [EaseAlertController showErrorAlert:EaseLocalizableString(@"fetchImageFail", nil)];
                }
            }
        }];

    }

}

- (void)showImageWithImages:(NSArray *)images {
    EMImageBrowser *browserVC = [EMImageBrowser sharedBrowser];
    browserVC.dismissBlock = ^{
        [self.navigationController popViewControllerAnimated:NO];
    };
    [browserVC showImages:images fromController:self];

}

//点播
- (void)startPlayVodStream:(NSURL *)vodStreamUrl
{
    //设置播放的项目
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:vodStreamUrl];
    //初始化player对象
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    //设置播放页面
    self.avLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    //设置播放页面的大小
    self.avLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.avLayer.backgroundColor = [UIColor clearColor].CGColor;
    //设置播放窗口和当前视图之间的比例显示内容
    self.avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //添加播放视图到self.view
    [self.view.layer insertSublayer:self.avLayer atIndex:0];
    //设置播放的默认音量值
    self.avPlayer.volume = 1.0f;
    [self.avPlayer play];
    [self addProgressObserver: [vodStreamUrl absoluteString]];
}

// 视频循环播放
- (void)vodPlayDidEnd:(NSDictionary*)dic{
    [self.avLayer removeFromSuperlayer];
    self.avPlayer = nil;
    NSURL *pushUrl = [NSURL URLWithString:[dic objectForKey:@"pushurl"]];
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(0, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    AVPlayerItem *item = [dic objectForKey:@"playItem"];
    [item seekToTime:kCMTimeZero];
//    [self startPlayVodStream:pushUrl];
}


-(void)addProgressObserver:(NSString*)url {
    __weak typeof(self) weakSelf = self;
    AVPlayerItem *playerItem=self.avPlayer.currentItem;
    _observer = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        if ((current > 0 && total > 0) && ((int)current == (int)total)) {
            [weakSelf vodPlayDidEnd:@{@"pushurl":url, @"playItem":weakSelf.avPlayer.currentItem}];
        }
    }];
}




- (void)showVideo {
    
    void (^playBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSURL *videoURL = [NSURL fileURLWithPath:aPathe];
//        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//        playerViewController.player = [AVPlayer playerWithURL:videoURL];
//        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
//        playerViewController.showsPlaybackControls = YES;
//        playerViewController.modalPresentationStyle = 0;
//        [self presentViewController:playerViewController animated:YES completion:^{
//            [playerViewController.player play];
//        }];
      
        
//    AVPlayer *player=[AVPlayer playerWithURL:videoURL];
//    player.rate = 1.0;
//    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:player];
//    playerLayer.frame = CGRectMake(0, 0, EaseIMKit_ScreenWidth, 300);
//    [self.view.layer addSublayer:playerLayer];
//    [player play];
    [self startPlayVodStream:videoURL];
        
    };

    void (^downloadBlock)(void) = ^ {
        [self showHudInView:self.view hint:EaseLocalizableString(@"downloadVideo...", nil)];
        [[EMClient sharedClient].chatManager downloadMessageAttachment:self.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
            [self hideHud];
            
            if (error) {
                [EaseAlertController showErrorAlert:@"下载视频失败"];
            } else {
                if (!message.isReadAcked) {
                    [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
                }
                playBlock([(EMVideoMessageBody*)message.body localPath]);
            }
        }];
    };
    
    EMVideoMessageBody *body = (EMVideoMessageBody*)self.message.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EaseAlertController showInfoAlert:EaseLocalizableString(@"downloadingVideo...", nil)];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed || ![fileManager fileExistsAtPath:body.thumbnailLocalPath]) {
        [self showHint:EaseLocalizableString(@"downloadThumnail", nil)];
    }
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        playBlock(body.localPath);
    } else {
        if (!isCustomDownload) {
            downloadBlock();
        }
    }
    
}



#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.masksToBounds = YES;
        
        [_iconImageView addSubview:self.loadingImageView];
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_iconImageView);
        }];
        
    }
    return _iconImageView;
}

- (UIImageView *)loadingImageView {
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFill;
        _loadingImageView.image = [UIImage easeUIImageNamed:@"yg_loading_image"];
        _loadingImageView.hidden = YES;
    }
    return _loadingImageView;
}

- (void)startAnimation {
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(self.loadingAngle * (M_PI /180.0f));

    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.loadingImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        self.loadingAngle += 15;
        [self startAnimation];
    }];
}

@end
