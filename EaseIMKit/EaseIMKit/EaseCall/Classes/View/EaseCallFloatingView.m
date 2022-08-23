//
//  EaseCallFloatingView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/23.
//

#import "EaseCallFloatingView.h"
#import "EaseHeaders.h"

@interface EaseCallFloatingView()

@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation EaseCallFloatingView
- (instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    [self addSubview:self.contentBgView];
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0));
    }];
}



- (void)tapAction {
    if (self.tapViewBlock) {
        self.tapViewBlock();
    }
}

#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [_iconImageView setImage:[UIImage easeUIImageNamed:@"floating_voice"]];
    }
    return _iconImageView;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
    }
    return _timeLabel;
}

- (UIView *)contentBgView {
    if (_contentBgView == nil) {
        _contentBgView = [[UIView alloc] init];
        _contentBgView.backgroundColor = [UIColor clearColor];
        _contentBgView.backgroundColor = [UIColor colorWithHexString:@"#1C1C1C"];
       
        [_contentBgView addSubview:self.iconImageView];
        [_contentBgView addSubview:self.timeLabel];

        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentBgView);
            make.top.equalTo(_contentBgView).offset(8.0);
            make.size.equalTo(@(28.0));

        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView).offset(4.0);
            make.centerX.equalTo(_contentBgView);
            make.left.right.equalTo(_contentBgView);
            
        }];
    }
    return _contentBgView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}


@end
