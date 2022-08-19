//
//  EaseCallSteamCollectionView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/19.
//

#import "EaseCallSteamCollectionView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoStore.h"
#import "EaseHeaders.h"

#define kAvatarImageHeight 38.0

@interface EaseCallSteamCollectionViewItem : UICollectionViewCell
@property (nonatomic, strong) NSMutableArray* callSteamViewArray;

@end

@implementation EaseCallSteamCollectionViewItem
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return self;
}


- (void)placeAndLayoutSubViews {
    
   
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)updateWithObj:(id)obj {
    
}


#pragma mark getter and setter
- (NSMutableArray *)callSteamViewArray {
    if (_callSteamViewArray == nil) {
        _callSteamViewArray = [NSMutableArray array];
    }
    return _callSteamViewArray;
}


@end


@interface EaseCallSteamCollectionView ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIView* titleView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* memberCountLabel;
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) UICollectionView* collectionView;

@end



@implementation EaseCallSteamCollectionView
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
    
    EaseCallSteamCollectionViewItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[EaseCallSteamCollectionViewItem reuseIdentifier] forIndexPath:indexPath];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row -1];
    [cell updateWithObj:obj];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
       
    }
    
}


#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
        
        [_collectionView registerClass:[EaseCallSteamCollectionViewItem class] forCellWithReuseIdentifier:[EaseCallSteamCollectionViewItem reuseIdentifier]];

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

    flowLayout.itemSize = [EaseCallSteamCollectionView collectionViewItemSize];
    flowLayout.minimumLineSpacing = [EaseCallSteamCollectionView collectionViewMinimumLineSpacing];
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
        _nameLabel.font = EaseIMKit_NFont(14.0f);
        
        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
            _nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];

        }else {
            _nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        }
        
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

        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleView).offset(16.0);
            make.left.equalTo(_titleView).offset(EaseIMKit_Padding * 1.6);
            make.right.equalTo(_titleView);
        }];
        
    }
    return _titleView;
}

@end

#undef kAvatarImageHeight

