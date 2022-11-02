//
//  EMMsgVideoBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgVideoBubbleView.h"
#import "UIImageView+EaseWebCache.h"

#define kEMMsgImageDefaultSize 120
#define kEMMsgImageMinWidth 50
#define kEMMsgImageMaxWidth 120
#define kEMMsgImageMaxHeight 260


@implementation EMMsgVideoBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
    }
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.shadowView = [[UIView alloc] init];
//    self.shadowView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    self.shadowView.backgroundColor = [UIColor colorWithHexString:@"#252525"];
        
//    [self addSubview:self.shadowView];
//    [self.shadowView Ease_makeConstraints:^(EaseConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
    
    self.playImgView = [[UIImageView alloc] init];
    self.playImgView.image = [UIImage easeUIImageNamed:@"msg_video_white"];
    self.playImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.playImgView];
    [self.playImgView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(@50);
    }];
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeVideo) {
        EMVideoMessageBody *body = (EMVideoMessageBody *)model.message.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0 && model.direction == EMMessageDirectionSend) {
            imgPath = body.localPath;
        }
        if (body.thumbnailSize.height == 0 || body.thumbnailSize.width == 0) {
            NSBundle *resource_bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"/Frameworks/EaseIMKit.framework" ofType:nil]];
            if (!resource_bundle) {
                resource_bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Frameworks/EaseIMKit.framework" ofType:nil]];
            }
            imgPath = [resource_bundle pathForResource:@"video_default_thumbnail" ofType:@"png"];
        }
        [self setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath thumbImgSize:body.thumbnailSize imgSize:body.thumbnailSize];
    }
}

#pragma mark - Private

- (CGSize)_getImageSize:(CGSize)aSize
{
    CGSize retSize = CGSizeZero;
    do {
        if (aSize.width == 0 || aSize.height == 0) {
            break;
        }
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width / 2 - 60.0;
        NSInteger tmpWidth = aSize.width;
        if (aSize.width < kEMMsgImageMinWidth) {
            tmpWidth = kEMMsgImageMinWidth;
        }
        if (aSize.width > kEMMsgImageMaxWidth) {
            tmpWidth = kEMMsgImageMaxWidth;
        }
        
        NSInteger tmpHeight = tmpWidth / aSize.width * aSize.height;
        if (tmpHeight > kEMMsgImageMaxHeight) {
            tmpHeight = kEMMsgImageMaxHeight;
        }
        retSize = CGSizeMake(tmpWidth, tmpHeight);
        
    } while (0);
    
    return retSize;
}

- (void)setThumbnailImageWithLocalPath:(NSString *)aLocalPath
                            remotePath:(NSString *)aRemotePath
                          thumbImgSize:(CGSize)aThumbSize
                               imgSize:(CGSize)aSize
{
    UIImage *img = nil;
    if ([aLocalPath length] > 0) {
        img = [UIImage imageWithContentsOfFile:aLocalPath];
    }
    
    __weak typeof(self) weakself = self;
    void (^block)(CGSize aSize) = ^(CGSize aSize) {
        CGSize layoutSize = [weakself _getImageSize:aSize];
        [weakself Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(layoutSize.width);
            make.height.Ease_equalTo(layoutSize.height);
        }];
    };
    
    CGSize size = CGSizeMake(100, 150);
    
    if (img) {
        self.image = img;
        block(size);
    } else {
        block(size);
        BOOL isAutoDownloadThumbnail = ([EMClient sharedClient].options.isAutoDownloadThumbnail);
        if (isAutoDownloadThumbnail) {
            [self Ease_setImageWithURL:[NSURL URLWithString:aRemotePath] placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {}];
        } else {
            self.image = [UIImage easeUIImageNamed:@"msg_img_broken"];
        }
    }
}

@end
