//
//  EaseRecordImageVideoCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/17.
//

#import "EaseRecordImageVideoCell.h"
#import <HyphenateChat/HyphenateChat.h>
#import <Masonry/Masonry.h>
#import "EaseHeaders.h"
#import "EaseMessageModel.h"

@interface EaseRecordImageVideoCell ()
@property (nonatomic, strong) UIImageView *iconImageView;

@end



@implementation EaseRecordImageVideoCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
    self.contentView.backgroundColor = UIColor.yellowColor;
    
    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

}


- (void)updateWithObj:(id)obj {
    EMChatMessage *msg = (EMChatMessage *)obj;
    NSString *urlString = @"";
    NSString *imgPath = @"";
    
    if(msg.body.type == EMMessageBodyTypeImage) {
        EMImageMessageBody* imageBody = (EMImageMessageBody*)msg.body;
        imgPath = imageBody.thumbnailLocalPath;
        if ([imgPath length] == 0 && msg.direction == EMMessageDirectionSend) {
            imgPath = imageBody.localPath;
        }else {
            urlString = imageBody.thumbnailRemotePath;
        }
        
    }
    
    if(msg.body.type == EMMessageBodyTypeVideo) {
        EMVideoMessageBody* videoBody = (EMVideoMessageBody*)msg.body;
        imgPath = videoBody.thumbnailLocalPath;
        if ([imgPath length] == 0 && msg.direction == EMMessageDirectionSend) {
            imgPath = videoBody.localPath;
        }else {
            urlString = videoBody.thumbnailRemotePath;
        }
        
        if (videoBody.thumbnailSize.height == 0 || videoBody.thumbnailSize.width == 0) {
            imgPath = @"";
        }
    }
    
    if (imgPath.length > 0) {
        [self.iconImageView setImage:[UIImage easeUIImageNamed:imgPath]];
    }else {
        BOOL isAutoDownloadThumbnail = ([EMClient sharedClient].options.isAutoDownloadThumbnail);
        if (isAutoDownloadThumbnail) {
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"]];
        } else {
            [self.iconImageView setImage:[UIImage easeUIImageNamed:@"msg_img_broken"]];
        }
    }
}


- (void)setModel:(EaseMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeImage) {
        EMImageMessageBody *body = (EMImageMessageBody *)model.message.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0 && model.direction == EMMessageDirectionSend) {
            imgPath = body.localPath;
        }
        
    }
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.layer.cornerRadius = 8.0f;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.masksToBounds = YES;
    }
    
    return _iconImageView;
}

@end

