//
//  EaseChatbarSendAudioView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/13.
//

#import "EaseChatbarSendAudioView.h"
#import "EaseHeaders.h"
#import "UIImage+Ext.h"


@interface EaseChatbarSendAudioView()
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) NSMutableArray *voiceImageArray;
@property (nonatomic, strong) UIImageView *voiceImageView;
@property (nonatomic, strong) UILabel *hintLabel;

@property (nonatomic, strong)UILongPressGestureRecognizer *longGestureRecognizer;

@end

@implementation EaseChatbarSendAudioView
- (instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    [self addGestureRecognizer:self.longGestureRecognizer];
    
    [self addSubview:self.contentBgView];
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


- (void)longPressAction {
//    if (self.tapViewBlock) {
//        self.tapViewBlock();
//    }
    
}

#pragma mark getter and setter
- (UIView *)contentBgView {
    if (_contentBgView == nil) {
        _contentBgView = [[UIView alloc] init];
        
        _contentBgView.backgroundColor = [UIColor colorWithHexString:@"#252525"];
        _contentBgView.layer.cornerRadius = 4.0;
        _contentBgView.layer.borderColor = [UIColor colorWithHexString:@"#2D2C2C"].CGColor;
        _contentBgView.layer.borderWidth = 1.0;
        
        [_contentBgView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_contentBgView).insets(UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0));
        }];
    }
    return _contentBgView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.backgroundColor = [UIColor colorWithHexString:@"#1C1C1C"];
       
        [_contentView addSubview:self.iconImageView];
        [_contentView addSubview:self.voiceImageView];
        [_contentView addSubview:self.hintLabel];

        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(20.0);
            make.left.equalTo(_contentView).offset(20.0);
            
        }];
        
        [self.voiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView);
            make.right.equalTo(_contentView).offset(-20.0);
            
        }];

        
        [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView.mas_bottom).offset(4.0);
            make.left.right.equalTo(_contentView);
            make.bottom.equalTo(_contentView).offset(-12.0);
        }];
        
    }
    return _contentView;
}


- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [_iconImageView setImage:[UIImage imageNamedFromBundle:@"ease_video_icon"]];
    }
    return _iconImageView;
}


- (NSMutableArray *)voiceImageArray {
    if (_voiceImageArray == nil) {
        _voiceImageArray = [NSMutableArray new];
        for (NSInteger i = 1; i < 8; ++i) {
            NSString *imageName = [NSString stringWithFormat:@"ease_video_%@",@(i)];
            UIImage *image = [UIImage imageNamedFromBundle:imageName];
            [_voiceImageArray addObject:image];
        }
    }
    
    return _voiceImageArray;
}


- (UIImageView *)voiceImageView {
    if (!_voiceImageView) {
        _voiceImageView = [[UIImageView alloc] init];
        //图片播放一次所需时长
        _voiceImageView.animationDuration = 0.5;
        //图片播放次数,0表示无限
        _voiceImageView.animationRepeatCount = 1;
        _voiceImageView.hidden = YES;
    }
    
    return _voiceImageView;
}




- (UILongPressGestureRecognizer *)longGestureRecognizer {
    if (_longGestureRecognizer == nil) {
        _longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction)];
    }
    return _longGestureRecognizer;
}

- (UILabel *)hintLabel {
    if (_hintLabel == nil) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.font = EaseIMKit_NFont(12.0);
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            _hintLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        }else {
            _hintLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        }

        _hintLabel.textAlignment = NSTextAlignmentLeft;
        _hintLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    }
    return _hintLabel;
}


@end
