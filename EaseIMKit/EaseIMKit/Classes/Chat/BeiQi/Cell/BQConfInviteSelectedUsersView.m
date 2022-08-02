//
//  BQConfenceSelectedView.m
//  EaseIM
//
//  Created by liu001 on 2022/7/14.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQConfInviteSelectedUsersView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoStore.h"
#import "EaseHeaders.h"

#define kAvatarImageHeight 38.0
#define KCollectionItemMaxCount 6

@interface BQConfInviteMemberCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation BQConfInviteMemberCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(@(38.0));
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(3.0);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)updateWithObj:(id)obj {
    NSString *aUid = (NSString *)obj;
    
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
                
        self.nameLabel.text = userInfo.nickName.length > 0 ? userInfo.nickName: userInfo.userId;

    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[aUid]];
    }
    
}


#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.layer.cornerRadius = kAvatarImageHeight * 0.5;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = EaseIMKit_NFont(12.0);
        _nameLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nameLabel;
}


@end



@interface BQConfInviteSelectedUsersView ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@end


@implementation BQConfInviteSelectedUsersView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)updateUIWithMemberArray:(NSMutableArray *)memberArray {
    self.dataArray = memberArray;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    BQConfInviteMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BQConfInviteMemberCell reuseIdentifier] forIndexPath:indexPath];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    [cell updateWithObj:obj];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[BQConfInviteMemberCell class] forCellWithReuseIdentifier:[BQConfInviteMemberCell reuseIdentifier]];

        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.pagingEnabled = NO;
        _collectionView.scrollEnabled = YES;
        _collectionView.userInteractionEnabled = YES;

    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = [BQConfInviteSelectedUsersView itemSize];
    flowLayout.minimumLineSpacing = 14.0;
    flowLayout.minimumInteritemSpacing = [BQConfInviteSelectedUsersView itemSpacing];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, [BQConfInviteSelectedUsersView collectionLeftRightPadding], 0, [BQConfInviteSelectedUsersView collectionLeftRightPadding]);
    
    return flowLayout;
}

+ (CGSize)itemSize {
    CGFloat itemWidth = (EaseIMKit_ScreenWidth - (KCollectionItemMaxCount - 1)* [BQConfInviteSelectedUsersView itemSpacing] - [BQConfInviteSelectedUsersView collectionLeftRightPadding] *2)/KCollectionItemMaxCount;
    CGFloat itemHeight = 70.0;
    return CGSizeMake(itemWidth, itemHeight);
}

+ (CGFloat)itemSpacing {
    return 12.0;
}

+ (CGFloat)collectionLeftRightPadding {
    return 16.0;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}


@end

#undef kAvatarImageHeight
#undef KCollectionItemMaxCount

