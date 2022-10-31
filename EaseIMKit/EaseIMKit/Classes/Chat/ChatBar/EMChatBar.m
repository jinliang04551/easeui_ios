//
//  EMChatBar.m
//  ChatDemo-UI3.0
//
//  Updated by zhangchong on 2020/06/05.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBar.h"
#import "UIImage+EaseUI.h"
#import "UIColor+EaseUI.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"

#define kTextViewMinHeight 32
#define kTextViewMaxHeight 80
#define kIconwidth 28
#define kModuleMargin 10

@interface EMChatBar()<UITextViewDelegate>

@property (nonatomic) CGFloat version;

@property (nonatomic) CGFloat previousTextViewContentHeight;

@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIView *currentMoreView;
@property (nonatomic, strong) UIButton *conversationToolBarBtn;//更多
@property (nonatomic, strong) UIButton *emojiButton;//表情
@property (nonatomic, strong) UIButton *audioButton;//语音
@property (nonatomic, strong) UIView *bottomLine;//下划线
//@property (nonatomic, strong) UIButton *audioDescBtn;
@property (nonatomic, strong) EaseChatViewModel *viewModel;

@property (nonatomic, strong) NSString *textViewInsertText;
@property (nonatomic, assign) NSRange textViewInsertRange;

@end

@implementation EMChatBar

- (instancetype)initWithViewModel:(EaseChatViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _previousTextViewContentHeight = kTextViewMinHeight;
        _viewModel = viewModel;
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.backgroundColor = _viewModel.chatBarBgColor;
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#2E2E2E"];
    line.alpha = 0.1;
    [self addSubview:line];
    [line Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@0.5);
    }];
    
//    self.audioButton = [[UIButton alloc] init];
//    [self.audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.audioButton];
    [self addSubview:self.textView];
    [self addSubview:self.emojiButton];
    [self addSubview:self.conversationToolBarBtn];

    
    [self.audioButton Ease_makeConstraints:^(EaseConstraintMaker *make) {
//        make.top.equalTo(self).offset(14.0);
        make.bottom.equalTo(self.textView.ease_bottom);
        make.left.equalTo(self).offset(12.0);
        make.width.Ease_equalTo(@(28));
        make.height.Ease_equalTo(@(28));
    }];
    
//    self.conversationToolBarBtn = [[UIButton alloc] init];
//    [_conversationToolBarBtn addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.conversationToolBarBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(self.audioButton);
        make.right.equalTo(self).offset(-16);
        make.size.equalTo(self.audioButton);
    }];
    
//    self.emojiButton = [[UIButton alloc] init];
//    [_emojiButton addTarget:self action:@selector(emoticonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiButton Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(self.audioButton);
        make.right.equalTo(self.conversationToolBarBtn.ease_left).offset(-kModuleMargin);
        make.size.equalTo(self.audioButton);
    }];
    

if ([EaseIMKitOptions sharedOptions].isJiHuApp){
//    [self.audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"audio-unSelected"] forState:UIControlStateNormal];
//    [self.audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"character"] forState:UIControlStateSelected];
//
//    [self.conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"more-unselected"] forState:UIControlStateNormal];
//    [self.conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"more-selected"] forState:UIControlStateSelected];
//
//    [self.emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"face"] forState:UIControlStateNormal];
//    [self.emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"character"] forState:UIControlStateSelected];
//
//
//    [self.textView setTextColor:[UIColor colorWithHexString:@"#F5F5F5"]];
//    self.textView.tintColor = [UIColor colorWithHexString:@"#04D0A4"];
//    self.textView.backgroundColor = [UIColor colorWithHexString:@"#3D3D3D"];
    
    [self.audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_audio-unSelected"] forState:UIControlStateNormal];
    [self.audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_character"] forState:UIControlStateSelected];
    
    [self.conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"yg_more-unselected"] forState:UIControlStateNormal];
    [self.conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"yg_more-selected"] forState:UIControlStateSelected];
    
    [self.emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_face"] forState:UIControlStateNormal];
    [self.emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_character"] forState:UIControlStateSelected];

    self.textView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];

}else {
    [self.audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_audio-unSelected"] forState:UIControlStateNormal];
    [self.audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_character"] forState:UIControlStateSelected];
    
    [self.conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"yg_more-unselected"] forState:UIControlStateNormal];
    [self.conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"yg_more-selected"] forState:UIControlStateSelected];
    
    [self.emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_face"] forState:UIControlStateNormal];
    [self.emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"yg_character"] forState:UIControlStateSelected];

    self.textView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
}

    
    [self.textView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(12.0);
        make.height.Ease_equalTo(kTextViewMinHeight);
        if (_viewModel.inputBarStyle == EaseInputBarStyleAll) {
            make.left.equalTo(self.audioButton.ease_right).offset(kModuleMargin);
            make.right.equalTo(self.emojiButton.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoAudio) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self.emojiButton.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoEmoji) {
            make.left.equalTo(self.audioButton.ease_right).offset(kModuleMargin);
            make.right.equalTo(self.conversationToolBarBtn.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoAudioAndEmoji) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self.conversationToolBarBtn.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleOnlyText) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self).offset(-16);
        }
    }];
    
    
//    self.bottomLine = [[UIView alloc] init];
//    self.bottomLine.backgroundColor = UIColor.blackColor;
//    _bottomLine.alpha = 0.1;
    
    [self addSubview:self.bottomLine];
    [self.bottomLine Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.textView.ease_bottom).offset(12.0);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
    }];
    self.currentMoreView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        [self.bottomLine Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
    
    self.emojiButton.selected = NO;
    self.conversationToolBarBtn.selected = NO;
    self.audioButton.selected = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL result = YES;
    
    if ([text isEqualToString:@"\n"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarSendMsgAction:)]) {
            [self.delegate chatBarSendMsgAction:self.textView.content];
        }
        result = NO;
        return result;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        result = [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }

    if (result) {
        self.textViewInsertText = text;
        self.textViewInsertRange = range;
    }
    
    return result;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _updatetextViewHeight];
    if (self.moreEmoticonView) {
        [self emoticonChangeWithText];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidChange:)]) {
        [self.delegate inputViewDidChange:self.textView];
    }
    
//    if (self.textViewInsertText.length > 0) {
//        [self.textView insertText:self.textViewInsertText range:self.textViewInsertRange];
//        self.textViewInsertText = @"";
//        self.textViewInsertRange = NSMakeRange(0, 0);
//    }

}

#pragma mark - Private

- (CGFloat)_gettextViewContontHeight
{
    if (self.version >= 7.0) {
        CGSize sizeToFit = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, MAXFLOAT)];
        if (sizeToFit.height <= 37.0) {
            return 32.0;
        }
        return sizeToFit.height;

    } else {
        return self.textView.contentSize.height;
    }
}

- (void)_updatetextViewHeight
{
    CGFloat height = [self _gettextViewContontHeight];
    if (height < kTextViewMinHeight) {
        height = kTextViewMinHeight;
    }
    if (height > kTextViewMaxHeight) {
        height = kTextViewMaxHeight;
    }
    
    if (height == self.previousTextViewContentHeight) {
        return;
    }
    
    self.previousTextViewContentHeight = height;
    [self.textView Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.height.Ease_equalTo(height);
    }];
}


- (void)_remakeButtonsViewConstraints
{
    if (self.currentMoreView) {
        [self.bottomLine Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.textView.ease_bottom).offset(12.0);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.currentMoreView.ease_top);
        }];
    } else {
        [self.bottomLine Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.textView.ease_bottom).offset(12.0);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
}

- (void)emoticonChangeWithText
{
    if (self.textView.text.length > 0) {
        [self.moreEmoticonView textDidChange:YES];
    } else {
        [self.moreEmoticonView textDidChange:NO];
    }
}

#pragma mark - Public

- (void)clearInputViewText
{
    self.textView.text = @"";
    if (self.moreEmoticonView) {
        [self emoticonChangeWithText];
    }
    [self _updatetextViewHeight];
}

- (void)inputViewAppendText:(NSString *)aText
{
    if ([aText length] > 0) {
        [self.textView appendEmojiText:aText];
        
        [self _updatetextViewHeight];
    }
    if (self.moreEmoticonView) {
        [self emoticonChangeWithText];
    }
}


- (BOOL)deleteTailText
{
    if ([self.textView.text length] > 0) {
        NSRange range = [self.textView.text rangeOfComposedCharacterSequenceAtIndex:self.textView.text.length-1];
        self.textView.text = [self.textView.text substringToIndex:range.location];
    }
    if ([self.textView.text length] > 0) {
        return YES;
    }
    return NO;
}

- (void)clearMoreViewAndSelectedButton
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        self.currentMoreView = nil;
        [self _remakeButtonsViewConstraints];
    }
    
    if (self.selectedButton) {
        self.selectedButton.selected = NO;
        self.selectedButton = nil;
    }
    if (!self.audioButton.isSelected) {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(@(28));
        }];
    } else {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(@(28));
        }];
    }
}

#pragma mark - Action

- (BOOL)_buttonAction:(UIButton *)aButton
{
    BOOL isEditing = NO;
    [self.textView resignFirstResponder];
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        self.currentMoreView = nil;
        [self _remakeButtonsViewConstraints];
    }
    
    if (self.selectedButton != aButton) {
        self.selectedButton.selected = NO;
        self.selectedButton = nil;
        self.selectedButton = aButton;
        [aButton setSelected:!aButton.selected];
    } else {
        self.selectedButton = nil;
        if (aButton.isSelected) {
            [self.textView becomeFirstResponder];
            isEditing = YES;
        }
    }
    if (aButton.selected) {
        self.selectedButton = aButton;
    }
    if (!self.audioButton.isSelected) {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(@(28));
        }];
    } else {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(kIconwidth);
        }];
    }
    
    return isEditing;
}

//语音
- (void)audioButtonAction:(UIButton *)aButton
{
    if([self _buttonAction:aButton]) {
        return;
    }

    if (aButton.selected) {
        if (self.recordAudioView) {
            self.currentMoreView = self.recordAudioView;
            [self addSubview:self.recordAudioView];
            [self.recordAudioView Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
            }];
            [self _remakeButtonsViewConstraints];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

//表情
- (void)emoticonButtonAction:(UIButton *)aButton
{
    if([self _buttonAction:aButton]) {
        return;
    }
    if (aButton.selected) {
        if (self.moreEmoticonView) {
            self.currentMoreView = self.moreEmoticonView;
            [self emoticonChangeWithText];
            [self addSubview:self.moreEmoticonView];
            [self.moreEmoticonView Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.Ease_equalTo(self.moreEmoticonView.viewHeight);
            }];
            [self _remakeButtonsViewConstraints];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

//更多
- (void)moreButtonAction:(UIButton *)aButton
{
    if([self _buttonAction:aButton]) {
        return;
    }
    if (aButton.selected){
        if(self.moreFunctionView) {
            self.currentMoreView = self.moreFunctionView;
            [self addSubview:self.moreFunctionView];
            [self.moreFunctionView Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.Ease_equalTo(@200);
            }];
            [self _remakeButtonsViewConstraints];
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

#pragma mark getter and setter
- (UIButton *)audioButton {
    if (_audioButton == nil) {
        _audioButton = [[UIButton alloc] init];
        [_audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioButton;
}


- (UIButton *)conversationToolBarBtn {
    if (_conversationToolBarBtn == nil) {
        _conversationToolBarBtn = [[UIButton alloc] init];
        [_conversationToolBarBtn addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _conversationToolBarBtn;
}

- (UIButton *)emojiButton {
    if (_emojiButton == nil) {
        _emojiButton = [[UIButton alloc] init];
        [_emojiButton addTarget:self action:@selector(emoticonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (EaseTextView *)textView {
    if (_textView == nil) {
        _textView = [[EaseTextView alloc] init];
        _textView.delegate = self;
        
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.textContainerInset = UIEdgeInsetsMake(8.0, 10, 10, 0);
        if (@available(iOS 11.1, *)) {
            _textView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(12, 20, 2, 0);
        } else {
            // Fallback on earlier versions
        }
        _textView.returnKeyType = UIReturnKeySend;
        _textView.placeHolder = @"说点啥";
        _textView.layer.cornerRadius = kTextViewMinHeight * 0.5;
        
    }
    return _textView;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = UIColor.blackColor;
        _bottomLine.alpha = 0.1;
    }
    return _bottomLine;
}

@end
