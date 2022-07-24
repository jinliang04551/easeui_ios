//
//  YGReadReceiptButton.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/22.
//

#import "YGReadReceiptButton.h"
#import "Masonry.h"
#import "EaseHeaders.h"


@interface YGReadReceiptButton()

@property (nonatomic, strong) UIImageView *readIconImageView;
@property (nonatomic, strong) UILabel *readCountLabel;

@end


@implementation YGReadReceiptButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeSubViews];
    }
    return self;
}

- (void)placeSubViews {
    [self addSubview:self.readIconImageView];
    [self addSubview:self.readCountLabel];
    
    [self.readIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.readCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}


- (void)updateStateWithCount:(NSInteger)readCount
                   isReadAll:(BOOL)isReadAll
{
    if (isReadAll) {
        [self.readIconImageView setImage:[UIImage easeUIImageNamed:@"yg_groupChat_allRead"]];
    }else {
        [self.readIconImageView setImage:[UIImage easeUIImageNamed:@"yg_groupChat_hasRead"]];
        self.readCountLabel.text = [@(readCount) stringValue];
    }

}

#pragma mark getter and setter
- (UILabel *)readCountLabel {
    if (_readCountLabel == nil) {
        _readCountLabel = [[UILabel alloc] init];
        _readCountLabel.font =  EaseIMKit_Font(@"PingFang SC", 8.0);
        _readCountLabel.textColor = [UIColor colorWithHexString:@"#07CEA6"];
        _readCountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _readCountLabel;
}


- (UIImageView *)readIconImageView {
    if (_readIconImageView == nil) {
        _readIconImageView = [[UIImageView alloc] init];
        [_readIconImageView setImage:[UIImage easeUIImageNamed:@"yg_groupChat_hasRead"]];
        _readIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _readIconImageView;
}


@end
