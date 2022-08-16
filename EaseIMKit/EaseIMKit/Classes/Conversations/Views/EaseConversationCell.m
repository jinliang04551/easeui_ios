//
//  EaseConversationCell.m
//  EaseIMKit
//
//  Created by XieYajie on 2019/1/8.
//  Update © 2020 zhangchong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseConversationCell.h"
#import "EaseDateHelper.h"
#import "EaseBadgeView.h"
#import "Easeonry.h"
#import "UIImageView+EaseWebCache.h"
#import "EaseHeaders.h"

@interface EaseConversationCell()

@property (nonatomic, strong) EaseConversationViewModel *viewModel;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) EaseBadgeView *badgeLabel;
@property (nonatomic, strong) UIImageView *redDot;
@property (nonatomic, strong) UIImageView *undisturbRing;

@property (nonatomic, strong) UILabel *groupIdLabel;

@end

@implementation EaseConversationCell

+ (EaseConversationCell *)tableView:(UITableView *)tableView cellViewModel:(EaseConversationViewModel *)viewModel {
    static NSString *cellId = @"EMConversationCell";
    EaseConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[EaseConversationCell alloc] initWithConversationsViewModel:viewModel identifier: cellId];
    }
    
    return cell;
}

- (instancetype)initWithConversationsViewModel:(EaseConversationViewModel*)viewModel
                                   identifier:(NSString *)identifier
{

    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _viewModel = viewModel;
        [self _addSubViews];
        [self _setupSubViewsConstraints];
        [self _setupViewsProperty];
    }
    return self;
}

#pragma mark - private layout subviews

- (void)_addSubViews {
        
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.groupIdLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.badgeLabel];
    [self.contentView addSubview:self.undisturbRing];

}

- (void)_setupViewsProperty {
    
    self.backgroundColor = _viewModel.cellBgColor;
        
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.redDot.image = [UIImage easeUIImageNamed:@"jh_undisturbDot"];
        self.undisturbRing.image = [UIImage easeUIImageNamed:@"jh_undisturbRing"];
    }else {
        self.redDot.image = [UIImage easeUIImageNamed:@"yg_undisturbDot"];
        self.undisturbRing.image = [UIImage easeUIImageNamed:@"yg_undisturbRing"];
    }

}

- (void)_setupSubViewsConstraints
{
    
    __weak typeof(self) weakSelf = self;
    
    [self.avatarView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.avatarEdgeInsets.top + 14.0);
        make.left.equalTo(weakSelf.contentView.ease_left).offset(weakSelf.viewModel.avatarEdgeInsets.left + 16.0);
        make.width.offset(weakSelf.viewModel.avatarSize.width);
        make.height.offset(weakSelf.viewModel.avatarSize.height).priority(750);
    }];
    
    [self.nameLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.nameLabelEdgeInsets.top + 14.0);
        make.left.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.avatarEdgeInsets.right + weakSelf.viewModel.nameLabelEdgeInsets.left + 10.0);
    }];
    
    [self.timeLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.timeLabelEdgeInsets.top + 14.0);
        make.right.equalTo(weakSelf.contentView.ease_right).offset(-weakSelf.viewModel.timeLabelEdgeInsets.right - 16.0);
        make.left.greaterThanOrEqualTo(weakSelf.nameLabel.ease_right).offset(weakSelf.viewModel.nameLabelEdgeInsets.right + weakSelf.viewModel.timeLabelEdgeInsets.left + 8);
    }];

    [self.groupIdLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameLabel.ease_bottom).offset(4.0);
        make.left.equalTo(weakSelf.nameLabel);
        make.right.equalTo(weakSelf.contentView).offset(-16.0);
        make.height.equalTo(@(16.0));
    }];
    
    [self.detailLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameLabel.ease_bottom).offset(4.0);
        make.left.equalTo(weakSelf.nameLabel);
        make.right.equalTo(weakSelf.contentView).offset(-16.0);
    }];

    [self.undisturbRing Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.height.Ease_equalTo(@(20.0));
        make.width.Ease_equalTo(@(20.0));
        make.centerY.equalTo(weakSelf.detailLabel);
        make.right.equalTo(weakSelf.contentView.ease_right).offset(-weakSelf.viewModel.timeLabelEdgeInsets.right - 16.0);
    }];

    
    if (_viewModel.badgeLabelPosition == EMAvatarTopRight) {
        [self.badgeLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.height.offset(_viewModel.badgeLabelHeight);
            make.width.Ease_greaterThanOrEqualTo(weakSelf.viewModel.badgeLabelHeight).priority(1000);
            make.centerY.equalTo(weakSelf.avatarView.ease_top).offset(weakSelf.viewModel.badgeLabelCenterVector.dy + 4);
            make.centerX.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.badgeLabelCenterVector.dx - 8);
        }];
        
        [self.detailLabel Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.right.equalTo(weakSelf.contentView.ease_right).offset(-weakSelf.viewModel.detailLabelEdgeInsets.right - 18);
        }];
    }else {
        [self.badgeLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.height.offset(_viewModel.badgeLabelHeight);
            make.width.Ease_greaterThanOrEqualTo(weakSelf.viewModel.badgeLabelHeight).priority(1000);
            make.centerY.equalTo(weakSelf.avatarView.ease_top).offset(weakSelf.viewModel.badgeLabelCenterVector.dy + 4);
            make.centerX.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.badgeLabelCenterVector.dx - 8);
        }];
    }
    
    
}

- (void)setModel:(EaseConversationModel *)model
{
    _model = model;
    
    UIImage *img = nil;
    if ([_model respondsToSelector:@selector(defaultAvatar)]) {
        img = _model.defaultAvatar;
    }
    
    if (_viewModel.defaultAvatarImage && !img) {
        img = _viewModel.defaultAvatarImage;
    }
  

    if ([_model respondsToSelector:@selector(avatarURL)]) {
        [self.avatarView Ease_setImageWithURL:[NSURL URLWithString:_model.avatarURL]
                           placeholderImage:img];
    }else {
        self.avatarView.image = img;
    }
    
    if ([_model respondsToSelector:@selector(showName)]) {
        self.nameLabel.text = _model.showName;
    }
    
    if (model.isTop) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = _viewModel.topBgColor;
    } else {
        self.backgroundColor = _viewModel.cellBgColor;
    }
    
    EaseIMKit_WS
    if (![EaseIMKitOptions sharedOptions].isJiHuApp && self.model.type == EMConversationTypeGroupChat) {
       
        self.groupIdLabel.hidden = NO;
        [self.detailLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
           
            make.top.equalTo(weakSelf.groupIdLabel.ease_bottom).offset(4.0);
            make.left.equalTo(weakSelf.nameLabel);
            
            if (model.showBadgeValue) {
                make.right.equalTo(weakSelf.contentView).offset(-16.0);

            }else {
                make.right.equalTo(weakSelf.undisturbRing.ease_left).offset(-8.0);
            }
        }];
        
    }else {
        self.groupIdLabel.hidden = YES;

        [self.detailLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(weakSelf.nameLabel.ease_bottom).offset(4.0);
            make.left.equalTo(weakSelf.nameLabel);

            if (model.showBadgeValue) {
                make.right.equalTo(weakSelf.contentView).offset(-16.0);

            }else {
                make.right.equalTo(weakSelf.undisturbRing.ease_left).offset(-8.0);
            }
        }];
    }
    
      
    self.groupIdLabel.text = [NSString stringWithFormat:@"群组ID:%@",_model.easeId];
    self.detailLabel.attributedText = _model.showInfo;
    if (self.detailLabel.attributedText.length > 0) {
        self.timeLabel.text = [EaseDateHelper formattedTimeFromTimeInterval:_model.lastestUpdateTime];
    }else {
        self.timeLabel.text = @"";
    }
        
    if (model.showBadgeValue == YES) {
        self.badgeLabel.badge = model.unreadMessagesCount;
        self.redDot.hidden = YES;
        self.badgeLabel.hidden = !(model.unreadMessagesCount > 0);
    } else {
        self.badgeLabel.hidden = YES;
        self.redDot.hidden = !(model.unreadMessagesCount > 0);
    }
    self.undisturbRing.hidden = model.showBadgeValue;
    
}


- (void)resetViewModel:(EaseConversationViewModel *)aViewModel {
    _viewModel = aViewModel;
    [self _addSubViews];
    [self _setupSubViewsConstraints];
    [self _setupViewsProperty];
}

+ (CGFloat)heightWithModel:(EaseConversationModel *)model {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        return 72.0;
    }else {
        if (model.type == EMConversationTypeGroupChat) {
            return 88.0;
        }else {
            return 72.0;
        }
    }
}

#pragma mark getter and setter
- (UILabel *)groupIdLabel {
    if (_groupIdLabel == nil) {
        _groupIdLabel = [[UILabel alloc] init];
        _groupIdLabel.font = EaseIMKit_NFont(12.0);
        _groupIdLabel.textColor = [UIColor colorWithHexString:@"#A5A5A5"];
        _groupIdLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _groupIdLabel.backgroundColor = [UIColor clearColor];
        _groupIdLabel.hidden = YES;
        
    }
    return _groupIdLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.badgeLabel.backgroundColor = _viewModel.badgeLabelBgColor;
        
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    self.badgeLabel.backgroundColor = _viewModel.badgeLabelBgColor;

    if (highlighted) {
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            self.contentView.backgroundColor = EaseIMKit_COLOR_HEX(0x252525);
        }else {
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

- (UIImageView *)avatarView {
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
      
        if (_viewModel.avatarType != Rectangular) {
            _avatarView.clipsToBounds = YES;
            if (_viewModel.avatarType == RoundedCorner) {
                _avatarView.layer.cornerRadius = 5;
            }
            else if(_viewModel.avatarType == Circular) {
                _avatarView.layer.cornerRadius = _viewModel.avatarSize.width / 2;
            }
            
        }else {
            _avatarView.clipsToBounds = NO;
        }
        
        _avatarView.backgroundColor = [UIColor clearColor];
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_avatarView addSubview:self.redDot];

        CGFloat r = _viewModel.avatarSize.width/2.0;
        CGFloat padding = r - ceilf(r/sqrt(2)) - 6;//求得以内切圆半径为斜边的等直角边直角三角形的单直角边长度，用内切圆半径减去它再减去红点视图的一半距离求得偏移量

        [self.redDot Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.height.Ease_equalTo(12);
            make.width.Ease_equalTo(12);
            make.top.equalTo(_avatarView.ease_top).offset(padding);
            make.right.equalTo(_avatarView.ease_right).offset(-padding);
        }];
        
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = _viewModel.nameLabelFont;
        _nameLabel.textColor = _viewModel.nameLabelColor;
        _nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _nameLabel.backgroundColor = [UIColor clearColor];
    }
    return _nameLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.font = _viewModel.detailLabelFont;
        _detailLabel.textColor = _viewModel.detailLabelColor;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = _viewModel.timeLabelFont;
        _timeLabel.textColor = _viewModel.timeLabelColor;
        _timeLabel.backgroundColor = [UIColor clearColor];
        [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    }
    return _timeLabel;
}

- (EaseBadgeView *)badgeLabel {
    if (_badgeLabel == nil) {
        _badgeLabel = [[EaseBadgeView alloc] initWithFrame:CGRectZero];
        _badgeLabel.hidden = YES;
        _badgeLabel.font = _viewModel.badgeLabelFont;
        _badgeLabel.backgroundColor = _viewModel.badgeLabelBgColor;
        _badgeLabel.badgeColor = _viewModel.badgeLabelTitleColor;
        _badgeLabel.maxNum = _viewModel.badgeMaxNum;
        
    }
    return _badgeLabel;
}

- (UIImageView *)redDot {
    if (_redDot == nil) {
        _redDot = [[UIImageView alloc] initWithFrame:CGRectZero];
        _redDot.hidden = YES;
    }
    return _redDot;
}

- (UIImageView *)undisturbRing {
    if (_undisturbRing == nil) {
        _undisturbRing = [[UIImageView alloc] initWithFrame:CGRectZero];
        _undisturbRing.hidden = YES;

    }
    return _undisturbRing;
}


@end

