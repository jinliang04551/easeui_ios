//
//  BQMemberAvatarTitleRoleCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/18.
//

#import "BQMemberAvatarTitleRoleCell.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BQMemberAvatarTitleRoleCell ()
@property (nonatomic, strong) UIImageView* roleImageView;
@property (nonatomic, strong) UILabel* roleLabel;

@end


@implementation BQMemberAvatarTitleRoleCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.roleImageView];
    [self.contentView addSubview:self.roleLabel];

}


- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(EaseIMKit_AvatarHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(8.0);
        make.width.lessThanOrEqualTo(@(200.0));
    }];

    [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
    }];

    [self.roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2.0);
        make.left.equalTo(self.nameLabel);
    }];
    
}

- (void)updateWithObj:(id)obj isOwner:(BOOL)isOwner role:(NSString *)role {
    
    NSString *aUid = (NSString *)obj;
    self.roleLabel.text = role;
    self.roleImageView.hidden = !isOwner;
    [self updateCellWithUserId:aUid];
}


#pragma mark getter and setter
- (UIImageView *)roleImageView {
    if (_roleImageView == nil) {
        _roleImageView = [[UIImageView alloc] init];
        [_roleImageView setImage:[UIImage easeUIImageNamed:@"yg_group_owner"]];
        _roleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _roleImageView;
}

- (UILabel *)roleLabel {
    if (_roleLabel == nil) {
        _roleLabel = [[UILabel alloc] init];
        _roleLabel.font = EaseIMKit_NFont(12.0);
        _roleLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _roleLabel.textAlignment = NSTextAlignmentLeft;
        _roleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _roleLabel.text = @"客户";
    }
    return _roleLabel;
}

@end
