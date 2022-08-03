//
//  YGGroupYunGuanRemarkViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/21.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupYunGuanRemarkViewController.h"
#import "EaseTextView.h"
#import "EaseHeaders.h"

@interface YGTextView : UIView
@property (nonatomic, strong) EaseTextView *textView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end


@implementation YGTextView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    self.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.titleLabel];
    [self addSubview:self.iconImageView];
    [self addSubview:self.textView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28.0);
        make.left.equalTo(self).offset(16.0);
        
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.left.equalTo(self.titleLabel.mas_right).offset(16.0);
        make.size.equalTo(@(14.0));
        
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8.0);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self).offset(-16.0);
        make.height.equalTo(@(150.0));
    }];
    
}


#pragma mark getter and setter
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = EaseIMKit_BFont(14.0);
        _titleLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}


- (EaseTextView *)textView {
    if (_textView == nil) {
        _textView = [[EaseTextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.backgroundColor = UIColor.clearColor;
    }
    return _textView;
}

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_iconImageView setImage:[UIImage easeUIImageNamed:@"yg_edit_icon"]];
    }
    
    return _iconImageView;
}


@end


@interface YGGroupYunGuanRemarkViewController ()<UITextViewDelegate>

@property (nonatomic, strong) NSString *originalString;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) BOOL isEditable;

@property (nonatomic, strong) YGTextView *systemTextView;
@property (nonatomic, strong) YGTextView *yunGuanTextView;
@property (nonatomic, strong) NSString *systemString;
@property (nonatomic, strong) NSString *groupId;

@end

@implementation YGGroupYunGuanRemarkViewController

- (instancetype)initWithSystemmark:(NSString *)aSystemString
                          yGString:(NSString *)aString
                       placeholder:(NSString *)aPlaceholder
                        isEditable:(BOOL)aIsEditable
{
    self = [super init];
    if (self) {
        _systemString = aSystemString;
        _originalString = aString;
        _placeholder = aPlaceholder;
        _isEditable = aIsEditable;
    }
    
    return self;
}


- (instancetype)initWithGroupId:(NSString *)groupId {
    self = [super init];
    if (self) {
        self.groupId = groupId;
        self.isEditable = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"运营备注";
    [self _setupSubviews];
    [self fetchNoteInfo];
    
}

- (void)fetchNoteInfo {
    
    [[EaseHttpManager sharedManager] fetchYunGuanNoteWithGroupId:self.groupId completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSDictionary *entity = responsedict[@"entity"];
                NSString *note = entity[@"noteAdmin"];
                self.yunGuanTextView.textView.text = note;
                
            }else {
                [EaseAlertController showErrorAlert:errorDescription];
            }
        }
        
    }];
    
    [self.yunGuanTextView.textView becomeFirstResponder];
    
}


- (float)heightForString:(UITextView *)textView andWidth:(float)width{
     CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}


#pragma mark - Subviews
- (void)_setupSubviews
{
    self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;

    [self addPopBackLeftItem];
    
    if (self.isEditable) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    }
    
    [self setRightNavBarItemTitleColor];

    
    [self.view addSubview:self.systemTextView];
    [self.view addSubview:self.yunGuanTextView];
    
    [self.systemTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(190.0));
    }];
    
    [self.yunGuanTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.systemTextView.mas_bottom).offset(12.0);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (void)doneAction
{
    [self.view endEditing:YES];
    
    [[EaseHttpManager sharedManager] editServeNoteWithGroupId:self.groupId note:self.yunGuanTextView.textView.text completion:^(NSInteger statusCode, NSString * _Nonnull response) {
            
        if (response && response.length > 0 && statusCode) {
            NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorDescription = [responsedict objectForKey:@"errorDescription"];
            if (statusCode == 200) {
                NSDictionary *entity = responsedict[@"entity"];
                NSString *groupId = entity[@"groupId"];
                
                if (groupId.length > 0) {
                    [self showHint:@"修改运管备注成功"];
                    if(self.doneCompletion) {
                        self.doneCompletion(self.systemTextView.textView.text);
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else {
                [EaseAlertController showErrorAlert:errorDescription];
            }
        }
        
    }];
}


#pragma mark getter and setter
- (YGTextView *)systemTextView {
    if (_systemTextView == nil) {
        _systemTextView = [[YGTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _systemTextView.titleLabel.text = @"系统备注";
        _systemTextView.iconImageView.hidden = YES;
        _systemTextView.textView.editable = NO;
        _systemTextView.textView.text = self.systemString;
        
    }
    return _systemTextView;
}


- (YGTextView *)yunGuanTextView {
    if (_yunGuanTextView == nil) {
        _yunGuanTextView = [[YGTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _yunGuanTextView.titleLabel.text = @"服务备注";
        _yunGuanTextView.textView.delegate = self;
        _yunGuanTextView.textView.textColor = [UIColor colorWithHexString:@"#171717"];
        
//        if (!self.isEditable){
//            _yunGuanTextView.textView.placeholder = NSLocalizedString(@"editRight", nil);
//        }else {
//            _yunGuanTextView.textView.placeholder = self.placeholder;
//        }
//
//        if (self.originalString && ![self.originalString isEqualToString:@""]) {
//            _yunGuanTextView.textView.text = self.originalString;
//        }
//        _yunGuanTextView.textView.editable = self.isEditable;

    }
    return _yunGuanTextView;
}



@end
