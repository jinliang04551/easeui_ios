//
//  EaseCustomCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/13.
//  Copyright © 2022 djp. All rights reserved.
//

#import "EaseCustomCell.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"

#define kAvatarImageHeight 44.0

@interface EaseCustomCell ()
@property (nonatomic, strong) UIView* bottomLine;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation EaseCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self prepare];
        [self placeSubViews];
if (EaseIMKitManager.shared.isJiHuApp){
        self.contentView.backgroundColor = EaseIMKit_ViewCellBgBlackColor;
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];

}else {
        self.contentView.backgroundColor = EaseIMKit_ViewCellBgWhiteColor;
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];

}
    }
    return self;
}

- (void)tapAction {
    if (self.tapCellBlock) {
        self.tapCellBlock();
    }
}

- (void)prepare {

}

- (void)placeSubViews {
    
}

- (void)updateWithObj:(id)obj {
    
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


+ (CGFloat)height {
    return 64.0f;
}


#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14.0];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    }
    return _nameLabel;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = UIView.new;
        _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#1C1C1C"];
    }
    return _bottomLine;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}

@end

#undef kAvatarImageHeight


