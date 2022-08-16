//
//  AgoraCustomCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//
#define kAvatarImageHeight 38.0

#import "BQCustomCell.h"
#import "EaseHeaders.h"
#import "UserInfoStore.h"


@interface BQCustomCell ()
@property (nonatomic, strong) UIView* bottomLine;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation BQCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            self.contentView.backgroundColor = EaseIMKit_ViewBgBlackColor;
    }else {
            self.contentView.backgroundColor = EaseIMKit_ViewCellBgWhiteColor;
    }

        [self prepare];
        [self placeSubViews];
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

- (void)updateCellWithUserId:(NSString *)aUid {
    EMUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUid];
    if(userInfo) {
        if(userInfo.avatarUrl.length > 0) {
            NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
            if(url) {
                [self.iconImageView sd_setImageWithURL:url completed:nil];
            }
        }else {
            [self.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_user_icon"]];
        }
             
        self.nameLabel.text = userInfo.nickname.length > 0 ? userInfo.nickname: userInfo.userId;
        
    }else{
        self.nameLabel.text = aUid;
        [self.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_user_icon"]];

        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[aUid]];
    }
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
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.layer.cornerRadius = kAvatarImageHeight * 0.5;
    }
    return _iconImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = EaseIMKit_NFont(14.0);
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        }else {
            _nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        }

        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    }
    return _nameLabel;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = UIView.new;
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#1C1C1C"];
}else {
        _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#DADADA"];
}
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            self.contentView.backgroundColor = EaseIMKit_COLOR_HEX(0x252525);
        }else {
//            self.contentView.backgroundColor = EaseIMKit_COLOR_HEX(0xF5F5F5);
            self.contentView.backgroundColor = EaseIMKit_COLOR_HEX(0xF2F3F5);
        }
        
    }else {
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
                self.contentView.backgroundColor = EaseIMKit_ViewCellBgBlackColor;
        }else {
                self.contentView.backgroundColor = EaseIMKit_ViewCellBgWhiteColor;
        }

    }
}



@end

#undef kAvatarImageHeight

