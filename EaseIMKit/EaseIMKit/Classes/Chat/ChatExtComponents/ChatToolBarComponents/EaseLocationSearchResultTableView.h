//
//  EaseLocationSearchResultTableView.h
//  EaseIMKit
//
//  Created by liu001 on 2022/8/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseLocationSearchResultTableView : UIView

@property (nonatomic, copy) void (^selectedBlock)(NSString *selectedName, NSInteger selectedType);


@end

NS_ASSUME_NONNULL_END
