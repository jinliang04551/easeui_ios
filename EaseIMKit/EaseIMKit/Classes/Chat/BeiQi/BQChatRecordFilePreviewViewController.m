//
//  BQChatRecordFilePreviewViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/23.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordFilePreviewViewController.h"
#import "EaseHeaders.h"

@interface BQChatRecordFilePreviewViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIProgressView* progressView;

@property (nonatomic, strong) UIButton *operateButton;
@property (nonatomic, strong) EMChatMessage *message;

@end

@implementation BQChatRecordFilePreviewViewController
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
    [self updateUI];
}


- (void)placeAndLayoutSubViews {
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
}else {
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
}

    
    [self.view addSubview:self.iconImageView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.sizeLabel];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.operateButton];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64.0);
        make.left.equalTo(self.view).offset(64.0);
        make.size.equalTo(@(52.0));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(12.0);
        make.left.equalTo(self.view).offset(64.0);
        make.right.equalTo(self.view).offset(-64.0);
    }];

    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4.0);
        make.left.equalTo(self.view).offset(64.0);
        make.right.equalTo(self.view).offset(-64.0);
        
    }];

    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.operateButton.mas_top).offset(-30.0);
        make.left.equalTo(self.view).offset(58.0);
        make.right.equalTo(self.view).offset(-58.0);
        make.height.equalTo(@(10.0));
    }];

    
    [self.operateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-260.0);
        make.left.equalTo(self.view).offset(58.0);
        make.right.equalTo(self.view).offset(-58.0);
        make.height.equalTo(@(44.0));
    }];
    
    
}

- (void)updateUI {
    EMFileMessageBody *fileBody = (EMFileMessageBody *)self.message.body;
    
    NSString *filename = [fileBody.displayName pathExtension];
    [self  displayFileIconWithFilename:filename];

    
    self.nameLabel.text = fileBody.displayName;
    self.sizeLabel.text = [NSString stringWithFormat:@"%1.fKB",fileBody.fileLength/1024.0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (fileBody.downloadStatus == EMDownloadStatusSucceed &&[fileManager fileExistsAtPath:fileBody.localPath]) {
        [self.operateButton setTitle:@"打开文件" forState:UIControlStateNormal];
        self.progressView.hidden = YES;
        
    }else {
        [self.operateButton setTitle:@"开始下载" forState:UIControlStateNormal];
        self.progressView.hidden = NO;
        
        [[EMClient sharedClient].chatManager downloadMessageAttachment:self.message progress:^(int progress) {
            self.progressView.progress = progress;
            
        } completion:^(EMChatMessage * _Nullable message, EMError * _Nullable error) {
        
            if (error) {
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"downFileFail", nil)];
            } else {
                [self operateButtonAction];
            }

            
        }];
    }
}

- (void)displayFileIconWithFilename:(NSString *)filename {
    NSString *fileSurfix = [filename lastPathComponent];
    
    BOOL hasSurfix = NO;
    if ([fileSurfix isEqualToString:@"doc"]) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_doc"];
        hasSurfix = YES;
    }
    
    
    if ([fileSurfix isEqualToString:@"docx"]) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_docx"];
        hasSurfix = YES;
    }
    
    //xls/xlsx
    if ([fileSurfix isEqualToString:@"xls"]||[fileSurfix isEqualToString:@"xlsx"]) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_exel"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"png"] ||[fileSurfix isEqualToString:@"jpg"] ||[fileSurfix isEqualToString:@"webp"]) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_img"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"pdf"]) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_pdf"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"ppt"]) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_ppt"];
        hasSurfix = YES;
    }
    
    if ([fileSurfix isEqualToString:@"txt"]) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_text"];
        hasSurfix = YES;
    }
    

    if (!hasSurfix) {
        self.iconImageView.image = [UIImage easeUIImageNamed:@"msg_file_other"];
    }

}


- (void)operateButtonAction {

#if TARGET_IPHONE_SIMULATOR
    [EaseAlertController showErrorAlert:@"模拟器无法打开文件"];
#elif TARGET_OS_IPHONE
    NSString *fileLocalPath = [(EMFileMessageBody*)self.message.body localPath];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fileLocalPath];
    NSLog(@"\nfile  --    :%@",[fileHandle readDataToEndOfFile]);
    [fileHandle closeFile];
    UIDocumentInteractionController *docVc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileLocalPath]];
    docVc.delegate = self;
    [docVc presentPreviewAnimated:YES];

#endif

}


#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}



#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = EaseIMKit_NFont(16.0);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.numberOfLines = 0;
        
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        _nameLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
}else {
        _nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
}
        
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel {
    if (_sizeLabel == nil) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.font = EaseIMKit_NFont(10.0);
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        _sizeLabel.textColor = [UIColor colorWithHexString:@"#F5F5F5"];
}else {
        _sizeLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
}
        
    }
    return _sizeLabel;
}

- (UIButton *)operateButton {
    if (_operateButton == nil) {
        _operateButton = [[UIButton alloc] init];
        _operateButton.contentMode = UIViewContentModeScaleAspectFit;
        [_operateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _operateButton.titleLabel.font = EaseIMKit_NFont(14.0);
        _operateButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
        [_operateButton addTarget:self action:@selector(operateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operateButton;
    
}

- (UIProgressView *)progressView
{
    if (!_progressView){
        _progressView = UIProgressView.new;
        _progressView.tintColor = [UIColor colorWithHexString:@"#4798CB"];
//        _progressView.trackTintColor = [UIColor colorWithHexString:@"#F5F5F5"];
        _progressView.trackTintColor = UIColor.lightGrayColor;
        _progressView.layer.cornerRadius = 10.0 * 0.5;
    }
    return _progressView;
}


@end
