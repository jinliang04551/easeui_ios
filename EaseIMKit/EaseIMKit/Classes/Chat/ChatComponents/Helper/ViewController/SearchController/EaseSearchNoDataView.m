//
//  EaseSearchNOdataView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/13.
//

#import "EaseSearchNoDataView.h"
#import "EaseHeaders.h"

@interface EaseSearchNoDataView ()

@property (nonatomic,strong) UIImageView *noDataImageView;
@property (nonatomic,strong) UILabel *prompt;


@end

@implementation EaseSearchNoDataView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self placeAndLayoutSubviews];
    }
    
    return self;
}

- (void)placeAndLayoutSubviews{
    [self addSubview:self.noDataImageView];
    [self addSubview:self.prompt];
    
    
    [self.noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5.0);
        make.centerX.equalTo(self);
    }];
    
    [self.prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noDataImageView.mas_bottom).offset(10.0);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(14.0);
        make.bottom.equalTo(self);
    }];
    
}

#pragma mark getter and setter
- (UIImageView *)noDataImageView {
    if (_noDataImageView == nil) {
        _noDataImageView = UIImageView.new;
    }
    return _noDataImageView;
}

- (UILabel *)prompt {
    if (_prompt == nil) {
        _prompt = UILabel.new;
        _prompt.textColor = EaseIMKit_COLOR_HEX(0x7F7F7F);
        _prompt.font = EaseIMKit_NFont(12.0);
        _prompt.textAlignment = NSTextAlignmentCenter;
        _prompt.text = @"no data";
    }
    return _prompt;
}

@end



