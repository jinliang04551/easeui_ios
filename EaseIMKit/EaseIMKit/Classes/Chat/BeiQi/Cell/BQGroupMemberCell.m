//
//  BQGroupMemberCell.m
//  EaseIM
//
//  Created by liu001 on 2022/7/7.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQGroupMemberCell.h"
#import "BQGroupMemberCollectionView.h"

@interface BQGroupMemberCell ()
@property (nonatomic, strong) BQGroupMemberCollectionView* memberCollectionView;
@property (nonatomic, strong) UIButton* moreButton;
@property (nonatomic, strong) EMGroup *group;

@end


@implementation BQGroupMemberCell

- (void)prepare {
    [self.contentView addSubview:self.memberCollectionView];
}

- (void)placeSubViews {
    [self.memberCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@(128.0));
    }];
    
    [self.contentView addSubview:self.moreButton];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.memberCollectionView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)updateWithObj:(id)obj {
    NSMutableArray *tArray = (NSMutableArray *)obj;

    [self.memberCollectionView updateUIWithMemberArray:tArray];
    if (tArray.count + 1 > 6) {
        CGFloat tHeight = 244.0 - 48.0;
        [self.memberCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(tHeight));
        }];
    }
   
    
}

+ (CGFloat)cellHeightWithObj:(id)obj {
//    EMGroup *tGroup = (EMGroup *)obj;
//    if (tGroup == nil) {
//        return 0;
//    }
//
//    NSMutableArray *tArray = [NSMutableArray array];
//    [tArray addObject:tGroup.owner];
//    if (tGroup.adminList.count > 0) {
//        [tArray addObjectsFromArray:tGroup.adminList];
//    }
//    if (tGroup.memberList.count > 0) {
//        [tArray addObjectsFromArray:tGroup.memberList];
//    }

    NSMutableArray *tArray = (NSMutableArray *)obj;
    if (tArray.count + 1 > 6) {
        return 244.0;
    }

    return 175.0;
}

#pragma mark action
- (void)moreButtonAction {
    if(self.moreMemberBlock){
        self.moreMemberBlock();
    }
}

#pragma mark getter and setter
- (BQGroupMemberCollectionView *)memberCollectionView {
    if (_memberCollectionView == nil) {
        _memberCollectionView = [[BQGroupMemberCollectionView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 100)];
        EaseIMKit_WS
        _memberCollectionView.addMemberBlock = ^{
            if (weakSelf.addMemberBlock) {
                weakSelf.addMemberBlock();
            }
        };
    }
    return _memberCollectionView;
}


- (UIButton *)moreButton {
    if (_moreButton == nil) {
        _moreButton = [[UIButton alloc] init];
        _moreButton.frame = CGRectMake(0, 0, 50.f, 30.f);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = EaseIMKit_Font(@"PingFang SC", 14.0);
        titleLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.text = @"查看更多群成员";
        
        UIImageView *accImageView = [[UIImageView alloc] init];
        [accImageView setImage:[UIImage easeUIImageNamed:@"jh_right_access"]];
        accImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_moreButton addSubview:titleLabel];
        [_moreButton addSubview:accImageView];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_moreButton);
            make.bottom.equalTo(_moreButton).offset(-16.0);
        }];
        
        [accImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel.mas_right).offset(5.0);
            make.centerY.equalTo(titleLabel);
            make.width.equalTo(@(28.0));
            make.height.equalTo(@(28.0));
        }];
        
        [_moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _moreButton;
}


@end
