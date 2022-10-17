//
//  EaseNetworkErrorView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/13.
//

#import "EaseNetworkErrorView.h"
#import "EaseHeaders.h"

@interface EaseNetworkErrorView ()
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation EaseNetworkErrorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutAllSubviews];
    }
    return self;
}
 
- (void)layoutAllSubviews {
    
    [self addSubview:self.contentView];
        
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
  

#pragma mark getter and setter
- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = UIView.new;
        _contentView.layer.cornerRadius = 10.0f;
        _contentView.clipsToBounds = YES;
        _contentView.backgroundColor = EaseIMKit_COLOR_HEX(0xFEE6E6);

        [_contentView addSubview:self.titleLabel];
        [_contentView addSubview:self.iconImageView];
      
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_contentView);
            make.left.equalTo(_contentView).offset(24.0);
            make.size.equalTo(@(28.0));
        }];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView.mas_right).offset(14.0);
            make.right.equalTo(_contentView);
        }];
        
    }
    return _contentView;;
}

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.layer.masksToBounds = YES;
        [_iconImageView setImage:[UIImage easeUIImageNamed:@"ease_network_disable"]];
    }
    return _iconImageView;
}


- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = UILabel.new;
        _titleLabel.font = EaseIMKit_NFont(14.0);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = EaseIMKit_COLOR_HEX(0xFE5967);
        _titleLabel.text = @"网络不给力，请检查网络设置";
    }
    return _titleLabel;
}



@end
