//
//  BQTitleValueContentAccessCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/13.
//

#import "BQTitleContentAccessCell.h"

@interface BQTitleContentAccessCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UILabel* detailLabel;


@end


@implementation BQTitleContentAccessCell

- (void)prepare {
    
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.accessoryImageView];
    [self.contentView addSubview:self.bottomLine];

}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0);
        make.left.equalTo(self.contentView).offset(EaseIMKit_Padding * 1.6);
        make.width.equalTo(@(150.0));
        make.height.equalTo(@(20.0));
        
    }];
    
    
    [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(28.0));
        make.height.equalTo(@(28.0));
        make.right.equalTo(self.contentView).offset(-16.0);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2.0);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.accessoryImageView.mas_left);
    }];
    
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(EaseIMKit_ONE_PX));
        make.bottom.equalTo(self.contentView);
    }];

}


+ (CGFloat)heightWithObj:(NSString *)obj {

    NSString *text = obj;
    
    CGFloat conMaxWidth = EaseIMKit_ScreenWidth - 16.0 *2 -28.0;
    CGSize size = CGSizeMake(conMaxWidth, MAXFLOAT);
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:12.0] forKey:NSFontAttributeName];
    
    CGFloat calculatedHeight = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size.height;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5.0];

    calculatedHeight += 12.0 + 20.0 + 2.0 + 12.0;
    calculatedHeight = MAX(calculatedHeight, 64.0);
    
    return calculatedHeight;
    
}

#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = EaseIMKit_Font(@"PingFang SC", 14.0);
        _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.text = @"未设置";
    }
    return _detailLabel;
}

- (UIImageView *)accessoryImageView {
    if (_accessoryImageView == nil) {
        _accessoryImageView = [[UIImageView alloc] init];
        [_accessoryImageView setImage:[UIImage easeUIImageNamed:@"jh_right_access"]];
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _accessoryImageView;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = EaseIMKit_Font(@"PingFang SC", 12.0);
        _contentLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.numberOfLines = 2;
        
    }
    return _contentLabel;
}

@end
