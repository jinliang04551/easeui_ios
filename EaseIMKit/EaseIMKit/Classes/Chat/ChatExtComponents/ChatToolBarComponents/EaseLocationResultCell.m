//
//  EaseLocationResultCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/24.
//

#import "EaseLocationResultCell.h"
#import "EaseHeaders.h"
#import "EaseLocationResultModel.h"

@interface EaseLocationResultCell ()
@property (nonatomic, strong) UIImageView* checkedImageView;
@property (nonatomic, strong) EaseLocationResultModel *model;

@end

@implementation EaseLocationResultCell

- (void)prepare {
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.checkedImageView];

    self.nameLabel.numberOfLines = 0;
    self.detailLabel.numberOfLines = 0;
    
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(4.0);
        make.left.equalTo(self.contentView).offset(EaseIMKit_Padding * 1.6);
        make.right.equalTo(self.checkedImageView.mas_left).offset(-EaseIMKit_Padding * 1.6);
        
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4.0);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.nameLabel);
    }];
    
    [self.checkedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.width.equalTo(@(17.0));
        make.height.equalTo(@(16.0));
        make.right.equalTo(self.contentView).offset(-16.0);
        
    }];
}


- (void)updateWithObj:(id)obj {
    EaseLocationResultModel *model = (EaseLocationResultModel *)obj;
    self.model = model;
    
}


#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = EaseIMKit_Font(@"PingFang SC", 12.0);
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        }else {
        //#B9B9B9
            _detailLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        }
        
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}

- (UIImageView *)checkedImageView {
    if (_checkedImageView == nil) {
        _checkedImageView = [[UIImageView alloc] init];
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            [_checkedImageView setImage:[UIImage easeUIImageNamed:@"jh_location_selected"]];

        }else {
            [_checkedImageView setImage:[UIImage easeUIImageNamed:@"jh_location_selected"]];
        }

        _checkedImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _checkedImageView;
}


@end
