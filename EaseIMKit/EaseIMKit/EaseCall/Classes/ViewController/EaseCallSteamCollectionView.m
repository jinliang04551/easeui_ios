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
#import "EaseCallStreamView.h"

#define kAvatarImageHeight 38.0

@interface EaseCallSteamCollectionCell : UICollectionViewCell
@property (nonatomic, strong) NSMutableArray* callSteamViewArray;

@end

@implementation EaseCallSteamCollectionCell
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
    self.callSteamViewArray = obj;
    
    int itemWidth = EaseIMKit_ScreenWidth * 0.5;
    int itemHeight = itemWidth;

    for (int i = 0; i < self.callSteamViewArray.count; ++i) {
        UIView *callView = self.callSteamViewArray[i];
        [callView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0 || i == 2) {
                make.left.equalTo(self);
            }else {
                make.left.equalTo(self).offset(itemWidth);
            }
        
            if (i > 1) {
                make.top.equalTo(self).offset(itemHeight);
            }else {
                make.top.equalTo(self);
            }
            
            make.size.equalTo(@(itemWidth));
            
        }];
    }
    
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
    [self addSubview:self.collectionView];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}


- (void)updateUIWithMemberArray:(NSMutableArray *)memberArray {
    [self splitDataWithMemberArray:memberArray];
    [self.collectionView reloadData];
}

- (void)splitDataWithMemberArray:(NSMutableArray *)memberArray {
//    int itemArrays = ceilf(memberArray.count/4);
    NSMutableArray *tArray = [NSMutableArray array];
    
    int loc = 0;
    while (loc < memberArray.count) {
        int length = 0;
        if (loc + 4 < memberArray.count) {
            length = 4;
        }else {
            length = (int)memberArray.count - loc;
        }
        
        NSRange range = NSMakeRange(loc, length);
        NSArray *mArray = [tArray subarrayWithRange:range];
        [tArray addObjectsFromArray:mArray];
        
        loc += length;
    }
    
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
    
    EaseCallSteamCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[EaseCallSteamCollectionCell reuseIdentifier] forIndexPath:indexPath];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row -1];
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
    
        
        [_collectionView registerClass:[EaseCallSteamCollectionCell class] forCellWithReuseIdentifier:[EaseCallSteamCollectionCell reuseIdentifier]];

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
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    return flowLayout;
}

+ (CGSize)collectionViewItemSize {
    CGFloat itemWidth = EaseIMKit_ScreenWidth;
    CGFloat itemHeight = itemWidth;
    return CGSizeMake(itemWidth, itemHeight);
}


+ (CGFloat)collectionViewMinimumLineSpacing {
    return 0;
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

