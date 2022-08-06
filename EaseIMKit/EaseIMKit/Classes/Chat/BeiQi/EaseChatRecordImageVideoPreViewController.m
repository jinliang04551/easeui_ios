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


@interface EaseChatRecordImageVideoPreViewController ()
@property (nonatomic, strong) EMChatMessage *message;

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, assign) CGFloat loadingAngle;

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
    [self addPopBackLeftItem];
    [self placeAndLayoutSubViews];
    [self displayImageOrVideo];
}


- (void)placeAndLayoutSubViews {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    }else {
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }

    
    [self.view addSubview:self.iconImageView];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64.0);
        make.left.equalTo(self.view).offset(64.0);
        make.size.equalTo(@(52.0));
    }];

}

- (void)displayImageOrVideo {
    if (self.message.body.type == EMMessageBodyTypeImage) {
        [self displayImage];
    }
    
    if (self.message.body.type == EMMessageBodyTypeVideo) {
        [self displayVideo];
    }
}

- (void)displayImage {
    EMImageMessageBody *body = (EMImageMessageBody*)self.message.body;

    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        if (image) {
            [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self];
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
                    [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self];
                } else {
                    [EaseAlertController showErrorAlert:EaseLocalizableString(@"fetchImageFail", nil)];
                }
            }
        }];

    }

}


- (void)displayVideo {
    
    void (^playBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSURL *videoURL = [NSURL fileURLWithPath:aPathe];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
        playerViewController.modalPresentationStyle = 0;
        [self presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    };

    void (^downloadBlock)(void) = ^ {
        [self showHudInView:self.view hint:EaseLocalizableString(@"downloadVideo...", nil)];
        [[EMClient sharedClient].chatManager downloadMessageAttachment:self.message progress:nil completion:^(EMChatMessage *message, EMError *error) {

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
