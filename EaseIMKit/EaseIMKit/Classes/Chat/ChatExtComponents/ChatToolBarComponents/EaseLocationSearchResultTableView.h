//
//  EaseLocationSearchResultTableView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/8/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EaseLocationResultModel;
@interface EaseLocationSearchResultTableView : UIView

@property (nonatomic, copy) void (^selectedBlock)(EaseLocationResultModel *model);

@property (nonatomic, copy) void (^searchLocationBlock)(NSString *searchLocation);


- (void)updateWithSearchResultArray:(NSMutableArray *)tArray;

@end

NS_ASSUME_NONNULL_END
