//
//  BQGroupMemberView.m
//  EaseIM
//
//  Created by liu001 on 2022/7/8.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQGroupMemberCollectionView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoStore.h"
#import "EaseHeaders.h"

#define kAvatarImageHeight 38.0

@interface BQGroupMemberOperationCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *operationImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BQGroupMemberOperationCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}

- (void)placeAndLayoutSubViews {
    [self.contentView addSubview:self.operationImageView];
    [self.contentView addSubview:self.titleLabel];

    [self.operationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(kAvatarImageHeight);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.operationImageView.mas_bottom).offset(3.0);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];

}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


#pragma mark getter and setter
- (UIImageView *)operationImageView {
    if (_operationImageView == nil) {
        _operationImageView = [[UIImageView alloc] init];
        _operationImageView.contentMode = UIViewContentModeScaleAspectFit;
        _operationImageView.clipsToBounds = YES;
        _operationImageView.layer.masksToBounds = YES;
        
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
    [_operationImageView setImage:[UIImage easeUIImageNamed:@"jh_addMember"]];
}else {
    [_operationImageView setImage:[UIImage easeUIImageNamed:@"yg_operate_member"]];
}

    }
    return _operationImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = EaseIMKit_NFont(12.0);
        _titleLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
if ([EaseIMKitOptions sharedOptions].isJiHuApp) {

}else {
        _titleLabel.text = @"编辑";
}
        
    }
    return _titleLabel;
}

@end


@interface BQGroupAddedMemberCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation BQGroupAddedMemberCell
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
        make.size.mas_equalTo(kAvatarImageHeight);
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
    }
    return _nameLabel;
}

@end







@interface BQGroupMemberCollectionView ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIView* titleView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* memberCountLabel;
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@end



@implementation BQGroupMemberCollectionView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
    [self addSubview:self.titleView];
    [self addSubview:self.collectionView];

    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.equalTo(@(56.0));
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}


- (void)updateUIWithMemberArray:(NSMutableArray *)memberArray {
    self.dataArray = memberArray;
    self.memberCountLabel.text = [NSString stringWithFormat:@"%@人",@(memberArray.count)];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count] + 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    BQGroupMemberOperationCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:[BQGroupMemberOperationCell reuseIdentifier] forIndexPath:indexPath];
    if (indexPath.row == 0) {
        return addCell;
    }
    
    BQGroupAddedMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BQGroupAddedMemberCell reuseIdentifier] forIndexPath:indexPath];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row -1];
    [cell updateWithObj:obj];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if(self.addMemberBlock){
            self.addMemberBlock();
        }
    }
    
}


#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[BQGroupMemberOperationCell class] forCellWithReuseIdentifier:[BQGroupMemberOperationCell reuseIdentifier]];
        
        [_collectionView registerClass:[BQGroupAddedMemberCell class] forCellWithReuseIdentifier:[BQGroupAddedMemberCell reuseIdentifier]];

        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
        
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

    flowLayout.itemSize = [BQGroupMemberCollectionView collectionViewItemSize];
    flowLayout.minimumLineSpacing = [BQGroupMemberCollectionView collectionViewMinimumLineSpacing];
    flowLayout.minimumInteritemSpacing = 12.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 16.0, 0, 16.0);
    
    return flowLayout;
}

+ (CGSize)collectionViewItemSize {
    CGFloat itemWidth = (EaseIMKit_ScreenWidth - 16.0 * 2 - 5 * 12.0)/6.0;
    CGFloat itemHeight = 58.0;
    return CGSizeMake(itemWidth, itemHeight);
}


+ (CGFloat)collectionViewMinimumLineSpacing {
    return 14.0;
}


- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.text = @"群成员";
        
    }
    return _nameLabel;
}


- (UILabel *)memberCountLabel {
    if (_memberCountLabel == nil) {
        _memberCountLabel = [[UILabel alloc] init];
        _memberCountLabel.font = EaseIMKit_Font(@"PingFang SC", 14.0);
        _memberCountLabel.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
        _memberCountLabel.textAlignment = NSTextAlignmentRight;
        _memberCountLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _memberCountLabel;
}

- (UIImageView *)accessoryImageView {
    if (_accessoryImageView == nil) {
        _accessoryImageView = [[UIImageView alloc] init];
        [_accessoryImageView setImage:[UIImage easeUIImageNamed:@"jh_right_access"]];
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _accessoryImageView;
}

- (UIView *)titleView {
    if (_titleView == nil) {
        _titleView = [[UIView alloc] init];
        [_titleView addSubview:self.nameLabel];
        [_titleView addSubview:self.memberCountLabel];
        [_titleView addSubview:self.accessoryImageView];

        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleView).offset(16.0);
            make.left.equalTo(_titleView).offset(EaseIMKit_Padding * 1.6);
            make.width.equalTo(@(150.0));
        }];
        
        [self.memberCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
            make.centerY.equalTo(self.nameLabel);
            make.right.equalTo(self.accessoryImageView.mas_left);
        }];
        
        
        [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.width.equalTo(@(28.0));
            make.height.equalTo(@(28.0));
            make.right.equalTo(_titleView).offset(-16.0);
        }];


    }
    return _titleView;
}

@end

#undef kAvatarImageHeight
