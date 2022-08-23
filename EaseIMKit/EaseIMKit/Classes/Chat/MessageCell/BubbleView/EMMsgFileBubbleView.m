//
//  EMMsgFileBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgFileBubbleView.h"

@interface EMMsgFileBubbleView ()
{
    EaseChatViewModel *_viewModel;
}

@end
@implementation EMMsgFileBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        _viewModel = viewModel;
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self setupBubbleBackgroundImage];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(230.0));
        make.height.equalTo(@(66.0));
    }];
    
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.clipsToBounds = YES;
    [self addSubview:self.iconView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.numberOfLines = 2;
    [self addSubview:self.textLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:10];
    self.detailLabel.numberOfLines = 0;
    
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.textLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        self.detailLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];

    }else {
        self.textLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        self.detailLabel.textColor = [UIColor colorWithHexString:@"#252525"];

    }
    
    
    
    [self addSubview:self.detailLabel];
    [self.detailLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.textLabel.ease_bottom).offset(4.0);
        make.left.equalTo(self.textLabel);
        make.right.equalTo(self).offset(-15);
        make.height.equalTo(@(12.0));
    }];
    
    self.downloadStatusLabel = [[UILabel alloc] init];
    self.downloadStatusLabel.font = [UIFont systemFontOfSize:10];
    self.downloadStatusLabel.numberOfLines = 0;
    self.downloadStatusLabel.textAlignment = NSTextAlignmentRight;
    self.downloadStatusLabel.textColor = [UIColor colorWithRed:173/255.0 green:173/255.0 blue:173/255.0 alpha:1.0];
    [self addSubview:self.downloadStatusLabel];
    [self.downloadStatusLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.textLabel.ease_bottom).offset(16);
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(self.ease_centerX);
        make.right.equalTo(self.textLabel);
    }];
    
    
    
    if (self.direction == EMMessageDirectionSend) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_white"];
        [self.iconView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self).offset(12.0);
            make.left.equalTo(self).offset(15.0);
            make.centerY.equalTo(self);
            make.size.equalTo(@(44.0));
        }];
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self).offset(9.0);
            make.left.equalTo(self.iconView.ease_right).offset(10.0);
            make.right.equalTo(self).offset(-10.0);
        }];

    } else {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file"];
        [self.iconView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self).offset(12.0);
            make.left.equalTo(self).offset(15.0);
            make.centerY.equalTo(self);
            make.size.equalTo(@(44.0));
        }];
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self).offset(9.0);
            make.left.equalTo(self.iconView.ease_right).offset(10.0);
            make.right.equalTo(self).offset(-10.0);
        }];
        
    }
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeFile) {
        EMFileMessageBody *body = (EMFileMessageBody *)model.message.body;
//        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:body.displayName];
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.lineSpacing = 5.0; // 设置行间距
//        paragraphStyle.alignment = NSTextAlignmentLeft;
//        [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedStr.length)];
//        [attributedStr addAttribute:NSKernAttributeName value:@0.34 range:NSMakeRange(0, attributedStr.length)];
//
//        self.textLabel.attributedText = attributedStr;
        self.textLabel.text = body.displayName;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.detailLabel.text = [NSString stringWithFormat:@"%.2lf MB",(float)body.fileLength / (1024 * 1024)];
        
        if (self.direction == EMMessageDirectionReceive && body.downloadStatus == EMDownloadStatusSucceed) {
            self.downloadStatusLabel.text = EaseLocalizableString(@"downloaded", nil);
        } else {
            self.downloadStatusLabel.text = @"";
        }
        
        NSString *filename = [body.displayName pathExtension];
        [self  displayFileIconWithFilename:filename];
    }
}

- (void)displayFileIconWithFilename:(NSString *)filename {
    NSString *fileSurfix = [filename lastPathComponent];
    
    BOOL hasSurfix = NO;
    if ([fileSurfix isEqualToString:@"doc"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_doc"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"docx"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_docx"];
        hasSurfix = YES;
    }
    
    //xls/xlsx
    if ([fileSurfix isEqualToString:@"xls"]||[fileSurfix isEqualToString:@"xlsx"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_exel"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"png"] ||[fileSurfix isEqualToString:@"jpg"] ||[fileSurfix isEqualToString:@"webp"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_img"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"pdf"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_pdf"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"ppt"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_ppt"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"txt"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_text"];
        hasSurfix = YES;
    }

    if ([fileSurfix isEqualToString:@"mov"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_mov"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"mp4"]) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_mp4"];
        hasSurfix = YES;
    }
    
    if (!hasSurfix) {
        self.iconView.image = [UIImage easeUIImageNamed:@"msg_file_other"];
    }

}



@end
