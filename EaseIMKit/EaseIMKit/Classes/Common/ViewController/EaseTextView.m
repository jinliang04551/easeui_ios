/************************************************************
  *  * HyphenateChat CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2016 HyphenateChat Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of HyphenateChat Inc.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from HyphenateChat Inc.
  */

#import "EaseTextView.h"
#import "EaseHeaders.h"


@interface EaseTextView ()
@property (nonatomic ,strong) UILabel *placeHolderLabel;


@end

@implementation EaseTextView
#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveTextDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
        [self placeAndLayoutSubviews];
        self.content = [NSMutableString string];
        
    }
    return self;
}

- (void)placeAndLayoutSubviews {

    [self addSubview:self.placeHolderLabel];
    [self.placeHolderLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(self.ease_top).offset(16.0);
        make.left.equalTo(self).offset(14.0);
        make.right.equalTo(self).offset(-14.0);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - Notifications
- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification {
    
    [self updateTextViewUI];
}

- (void)updateTextViewUI {
    self.content = [[self getTextViewText] mutableCopy];
    self.placeHolderLabel.hidden = self.content.length > 0 ? YES : NO;
}

#pragma mark getter and setter
- (UILabel *)placeHolderLabel {
    if (_placeHolderLabel == nil) {
        _placeHolderLabel = [[UILabel alloc] init];
        _placeHolderLabel.font = EaseIMKit_NFont(14.0);
        _placeHolderLabel.textColor = [UIColor lightGrayColor];
        _placeHolderLabel.textAlignment = NSTextAlignmentLeft;
        _placeHolderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _placeHolderLabel;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.placeHolderLabel.text = _placeHolder;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    self.placeHolderLabel.textColor = _placeHolderColor;
    
}


- (void)appendEmojiText:(NSString *)emojiText {
  
    NSString *plainText =  [self getTextViewText];
    NSMutableString *reString = [[NSMutableString alloc] initWithString:plainText];
    [reString appendString:emojiText];
        
    NSMutableAttributedString *emojiAttributeString = [EaseKitUtil attachPictureWithText:reString];

    self.attributedText = emojiAttributeString;
    
    //reset font
    self.font = EaseIMKit_NFont(14.0);

    [self updateTextViewUI];
}


- (NSString *)getTextViewText {
    __block NSMutableString *result = [NSMutableString string];
    
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            
        NSLog(@"attrs:%@ range:%@",attrs,[NSValue valueWithRange:range]);
        
        BOOL hasEmojiText = NO;
        for (NSString *key in attrs.allKeys) {
            if ([key isEqualToString:EaseEmojiTextKey]) {
                NSString *emojiText = attrs[key];
                [result appendString:emojiText];
                hasEmojiText = YES;
            }
        }
        
        //not emojiText
        if (!hasEmojiText) {
            NSString *noEmojiText = [self.text substringWithRange:range];
             [result appendString:noEmojiText];
        }
    }];
    
        
    NSLog(@"%s result:%@",__func__,result);
    return result;
}


@end
